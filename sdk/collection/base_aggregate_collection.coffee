###*
Unlike a normal `AP.collection.Collection`, aggregate collections expect a
simple integer-only response from the server.  Aggregate collections are always
zero-length (they have no members).  They have an extra member `value`.
@module AP
@submodule collection
@class AggregateCollection
@extends AP.collection.ScopeCollection
###
class AP.collection.AggregateCollection extends AP.collection.ScopeCollection
  ###*
  The value last returned by this collection's URL.
  @property value
  @type Number
  ###
  value: null
  
  ###*
  @method valueOf
  @return {Number} the value of {@link #value}
  ###
  valueOf: -> @value
  
  ###*
  Called automatically whenever {@link AP.collection.Collection#fetch} returns.
  The response is parsed as an integer and stored in {@link #value}.  `parse`
  ignores any other data returned by the server.
  @method parse
  @param {String} response the value returned by the server
  ###
  parse: (response) ->
    @value = parseInt(response, 10)
    []
