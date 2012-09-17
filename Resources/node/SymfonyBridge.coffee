cp = require 'child_process'
fs = require 'fs'

module.exports = class SymfonyBridge
  constructor: (@console,@kernelDir,@documentRoot,@env) ->

  dumpAsset: (group,index,done) ->
    cmd = 'room13:assetic-server:dump-asset '+group
    cmd+= ' '+index if index
    @command cmd, (data) =>
      if not data
        console.log "server: ERROR dumping asset "+group+" "+index
        return
      done(data)

  readAssets:(done) ->
    @command 'room13:assetic-server:list-assets json', (data) =>
      if not data
        console.log "server: ERROR reading asset list"
        return
      data = JSON.parse data
      done(data)

  command: (command,done) ->
    cmd = @console+' '+command+' --env='+@env
    cp.exec cmd, (error, stdout, stderr) =>
      done stdout
