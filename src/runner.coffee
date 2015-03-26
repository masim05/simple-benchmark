async = require 'async'
Stats = require('fast-stats').Stats
_ = require 'lodash'

index = require './index.coffee'

ITERATIONS_TOTAL = 100

routines = []
durations = {}

durator = (callback) ->
    {key, action} = @

    start = new Date()

    action (error) ->
        duration = new Date() - start

        switch key
            when 'prolog' then space = durations

            when 'epilog' then space = durations

            else
                space = durations.actions ?= {}


        if space.hasOwnProperty key
            console.log "duplicated key: #{key}, rewriting."

            delete space[key]

        value = space[key] =
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

    console.log "Prolog: #{r.duration}, err: #{!!r.error}" if r = durations.prolog
    console.log "Epilog: #{r.duration}, err: #{!!r.error}" if r = durations.epilog

    times = _.filter(durations.actions, (value) -> !value.error).map (e) -> e.duration

    s = new Stats().push times

    console.log 'mean: ', s.amean().toFixed 2
    console.log 'median: ', s.median().toFixed 2
    console.log 'stdev: ', s.stddev().toFixed 2