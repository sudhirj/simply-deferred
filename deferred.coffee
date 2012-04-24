_ = _ || require 'underscore'

PENDING = "pending"
RESOLVED = "resolved"
REJECTED = "rejected"

class Deferred    
    constructor: ->
        @_state = PENDING
        @_doneCallbacks = []
        @_failCallbacks = []
        @_alwaysCallbacks = []
        @_closingArguments = []

    state: => @_state

executeCallbacks = (callbacks, args) => (callback(args...) for callback in _.flatten(callbacks))
    
actionFor = {}
actionFor[PENDING] = (callbacks, holder, closingArgs) -> holder.push _.flatten(callbacks)...
actionFor[RESOLVED] = (callbacks, holder, closingArgs) -> executeCallbacks callbacks, closingArgs
actionFor[REJECTED] = actionFor[RESOLVED]

callbackStorage = (holder) ->
    return ->        
        actionFor[@_state](arguments, @[holder], @_closingArguments)                 
        return this

terminator = (targetState, callbackSetNames) ->
    return ->
        if @_state is PENDING
            @_state = targetState
            @_closingArguments = arguments
            callbackSets = callbackSetNames.map (name) => @[name]
            executeCallbacks callbackSets, arguments
        return this

Deferred::resolve = terminator RESOLVED, ['_doneCallbacks', '_alwaysCallbacks']
Deferred::reject = terminator REJECTED, ['_failCallbacks', '_alwaysCallbacks']

Deferred::done = callbackStorage '_doneCallbacks'
Deferred::fail = callbackStorage '_failCallbacks'
Deferred::always = callbackStorage '_alwaysCallbacks'
Deferred::then = callbackStorage '_alwaysCallbacks'

(exports ? window).Deferred = -> new Deferred()
