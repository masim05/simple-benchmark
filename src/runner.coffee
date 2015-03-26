async = require 'async'
stats = require 'fast-stats'

index = require './index.coffee'

ITERATIONS_TOTAL = 100

routines = []
durations = {}

durator = (callback) ->
    {key, action} = @

    start = new Date()

    action (error) ->
        duration = new Date() - start

        if durations.hasOwnProperty key
            console.log "duplicated key: #{key}, rewriting."

            delete durations[key]

        value = durations[key] =
            duration: duration

        value.error = error if error

        callback()


routines.push durator.bind({action: a, key: 'prolog'}) if typeof (a = index.prolog) is 'function'

if typeof (a = index.action) is 'function'
    for i in [0...ITERATIONS_TOTAL]
        routines.push durator.bind({action: a, key: "action_#{i}"})

routines.push durator.bind({action: a, key: 'epilog'}) if typeof (a = index.epilog) is 'function'

async.series routines, (error) ->
    console.log error if error

    console.log durations