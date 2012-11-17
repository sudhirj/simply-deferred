###
Simply Deferred - v.1.2
(c) 2012 Sudhir Jonathan, contact.me@sudhirjonathan.com, MIT Licensed.
Portions of this code are inspired and borrowed from Underscore.js (http://underscorejs.org/) (MIT License)
###

PENDING = "pending"
RESOLVED = "resolved"
REJECTED = "rejected"

has = (obj, prop) -> obj?.hasOwnProperty prop
isArguments = (obj) -> return has(obj, 'length') and has(obj, 'callee')

flatten = (array) ->
    return flatten Array.prototype.slice.call(array) if isArguments array
    return [array] if not Array.isArray array
    return array.reduce (memo, value) ->
        return memo.concat flatten value if Array.isArray(value)
        memo.push value
        return memo
    , []

after = (times, func) ->
    return func() if times <= 0
    return -> func.apply(this, arguments) if --times < 1

wrap = (func, wrapper) ->
    return ->
        args = [func].concat Array.prototype.slice.call(arguments, 0)
        wrapper.apply this, args

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

        pipe = (doneFilter, failFilter) ->                        
            deferred = new Deferred()
            filter = (target, source, filter) ->
                if filter then target -> source filter (flatten arguments)...
                else target -> source (flatten arguments)...
            filter candidate.done, deferred.resolve, doneFilter
            filter candidate.fail, deferred.reject, failFilter
            deferred

        candidate.done = storeCallbacks((-> state is RESOLVED), doneCallbacks)
        candidate.fail = storeCallbacks((-> state is REJECTED), failCallbacks)
        candidate.always = storeCallbacks((-> state isnt PENDING), alwaysCallbacks)
        candidate.pipe = pipe
        candidate.then = pipe

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
    finish = after defs.length, trigger.resolve
    def.done(finish) for def in defs
    def.fail(-> trigger.reject()) for def in defs
    trigger.promise()


installInto = (fw) ->
    fw.Deferred = -> new Deferred()
    fw.ajax = wrap fw.ajax, (ajax, options = {}) ->
        def = new Deferred()

        createWrapper = (wrapped, finisher) ->
            return wrap wrapped, (func, args...) ->
                func(args...) if func
                finisher(args...)

        options.success = createWrapper options.success, def.resolve
        options.error = createWrapper options.error, def.reject

        ajax(options)

        def.promise()

    fw.when = _when

if (typeof exports isnt 'undefined')
    exports.Deferred = -> new Deferred()
    exports.when = _when
    exports.installInto = installInto
else
    this.Deferred = -> new Deferred();
    this.Deferred.when = _when
    this.Deferred.installInto = installInto
