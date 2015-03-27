async = require 'async'
Stats = require('fast-stats').Stats
_ = require 'lodash'
path = require 'path'

index = require path.join process.cwd(), process.argv[2]

ITERATIONS_TOTAL = 1000

routines = []
durations = {}

durator = (callback) ->
    {key, action} = @

    [starts, startns] = process.hrtime()

    action (error) ->
        [ends, endns] = process.hrtime()

        duration = parseInt ((ends - starts) * 1000 * 1000 * 1000 + endns - startns) / 1000

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

    s = new Stats().push(times).iqr()

    #console.log t for t, i in times when (i % 10) == 0
    console.log 'mean: ', parseInt s.amean()
    console.log 'median: ', parseInt s.median()
    console.log 'stdev: ', parseInt s.stddev()