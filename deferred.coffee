###
Deferred.js - v.0.1.0
(c) 2012 Sudhir Jonathan, contact.me@sudhirjonathan.com
Released under the MIT License.
###
_ = window?._ || require 'underscore'

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

    promise: (candidate) =>
        _promise = candidate or {}
        _promise.state = => @state()
        returnPromise = -> return _promise        
        _.extend _promise, {
            done: => 
                @done arguments...
                return _promise
            fail: => 
                @fail arguments...
                return _promise
            always: => 
                @always arguments...
                return _promise            
        }

executeCallbacks = (callbacks, args) => (callback(args...) for callback in _.flatten(callbacks))
executeOnMatch = (state) -> 
    return (callbacks, holder, closingArgs, stateMatcher) -> 
        if state.match stateMatcher then executeCallbacks callbacks, closingArgs
    
actionFor = {}
actionFor[PENDING] = (callbacks, holder, closingArgs, stateMatcher) -> holder.push _.flatten(callbacks)...
actionFor[RESOLVED] = executeOnMatch RESOLVED
actionFor[REJECTED] = executeOnMatch REJECTED

callbackStorage = (holder, stateMatcher) ->
    return ->                
        actionFor[@_state](arguments, @[holder], @_closingArguments, stateMatcher)                 
        return this

Deferred::done = callbackStorage '_doneCallbacks', RESOLVED
Deferred::fail = callbackStorage '_failCallbacks', REJECTED
Deferred::always = callbackStorage '_alwaysCallbacks', /.*/

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


(exports ? window).Deferred = -> new Deferred()
