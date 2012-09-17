AsseticServer = require './AsseticServer'
SymfonyBridge = require './SymfonyBridge'

symfony = new SymfonyBridge('./frontend/console','frontend','web/frontend','dev');
server = new AsseticServer(symfony,8124)
server.start()


#/js/0533f21_mustache_2.js
#/js/0533f21.js
#/js/0533f21_jquery.ui.location-autocomplete_4.js
#
#console.log "maping symfony bundles"
#Symfony.readBundles (data) ->
#  bundles = data
#  console.log "reading assetic cache"
#  Symfony.readAsseticCache asseticCache, (data) ->
#    console.log data



