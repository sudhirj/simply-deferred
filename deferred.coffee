_ = require 'underscore'

PENDING = "pending"
RESOLVED = "resolved"
REJECTED = "rejected"

class _Deferred
    constructor: ->
        @_state = PENDING
        @_doneCallbacks = []
        @_failCallbacks = []
        @_alwaysCallbacks = []
        @_closingArguments = []

    state: =>
        @_state

    _close: (newState, callbackSets, args) =>
        @_state = newState
        @_closingArguments = args
        @_executeCallbacks callbackSets, args


    resolve: =>
        if @_state is PENDING
            @_close RESOLVED, [@_doneCallbacks, @_alwaysCallbacks], arguments            
        return this

    reject: =>
        if @_state is PENDING            
            @_close REJECTED, [@_failCallbacks, @_alwaysCallbacks], arguments                        
        return this

    done: =>
        callbacks = _.flatten arguments 
        if @_state is PENDING
            @_doneCallbacks.push callbacks...
        if @_state is RESOLVED
            @_executeCallbacks callbacks, @_closingArguments
        return this

    fail: =>
        callbacks = _.flatten arguments
        if @_state is PENDING
            @_failCallbacks.push callbacks...
        if @_state is REJECTED
            @_executeCallbacks callbacks, @_closingArguments
        return this

    always: =>
        callbacks = _.flatten arguments
        if @_state is PENDING
            @_alwaysCallbacks.push (_.flatten arguments)...
        else 
            @_executeCallbacks callbacks, @_closingArguments
        return this

    _executeCallbacks: (callbacks, args) =>
        (callback(args...) for callback in _.flatten(callbacks))

    then: => @always arguments...

exports.Deferred = -> new _Deferred()
