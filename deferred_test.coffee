deferred = require './deferred'
assert = require 'assert'
_ = require 'underscore'


expectedMethods = ['done', 'fail', 'always', 'state', 'then', 'pipe']
assertHasPromiseApi = (promise) -> assert _.has(promise, method) for method in expectedMethods
assertIsPromise = (promise) -> assertHasPromiseApi promise

describe 'deferred', ->
  it 'should create and return a deferred object', ->
    def = new deferred.Deferred()
    assert.equal def.state(), "pending"

  it 'should maintain a resolved state', ->
    def = new deferred.Deferred()
    assert.equal def.state(), "pending"
    def.resolve()
    assert.equal def.state(), "resolved"
    def.resolve()
    assert.equal def.state(), "resolved"
    def.reject()
    assert.equal def.state(), "resolved"


  it 'should maintain a rejected state', ->
    def = new deferred.Deferred()
    assert.equal def.state(), "pending"
    def.reject()
    assert.equal def.state(), "rejected"
    def.reject()
    assert.equal def.state(), "rejected"
    def.resolve()
    assert.equal def.state(), "rejected"

  it 'should call all the done callbacks', (done) ->
    def = new deferred.Deferred()
    callback = _.after 8, done
    def.done(callback).done([callback, callback])
    def.resolve()
    def.done callback, callback
    def.reject()
    def.done callback, [callback, callback]
    def.fail callback, callback

  it 'should scope done callbacks when using resolveWith', (done) ->
    callback = _.after 2, done
    def = new deferred.Deferred()
    finishHolder = {finisher: callback}
    finish = (arg1) ->
      assert.equal(42, arg1)
      @finisher()
    def.done finish
    def.always -> callback()
    def.resolveWith(finishHolder, 42)
    assert.equal def.state(), 'resolved'

  it 'should scope fail callbacks when using rejectWith', (done) ->
    callback = _.after 2, done
    def = new deferred.Deferred()
    finishHolder = {finisher: callback}
    finish = (arg1) ->
      assert.equal(42, arg1)
      @finisher()
    def.fail finish
    def.always -> callback()
    def.rejectWith(finishHolder, 42)
    assert.equal def.state(), 'rejected'


  it 'should call all the fail callbacks', (done) ->
    def = new deferred.Deferred()
    callback = _.after 8, done
    def.fail(callback).fail([callback, callback])
    def.reject()
    def.fail callback, callback
    def.resolve()
    def.fail callback, [callback, callback]
    def.done callback

  it 'should call all the always callbacks on resolution', (done) ->
    def = new deferred.Deferred()
    callback = _.after 8, done
    def.always(callback).always([callback, callback])
    def.resolve()
    def.always callback, callback
    def.always callback, [callback, callback]
    def.fail callback

  it 'should call the always callbacks on rejection', (done) ->
    def = new deferred.Deferred()
    def.always done
    def.reject()
    def.done done

  it 'should call callbacks with arguments', (done) ->
    finish = _.after 8, done
    callback = (arg1, arg2) ->
      if arg1 is 42 and arg2 is 24
        finish()
    new deferred.Deferred().always(callback).resolve(42, 24).always(callback)
    new deferred.Deferred().always(callback).reject(42, 24).always(callback)
    new deferred.Deferred().done(callback).resolve(42, 24).done(callback)
    new deferred.Deferred().fail(callback).reject(42, 24).fail(callback)

  it 'should provide a when method', (done) ->
    callback = _.after 4, -> done()
    def1 = new deferred.Deferred().done callback
    def2 = new deferred.Deferred().done callback
    def3 = new deferred.Deferred().done callback
    all = deferred.when(def1, def2, def3).done callback
    def1.resolve()
    def2.resolve()
    def3.resolve()

  describe 'pipe', ->
    it 'should pipe on resolution', (done) ->
      finisher = (value) -> if value is 10 then done()
      def = new deferred.Deferred()
      filtered = def.pipe (value) -> value * 2
      def.resolve 5
      filtered.done finisher

    it 'should pipe on rejection', (done) ->
      finisher = (value) -> if value is 6 then done()
      def = new deferred.Deferred()
      filtered = def.pipe null, (value) -> value * 3
      def.reject 2
      filtered.fail finisher

    it 'should pipe with arrays intact', (done) ->
      finisher = (value) ->
        if value.length is [1,2,3].length then done()
      def = new deferred.Deferred()
      filtered = def.pipe null, (value) ->
        value.push(3)
        value
      def.reject([1,2])
      filtered.fail finisher

    it 'should pass through for null filters for done', (done) ->
      finisher = (value) -> if value is 5 then done()
      def = new deferred.Deferred()
      filtered = def.pipe(null, null)
      def.resolve 5
      filtered.done finisher

    it 'should pass through for null filters for fail', (done) ->
      finisher = (value) -> if value is 5 then done()
      def = new deferred.Deferred()
      filtered = def.pipe(null, null)
      def.reject 5
      filtered.fail finisher

    it 'should accept promises from filters and call them later with arguments', (done) ->
      def = deferred.Deferred()

      filter = (result) ->
        assert.equal result, 'r1'
        def2 = deferred.Deferred()
        setTimeout (-> def2.resolve('r2')), 100
        def2

      def.then(filter).done (result) ->
        assert.equal result, 'r2'
        done() if result is 'r2'

      def.resolve('r1')

  describe 'then', ->
    it 'should alias pipe', ->
      def = new deferred.Deferred()
      assert.equal def.then, def.pipe

  describe 'promises', ->
    it 'should provide a promise that has a restricted API', (done) ->
      def = new deferred.Deferred()
      promise = def.promise()

      assertIsPromise promise

      callback = _.after 5, done
      promise.always(callback).always(callback).fail(callback).done(callback).fail(callback)
      assertIsPromise promise.done callback
      assertIsPromise promise.fail callback
      assertIsPromise promise.always callback

      assert.equal "pending", promise.state()
      def.resolve()
      assert.equal "resolved", promise.state()

    it 'should create a promise out of a given object', ->
      candidate = {id: 42}
      def = new deferred.Deferred()
      promise = def.promise(candidate)
      assert.equal candidate, promise
      assertHasPromiseApi candidate

    it 'should soak up extraneous promises', ->
        def = new deferred.Deferred()
        promise = def.promise().promise()
        assertIsPromise promise

        promise.done (arg) -> assert.equal arg, 42
        def.resolve(42)

    describe 'when', ->
      it 'should return a promise', ->
        assertIsPromise deferred.when new deferred.Deferred()

      it 'should resolve when all deps have succeeded', ->
        d1 = new deferred.Deferred()
        d2 = new deferred.Deferred()
        after_all = deferred.when(d1, d2)
        d1.resolve()
        assert.equal after_all.state(), 'pending'
        d2.resolve()
        assert.equal after_all.state(), 'resolved'

      it 'should reject when there are some failures', ->
        d1 = new deferred.Deferred()
        d2 = new deferred.Deferred()
        after_all = deferred.when(d1, d2)
        d1.resolve()
        assert.equal after_all.state(), 'pending'
        d2.reject()
        assert.equal after_all.state(), 'rejected'

      it 'should pass on reject arguments', (done) ->
        d1 = new deferred.Deferred()
        d2 = new deferred.Deferred()
        after_all = deferred.when(d1, d2)
        after_all.fail (arg1) -> done() if arg1 is 42
        d1.resolve()
        d2.reject 42

      it 'should pass on resolve arguments as is when used with a single deferred', (done) ->
        d1 = new deferred.Deferred()
        after_all = deferred.when(d1)
        after_all.done (arg1) -> done() if arg1 is 42
        d1.resolve(42)

      it 'should special case single or no arguments when using multiple deferreds', (done) ->
        d1 = new deferred.Deferred()
        d2 = new deferred.Deferred()
        d3 = new deferred.Deferred()
        after_all = deferred.when(d1, d2, d3)
        after_all.done (arg1, arg2, arg3) ->
          assert.equal arg1, 42
          assert.equal arg2, undefined
          assert.deepEqual arg3, ['abc', 123]
          done()

        d2.resolve()
        d3.resolve('abc', 123)
        d1.resolve(42)

      it 'should handle non promise arguments', ->
        deferred.when(1, 2, 42).done((arg1, arg2, arg3) ->
          assert.equal arg1, 1
          assert.equal arg2, 2
          assert.equal arg3, 42
        )

      it 'should handle zero arguments', (done) ->
        deferred.when().done(done)

  describe 'installation into a jQuery compatible library', ->
    exampleArgs = [42, 24]
    it 'should install .Deferred', ->
      zepto = {}
      deferred.installInto(zepto)
      assertHasPromiseApi zepto.Deferred()

    it 'should install .when', ->
      zepto = {}
      deferred.installInto(zepto)
      assert.equal zepto.when.toString(), deferred.when.toString()

    it 'should wrap .ajax()', (done) ->
      zepto = {}
      zepto.ajax = (options) -> done()
      deferred.installInto zepto
      assertIsPromise zepto.ajax()

    it 'should resolve on success', (done) ->
      callback = _.after 3, done
      zepto = {}
      zepto.ajax = (options) -> options.success(exampleArgs...)
      deferred.installInto zepto
      success = (args...) -> if args.length is exampleArgs.length then callback()
      promise = zepto.ajax({
        success: success
      })
      promise.done success
      promise.always success
      promise.fail -> fail()

    it 'should provide an abort mechanism', (done) ->
      zepto = {}
      zepto.ajax = (options) -> {
        abort: -> done()
      }
      deferred.installInto zepto
      promise = zepto.ajax()
      promise.abort()


    it 'should reject on failure', (done) ->
      callback = _.after 3, done
      zepto = {}
      zepto.ajax = (options) -> options.error(exampleArgs...)
      deferred.installInto zepto
      error = (args...) -> if args.length is exampleArgs.length then callback()
      promise = zepto.ajax({
        error: error
      })
      promise.fail error
      promise.always error
      promise.done -> fail()

    it 'should work when no ajax callbacks are provided', (done) ->
      zepto = {}
      zepto.ajax = (options) -> options.success()
      deferred.installInto zepto
      zepto.ajax({
        success: null
      }).done(done)

