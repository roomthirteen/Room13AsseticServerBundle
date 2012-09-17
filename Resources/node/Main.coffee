AsseticServer = require './AsseticServer'
SymfonyBridge = require './SymfonyBridge'

port = 8124
kernelRoot ='app'
documentRoot = 'web'
environment='dev'
consoleBin = './bin/console'

if process.argv[2]
  port = parseInt(process.argv[2])
if process.argv[3]
  kernelRoot = process.argv[3]
if process.argv[4]
  documentRoot = process.argv[4]
if process.argv[5]
  environment = process.argv[5]
if process.argv[6]
  consoleBin = process.argv[6]

console.log "Asset server starting with:"
console.log " Port         : "+port
console.log " KernelRoot   : "+kernelRoot
console.log " DocumentRoot : "+documentRoot
console.log " Environment  : "+environment
console.log " Console      : "+consoleBin
console.log ".\n"


symfony = new SymfonyBridge(consoleBin,kernelRoot,documentRoot,environment);
server = new AsseticServer(symfony,port)
server.start()
