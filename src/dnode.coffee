dnode = require 'dnode'
fs = require 'fs'
path = require 'path'

SERVER_PORT = 3000

count = 0

response = fs.readFileSync path.join __dirname, './response.json'


server = dnode
    ping: (callback) ->
        console.log new Date() unless (count++ % 5000)
        callback null, response

server.listen SERVER_PORT, -> console.log "listening #{SERVER_PORT}"