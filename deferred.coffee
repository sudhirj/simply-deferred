###
Deferred.js - v.0.1.0
(c) 2012 Sudhir Jonathan, contact.me@sudhirjonathan.com
Released under the MIT License.
###
_ = window?._ || require 'underscore'

PENDING = "pending"
RESOLVED = "resolved"
REJECTED = "rejected"

flatten = _.flatten
pushWhenPending = (state, holder, args) -> if state is PENDING then holder.push (flatten args)...
execute = (callbacks, args) -> callback args... for callback in callbacks

Deferred = ->
    state = PENDING
    doneCallbacks = []
    failCallbacks = []
    alwaysCallbacks = []
    closingArguments = {}
    
    @promise = (candidate) ->
        candidate = candidate || {}
        candidate.state = -> state

        conditionallyExecute = (shouldRun, args) -> if shouldRun then execute flatten(args), closingArguments
        
        candidate.done = ->
            pushWhenPending state, doneCallbacks, arguments            
            conditionallyExecute state is RESOLVED, arguments
            return candidate
        candidate.fail = ->
            pushWhenPending state, failCallbacks, arguments
            conditionallyExecute state is REJECTED, arguments
            return candidate
        candidate.always = ->
            pushWhenPending state, alwaysCallbacks, arguments
            conditionallyExecute state isnt PENDING, arguments
            return candidate
        
        return candidate
    
    @promise this
    
    terminate = (finalState, callbacks, args) ->    
        if state is PENDING
            state = finalState
            closingArguments = args
            execute callbacks, closingArguments            
            execute alwaysCallbacks, closingArguments
    
    @resolve = ->
        terminate RESOLVED, doneCallbacks, arguments
        return this
    
    @reject = ->
        terminate REJECTED, failCallbacks, arguments
        return this
    
    return this



(exports ? window).Deferred = -> new Deferred()
