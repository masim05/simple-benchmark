dnode = require 'dnode'

SERVER_PORT = 3000

server = dnode
    ping: (callback) ->
        #console.log '.'
        callback null, 'ok.'

server.listen SERVER_PORT, -> console.log "listening #{SERVER_PORT}"