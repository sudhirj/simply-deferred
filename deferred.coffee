_ = require 'underscore'

PENDING = "pending"
RESOLVED = "resolved"
REJECTED = "rejected"

executeCallbacks = (callbacks, args) => (callback(args...) for callback in _.flatten(callbacks))
    
actionFor = {}
actionFor[PENDING] = (callbacks, holder, closingArgs) -> holder.push _.flatten(callbacks)...
actionFor[RESOLVED] = (callbacks, holder, closingArgs) -> executeCallbacks callbacks, closingArgs
actionFor[REJECTED] = actionFor[RESOLVED]

class _Deferred    
    constructor: ->
        @_state = PENDING
        @_doneCallbacks = []
        @_failCallbacks = []
        @_alwaysCallbacks = []
        @_closingArguments = []

        @state = => @_state

        callbackStorage = (holder) =>
            return =>        
                actionFor[@_state](arguments, holder, @_closingArguments)                 
                return this

        @done = callbackStorage @_doneCallbacks
        @fail = callbackStorage @_failCallbacks
        @always = callbackStorage @_alwaysCallbacks
        @then = callbackStorage @_alwaysCallbacks

        terminator = (targetState, callbackSets) =>
            return =>
                if @_state is PENDING
                    @_state = targetState
                    @_closingArguments = arguments
                    executeCallbacks callbackSets, arguments
                return this

        @resolve = terminator RESOLVED, [@_doneCallbacks, @_alwaysCallbacks]
        @reject = terminator REJECTED, [@_failCallbacks, @_alwaysCallbacks]

exports.Deferred = -> new _Deferred()
