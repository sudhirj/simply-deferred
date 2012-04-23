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
        

    it 'should call all the fail callbacks', (done) ->
        def = new deferred.Deferred()
        callback = _.after 8, done
        def.fail(callback).fail([callback, callback])        
        def.reject()
        def.fail callback, callback
        def.resolve()
        def.fail callback, [callback, callback]     

    it 'should call all the done callbacks', (done) ->
        def = new deferred.Deferred()
        callback = _.after 8, done
        def.done(callback).done([callback, callback])        
        def.resolve()
        def.done callback, callback
        def.reject()
        def.done callback, [callback, callback]

    it 'should call all the always callbacks on resolution', (done) ->
        def = new deferred.Deferred()
        callback = _.after 8, done
        def.always(callback).always([callback, callback])        
        def.resolve()
        def.always callback, callback
        def.always callback, [callback, callback]        

    it 'should call the always callbacks on rejection', (done) ->
        def = new deferred.Deferred()        
        def.always done        
        def.reject()

    it 'should call callbacks with arguments', (done) ->        
        finish = _.after 8, done
        callback = (arg1, arg2) ->
            if arg1 is 42 and arg2 is 24
                finish()
        new deferred.Deferred().then(callback).resolve(42, 24).always(callback)
        new deferred.Deferred().always(callback).reject(42, 24).then(callback)        
        new deferred.Deferred().done(callback).resolve(42, 24).done(callback)
        new deferred.Deferred().fail(callback).reject(42, 24).fail(callback)

    it 'should alias always() to then()', (done) ->
        def = new deferred.Deferred()        
        callback = _.after 2, done
        def.always(callback).then(callback).resolve()
        





