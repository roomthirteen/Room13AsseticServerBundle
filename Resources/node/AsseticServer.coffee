Http    = require 'http'
Zlib    = require('zlib');
Mime    = require 'mime'
Fs      = require 'fs'
Cp      = require 'child_process'
Symfony = require './SymfonyBridge'
Coffee  = require 'coffee-script'
Inotify = require('inotify').Inotify
Crypto  = require('crypto')

inotify = new Inotify()

class AsseticServer
  resources: {}

  constructor: (@symfony, @port) ->
    @server = Http.createServer (request, response) =>
      @handleRequest request,response

  handleRequest: (request, response) ->
    # if a url is not mapped, it might be a static file resource not handled by assetic
    if not @resources.hasOwnProperty(request.url)
      absPath = @symfony.documentRoot+request.url
      try
        stats = Fs.lstatSync absPath
        # register newly found file as resource
        @resources[request.url] = new StaticResource(request.url,absPath)
      catch error
    # lookup and dispatch
    resource = @getResource(request.url)
    @sendContent resource,request,response

  getResource: (url) ->
    if not @resources[url]
      return new UnknownResource(url)
    return @resources[url]

  sendContent: (resource,request,response) ->
    if resource.content and resource.etag and request.headers['if-none-match'] and resource.etag == request.headers['if-none-match']
      response.writeHead 304,
        'Content-Type': resource.mime
        'Etag': resource.etag
      response.end()
      return

    resource.get (content) =>
      response.writeHead resource.error | 200
        'Content-Type': resource.mime
        'Etag': resource.etag
      response.end content

  start: ->
    console.log "server: scan assets"
    @reloadAssets =>
      @server.listen @port
      console.log "server: on your demand"

      # watch symfony asset list for changes
      setInterval @checkAssetsChanged.bind(this),2000

  checkAssetsChanged: ->
    @symfony.readAssets (assets) =>
      newResources = {}
      # get symfony registered assets
      for url,files of assets
        url = '/'+url
        if not @resources[url]
          # new asset found
          console.log "server: new resource "+url
          resource = new AsseticResource url,files,@symfony
        else
          # asset still exists
          resource = @resources[url]
        newResources[url]=resource
      # now we can remove old assets
      for url,resource of @resources
        if resource.file
          newResources[url]=resource
        else if not newResources[url]
          console.log "old resource "+url
      # from now on serve only the current assets
      @resources = newResources

  reloadAssets: (cbl) ->
    @urls = {}
    @symfony.readAssets (assets) =>
      for url,files of assets
        url = '/'+url;
        resource = new AsseticResource url,files,@symfony
        @resources[url] = resource
      cbl()


class Resource
  constructor: (@url) ->


class AsseticResource
  constructor: (@url,@target,@symfony) ->
    @etag = null
    @content = null
    @mime = Mime.lookup(@url)
    # parse the assetic url... monster
    @assetic = new AsseticUrl(@url)
    # watch file changes
    if typeof @target == 'string'
      FileEvents.onChange @target, =>
        @content = null
        @etag = null
        @symfony.dumpAsset @assetic.group,@assetic.index, (content) =>
          @content = content
          @etag = Crypto.createHash('md5').update(@content).digest("hex")
          console.log "server: asset reloaded",@url

  get: (done) ->
    if @content
      done @content
    else
      console.log "server: read asset "+@url
      @symfony.dumpAsset @assetic.group,@assetic.index, (content) =>
        @content = content
        @etag = Crypto.createHash('md5').update(@content).digest("hex")
        done @content



class StaticResource
  constructor: (@url,@file) ->
    @mime = Mime.lookup(@file)
    @etag = null
    @content = null
    inotify.addWatch
      path:@file
      watch_for: Inotify.IN_CLOSE_WRITE
      callback:  =>
        console.log "server: static resouce changed ",file
        @etag = null
        @content = null
  get: (done) ->
    if @content
      done @content
    else
      console.log "server: load static",@url
      Fs.readFile @file, (error,content) =>
        @content = content
        @etag = Crypto.createHash('md5').update(@content).digest("hex")
        done @content

class UnknownResource extends Resource
  mime: 'text/html'
  error: 404
  get: (done) ->
    done "<!DOCTYPE html>
    <html>
    <head>
    <title>File not found "+@url+"</title>
    </head>
    <body>
      <h1>Not found</h1>
      <p>"+@url+"</p>
    </body>
    </html> "


FileEvents =
  onChange: (file,cbl) ->
    inotify.addWatch
      path:file
      watch_for: Inotify.IN_CLOSE_WRITE
      callback: ->
        FileEvents.onChange file,cbl
        cbl()

class AsseticUrl
  constructor: (@url) ->
    @path = @url.substr(0,@url.lastIndexOf('/'))
    @file= @url.substr(@url.lastIndexOf('/')+1)
    @type = @file.substr(@file.lastIndexOf('.')+1)
    if @file.indexOf('_') < 0
      @group = @file.substr(0,@file.lastIndexOf('.'))
      @name = null
      @index = null
    else
      @group = @file.substr(0,@file.indexOf('_'))
      tmp =  @file.substr(@file.indexOf('_')+1)
      @name = tmp.substr(0,tmp.lastIndexOf('_'))
      tmp1 = tmp.substr(tmp.lastIndexOf('_')+1)
      @index = tmp1.substr(0,tmp1.lastIndexOf('.'))

module.exports = AsseticServer