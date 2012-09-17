cp = require 'child_process'
fs = require 'fs'

module.exports = class SymfonyBridge
  constructor: (@console,@kernelDir,@documentRoot,@env) ->

  dumpAsset: (group,index,done) ->
    cmd = 'room13:assetic-server:dump-asset '+group
    cmd+= ' '+index if index
    @command cmd, (data) =>
      done(data)

  readAssets:(done) ->
    @command 'room13:assetic-server:list-assets json', (data) =>
      data = JSON.parse data
      done(data)

  command: (command,done) ->
    cmd = './frontend/console '+command
    cp.exec cmd, (error, stdout, stderr) =>
      done stdout
