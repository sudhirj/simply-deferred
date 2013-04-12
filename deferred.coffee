# #Simply Deferred
# ###Simplified Deferred Library (jQuery API) for Node and the Browser
# ####MIT Licensed.
# Portions of this code are inspired and borrowed from [underscore.js](http://underscorejs.org/) (MIT License)
# ####[Source (github)](http://github.com/sudhirj/simply-deferred) | [Documentation](https://github.com/sudhirj/simply-deferred#simply-deferred)
# &copy; Sudhir Jonathan [sudhirjonathan.com](http://www.sudhirjonathan.com)

VERSION = '1.3.2'

# First, let's set up the constants that we'll need to signify the state of the `deferred` object. These will be returned from the `state()` method.

PENDING = "pending"
RESOLVED = "resolved"
REJECTED = "rejected"

# `has` and `isArguments` are both workarounds for JS quirks. We use them only to flatten arrays. 

# `has` checks if an object natively owns a particular property, 
has = (obj, prop) -> obj?.hasOwnProperty prop
# while `isArguments` checks if the given object is a method arguments object (like an array, but not quite).
isArguments = (obj) -> return has(obj, 'length') and has(obj, 'callee')

# Borrowed from the incredibly useful [underscore.js](http://underscorejs.org/), these three utilities help 
# flatten argument arrays,
flatten = (array) ->
  return flatten Array.prototype.slice.call(array) if isArguments array
  return [array] if not Array.isArray array
  # > `reduce` requires a modern JS interpreter, or a shim.
  return array.reduce (memo, value) ->    
    return memo.concat flatten value if Array.isArray(value)
    memo.push value
    return memo
  , []

# call functions only after they've been invoked a certain number of times, 
after = (times, func) ->
  return func() if times <= 0
  return -> func.apply(this, arguments) if --times < 1

# and wrap functions so we can run code before and after execution.
wrap = (func, wrapper) ->
  return ->
    args = [func].concat Array.prototype.slice.call(arguments, 0)
    wrapper.apply this, args

# Now we'll need a general callback executor, with optional control over the execution context.
execute = (callbacks, args, context) -> callback.call(context, args...) for callback in flatten callbacks

# Let's start with the Deferred object constructor - it needs no arguments 
Deferred = ->
  # and all `deferred` objects are in a `'pending'` state when initialized.
  state = PENDING
  doneCallbacks = []
  failCallbacks = []
  closingArguments = {}
  # Calling `.promise()` gives you an object that you pass around your code indiscriminately. 
  # Any code can add callbacks to a `promise`, but none can alter the state of the `deferred` itself. 
  # You can also transform any candidate object into a promise for this particular deferred object by passing it in.
  @promise = (candidate) ->
    candidate = candidate || {}
    # `.state()` returns the state of the current deferred object. This will be one of `'pending'`, `'resolved'` or `'rejected'`.
    candidate.state = -> state

    # Let's now create a mechanism to store the callbacks that are added in, or execute them immediately if the deferred has already been resolved or rejected.
    storeCallbacks = (shouldExecuteImmediately, holder) ->
      return ->
        if state is PENDING then holder.push (flatten arguments)...
        if shouldExecuteImmediately() then execute arguments, closingArguments
        return candidate
    # Now we can add success / resolution callbacks using `.done(callback)`,
    candidate.done = storeCallbacks((-> state is RESOLVED), doneCallbacks)
    # or failure callbacks using `.fail(callback)`,
    candidate.fail = storeCallbacks((-> state is REJECTED), failCallbacks)
    # or register a callback to always fire when the deferred is either resolved or rejected - using `.always(callback)`
    candidate.always = -> candidate.done(arguments...).fail(arguments...)      

    # It also makes sense to set up a piper to which can filter the success or failure arguments through the given filter methods. 
    # Quite useful if you want to transform the results of a promise or log them in some way. 
    pipe = (doneFilter, failFilter) ->                        
      deferred = new Deferred()
      filter = (target, source, filter) ->
        if filter then target -> source filter (flatten arguments)...
        else target -> source (flatten arguments)...
      filter candidate.done, deferred.resolve, doneFilter
      filter candidate.fail, deferred.reject, failFilter
      deferred

    # Expose the `.pipe(doneFilter, failFilter)` method and alias it to `.then()`.
    candidate.pipe = pipe
    candidate.then = pipe

    return candidate

  # Since we now have a way to create all the public methods that this deferred needs on a candidate object, let's use it to create them on itself.
  @promise this

  # Moving to the methods that exist only on the deferred object itself, 
  # let's create a generic closing function that stores the final resolution / rejection arguments for future callbacks;
  # and then runs all the callbacks that have already been set. 
  close = (finalState, callbacks, context) ->
    return ->
      if state is PENDING
        state = finalState
        closingArguments = arguments
        execute callbacks, closingArguments, context
      return this
  # Now we can set up `.resolve([args])` method to close the deferred and call the `done` callbacks,
  @resolve = close RESOLVED, doneCallbacks
  # and `.reject([args])` to fail it and call the `fail` callbacks.
  @reject = close REJECTED, failCallbacks
  # We can also set up `.resolveWith(context, [args])` and `.rejectWith(context, [args])` to allow setting an execution scope for the callbacks.
  @resolveWith = (context, args...) -> close(RESOLVED, doneCallbacks, context)(args...)
  @rejectWith = (context, args...) -> close(REJECTED, failCallbacks, context)(args...)

  return this
 
# If we're dealing with multiple deferreds, it would be nifty to have a way to run code after all of them succeed (or any of them fail). 
# Let's set up a `.when([deferreds])` method to do that. It should be able to take any number or deferreds as arguments (or an array of them).
_when = ->
  trigger = new Deferred()
  defs = flatten arguments
  finish = after defs.length, trigger.resolve
  def.done(finish) for def in defs
  def.fail(trigger.reject) for def in defs
  trigger.promise()

# Since the core team of [Zepto](http://zeptojs.com/) (and maybe other jQuery compatible libraries) don't seem to like the idea of Deferreds / Promises too much, 
# let's put in an easy way to install this library into Zetpo.
installInto = (fw) ->
  # Add the `.Deferred()` constructor on to the framework. 
  fw.Deferred = -> new Deferred()
  # And wrap the `.ajax()` method to return a promise instead.
  fw.ajax = wrap fw.ajax, (ajax, options = {}) ->
    def = new Deferred()

    createWrapper = (wrapped, finisher) ->
      return wrap wrapped, (func, args...) ->
        func(args...) if func
        finisher(args...)
    # This should let us do `request.done(callback)` instead of passing callbacks in to the options hash. 
    # Also lets us add as many callbacks as we need at any point in the code.
    options.success = createWrapper options.success, def.resolve
    # Rinse and repeat for errors. We can now use `request.fail(callback)`.
    options.error = createWrapper options.error, def.reject

    ajax(options)

    def.promise()
  # Let's also alias the `.when()` method, for good measure.
  fw.when = _when

# Finally, let's support node by exporting the intersting stuff
if (typeof exports isnt 'undefined')
  exports.Deferred = -> new Deferred()
  exports.when = _when
  exports.installInto = installInto
else
# and the browser by setting the functions on `window`.
  this.Deferred = -> new Deferred();
  this.Deferred.when = _when
  this.Deferred.installInto = installInto

# That's all, folks. The End.