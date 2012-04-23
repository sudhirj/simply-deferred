
class _Deferred
    constructor: ->
        @_state = "pending"

    state: =>
        @_state

    resolve: =>
        if @_state is "pending"
            @_state = "resolved"

    reject: =>
        if @_state is "pending"
            @_state = "rejected"

Deferred = ->
    new _Deferred()

exports.Deferred = Deferred