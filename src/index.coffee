dnode = require 'dnode'

service = undefined
remote = undefined

module.exports =
    prolog: (callback) ->
        service = dnode.connect
            host: 'localhost'
            port: 3000

        service.on 'remote', (rem) ->
            remote = rem
            callback()


    action: (callback) -> remote.ping callback

    epilog: (callback) ->
        service.end()
        callback()