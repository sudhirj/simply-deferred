deferred = require './deferred'
assert = require 'assert'
_ = require 'underscore'

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
        callback = _.after 4, done
        def1 = new deferred.Deferred().done callback
        def2 = new deferred.Deferred().done callback
        def3 = new deferred.Deferred().done callback
        all = deferred.when(def1, def2, def3).done callback
        def1.resolve()
        def2.resolve()
        def3.resolve()

    
    describe 'promises', ->
        expectedMethods = ['done', 'fail', 'always', 'state']
        assertHasPromiseApi = (promise) -> assert _.has(promise, method) for method in expectedMethods
        assertIsPromise = (promise) ->            
            assert.equal _.keys(promise).length, expectedMethods.length
            assertHasPromiseApi promise
            
        it 'should provide a promise that has a restricted API', (done) ->
            def = new deferred.Deferred()
            promise = def.promise()
                    
            assertIsPromise promise    

            callback = _.after 5, done
            promise.always(callback).always(callback).fail(callback).done(callback).fail(callback)
            assertIsPromise promise.done callback
            assertIsPromise promise.fail callback
            assertIsPromise promise.always callback

            assert "pending", promise.state()
            def.resolve()
            assert "resolved", promise.state()

        it 'should create a promise out of a given object', ->
            candidate = {id: 42}
            def = new deferred.Deferred()
            promise = def.promise(candidate)
            assert.equal candidate, promise
            assertHasPromiseApi candidate

        describe 'when', ->
            it 'should return a promise', ->
                assertIsPromise deferred.when new deferred.Deferred()
