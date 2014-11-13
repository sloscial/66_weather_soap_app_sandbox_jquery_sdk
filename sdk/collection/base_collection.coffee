###*
Base collection class.  In addition to the standard methods provided by the
[Backbone JS collection class](http://backbonejs.org/#Collection), this base
collection implements paginaton and query parameter mapping.

This class should be subclassed, not used directly.  For example (Coffeescript):
@example
    class People extends AP.collection.Collection
      @collectionId: 'people'
      model: Person
      apiEndpoint: '/person/'
      extraParams:
        format: 'json'

For full collection usage documentation,
refer to [Backbone JS](http://backbonejs.org/#Collection).

@module AP
@submodule collection
@class Collection
@extends Backbone.Collection
###
class AP.collection.Collection extends Backbone.Collection
  ###*
  Name/value pairs appended to URL of requests to server.  For example, extra
  parameters `{format: 'json'}` is passed to server as:  `/url/?format=json`.
  @property extraParams
  @type Object
  ###
  extraParams: {}
  
  
  initialize: -> @extraParams = _.clone(@extraParams or {})
  
  ###*
  Returns the URL for this collection.  By default this is the value of the
  `apiEndpoint` member of the collection.
  @method url
  @return {String} URL of this collection
  ###
  url: -> @apiEndpoint
  
  ###*
  Copies keys in object to keys of the format `query[key_name]`  in a new
  object, where `key_name` is the original key.  Returns a new object leaving
  the original intact.  For example, an input object `{foo: 'bar'}` would
  result in an output object `{query[foo]: 'bar'}`.
  @method mapQueryParams
  @param {Object} data name/value pairs to map to query-format
  @return {Object} a new object with mapped keys
  ###
  mapQueryParams: (data) ->
    query = {}
    for key, value of data
      query["query[#{key}]"] = value if value
    query
  
  ###*
  Fetches objects from the collection instance's URL.  Calls the underlaying
  [Backbone Collection.fetch method](http://backbonejs.org/#Collection-fetch).
  Note:  data from the collection's optional {@link #extraParams} is passed
  through the URL of every request.
  @method fetch
  @param {Object} options optional request data
  @param {Object} options.data optional request parameters are passed through
  request URL as-is
  @param {Object} options.query optional query parameters are passed through
  request URL after being transformed by {@link #mapQuerParams}.
  @param args... optional additional arguments passed-through to underlaying
  [Backbone Collection.fetch method](http://backbonejs.org/#Collection-fetch).
  ###
  fetch: (options, args...) ->
    options ?= {}
    query = @mapQueryParams(options.query) if options?.query
    options.data = _.extend({}, @extraParams, options.data, query)
    Backbone.Collection.prototype.fetch.apply @, [options].concat(args)
  
  ###*
  Convenience method calls {@link #fetch} passing `query` as query parameters.
  @method query
  @param {Object} query name/value pairs passed to {@link #fetch} as query data
  ###
  query: (query, options) ->
    @fetch _.extend({query: query}, options)
