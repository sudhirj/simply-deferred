deferred = require './deferred'
assert = require 'assert'

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

    

