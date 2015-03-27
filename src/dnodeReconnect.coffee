dnode = require 'dnode'

service = undefined
remote = undefined

module.exports =
    prolog: (callback) -> callback()

    action: (callback) ->
        service = dnode.connect
            host: 'localhost'
            port: 3000

        service.on 'remote', (remote) ->
            remote.ping () ->

                service.end()
                callback()

    epilog: (callback) -> callback()