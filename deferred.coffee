###
Simply Deferred - v.1.1.0
(c) 2012 Sudhir Jonathan, contact.me@sudhirjonathan.com
Released under the MIT License.
###

_ = window?._ || require 'underscore'

PENDING = "pending"
RESOLVED = "resolved"
REJECTED = "rejected"

flatten = _.flatten
execute = (callbacks, args) -> callback args... for callback in flatten callbacks

Deferred = ->
    state = PENDING
    doneCallbacks = []
    failCallbacks = []
    alwaysCallbacks = []
    closingArguments = {}
    
    @promise = (candidate) ->
        candidate = candidate || {}
        candidate.state = -> state
        
        storeCallbacks = (shouldExecuteImmediately, holder) ->
            return ->
                if state is PENDING then holder.push (flatten arguments)...                
                if shouldExecuteImmediately() then execute arguments, closingArguments
                return candidate
        
        candidate.done = storeCallbacks((-> state is RESOLVED), doneCallbacks)            
        candidate.fail = storeCallbacks((-> state is REJECTED), failCallbacks)
        candidate.always = storeCallbacks((-> state isnt PENDING), alwaysCallbacks)
        
        return candidate
    
    @promise this
    
    close = (finalState, callbacks) ->    
        return ->
            if state is PENDING
                state = finalState
                closingArguments = arguments
                execute [callbacks, alwaysCallbacks], closingArguments                            
            return this
    
    @resolve = close RESOLVED, doneCallbacks
    @reject = close REJECTED, failCallbacks
            
    return this


_when = ->
    trigger = new Deferred()
    defs = flatten arguments
    finish = _.after defs.length, trigger.resolve
    def.done(finish) for def in defs
    trigger.promise()


_installInto = (fw) ->
    fw.Deferred = -> new Deferred()
    fw.ajax = _.wrap fw.ajax, (ajax, options = {}) ->
        def = new Deferred()

        createWrapper = (wrapped, finisher) ->
            return _.wrap wrapped, (func, args...) ->
                func(args...)
                finisher(args...)

        options.success = createWrapper options.success, def.resolve        
        options.error = createWrapper options.error, def.reject

        ajax(options)
        
        def.promise()


if (typeof exports isnt 'undefined')     
    exports.Deferred = -> new Deferred()
    exports.when = _when
    exports.installInto = _installInto
else 
    this['Deferred'] = -> new Deferred();
    this['Deferred']['when'] = _when
    this['Deferred']['installInto'] = _installInto
  
