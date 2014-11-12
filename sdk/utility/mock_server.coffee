###*
Mock server instances are used by the test framework to intercept XHR requests
and simulate the functionality of an API backend, entirely offline.  A mock
server handles all requests matching collections within the application within
which it is instantiated.

To enable a mock server in an application, simply enable the global
`useMockServer` flag:
@example
    AP.useMockServer = true

@module AP
@submodule utility
@class MockServer
###
class AP.utility.MockServer
  ###*
  @module AP
  @submodule utility
  @submodule MockServer
  @class Collections
  @static
  ###
  class @Collections
    ###*
    Number of model instances with which to prepopulate a collection
    instantiated via `AP.utility.MockServer.Collections.createCollectionInstanceFor`.
    @property instancesPerCollection
    @type Number
    @static
    ###
    @instancesPerCollection: 3
    
    ###*
    Generates an `AP.collection.Collection` collection instance from the given
    collection class.  The instance is prepopulated with a number of model
    instances appropriate to the collection, the number of which is defined
    by {@link #instancesPerCollection}.
    @method createCollectionInstanceFor
    @static
    @param {AP.collection.Collection} collectionClass a class object
    @return {AP.collection.Collection} prepopulated collection instance
    ###
    @createCollectionInstanceFor: (collectionClass) ->
      collection = new collectionClass
      instances = @createInstancesFor collectionClass::model
      collection.add instances
      collection
    
    ###*
    Generates a number of `AP.model.Model` model instances from the given model
    class.  The number generated
    @method createInstancesFor
    @static
    @param {AP.model.Model} modelClass a class object
    @return {AP.model.Model[]} array of model instances
    ###
    @createInstancesFor: (modelClass) ->
      for num in [0...@instancesPerCollection]
        instance = @createInstanceFor modelClass, num
        # Use deterministic ID attributes.
        # This simplifies instance lookups in test cases by making instance IDs
        # deducible using nothing more a than model name.
        idAttribute = modelClass::idAttribute
        instance.set idAttribute, "#{modelClass.name}-#{num}"
        instance
    
    ###*
    Generates a single `AP.model.Model` model instance from the given model
    class, prepopulated with random field data
    via {@link AP.utility.MockServer.Models.generateRandomInstanceDataFor}.
    @method createInstanceFor
    @static
    @param {AP.model.Model} modelClass a class object
    @return {AP.model.Model} a model instance
    ###
    @createInstanceFor: (modelClass) ->
      instanceData = AP.utility.MockServer.Models.generateRandomInstanceDataFor modelClass
      new (modelClass)(instanceData)
  
  ###*
  @module AP
  @submodule utility
  @submodule MockServer
  @class Models
  @static
  ###
  class @Models
    ###*
    Generates random field data for a model class based on that class'
    field definitions.
    @method generateRandomInstanceDataFor
    @static
    @param {AP.model.Model} modelClass a class object
    @return {Object} key/value hash of field names and randomly generated values
    appropriate for use in instantiating the model class
    ###
    @generateRandomInstanceDataFor: (modelClass) ->
      _.object _.map modelClass::fieldDefinitions, (fieldDef) =>
        name = fieldDef.name
        value = @generateRandomFieldDataFor fieldDef
        [name, value]
    
    ###*
    Generates random field data for a model class based on that class'
    field definitions.
    @method generateRandomFieldDataFor
    @static
    @param {AP.model.Model} fieldDef a class object
    @return {Object} key/value hash of field names and randomly generated values
    appropriate for use in instantiating the model class
    ###
    @generateRandomFieldDataFor: (fieldDef) ->
      switch fieldDef.type
        when 'string' then _.uniqueId "#{fieldDef.name}_"
        when 'boolean' then ((Math.random() * 100) < 50)
        when 'integer' then _.random 0, 1000000000
        when 'float' then Math.random() * 1000000000
        when 'date', 'time' then (new Date()).toISOString()
        when 'array' then [_.random(0, 1000000000), _.random(0, 1000000000), _.random(0, 1000000000),]
        when 'hash' then {"field1": _.uniqueId('field1'), "field2": _.uniqueId('field2'), "field3": _.uniqueId('field3')}
  
  ###*
  The application class with which this mock server as instantiated.
  See {@link #initialize}.
  @property application
  @type AP.Application
  ###
  application: null
  
  ###*
  A sinon fake server instance, automatically instantiated.  The sinon fake
  server intercepts XHR requests and handles the low-level request/response
  cycle.  See [Sinon.JS](http://sinonjs.org) for more information.
  @private
  @property server
  @type sinon.fakeServer
  ###
  server: null
  
  ###*
  The collections property is an internal datastore used by the mock server to
  simulate a database.  The collections property is a collection (database) of
  collections (tables) with additional metadata for ease of use.
  @private
  @property collections
  @type Backbone.Collection
  ###
  collections: null
  
  constructor: -> @initialize.apply @, arguments
  
  ###*
  Constructs a mock server instance.
  @method initialize
  @param {AP.Application} application an application class to which this
  mock server applies
  ###
  initialize: (@application) ->
    # initialize a sinon fake XHR server
    @server = sinon.fakeServer.create()
    @server.autoRespond = true
    #@server.autoRespondAfter = 5
    # initialize an empty collection of collections
    # as collections are instantiated to help serve responses, they
    # will be inserted into this collection
    @collections = new Backbone.Collection
    # initialize sinon responses for each collection in the SDK
    @initResponses()
  
  ###*
  Initializes XHR request interceptors via sinon for requests originating from
  any collection within the application.
  @method initResponses
  ###
  initResponses: ->
    responseUrls = []
    _.each @application.collections, (collectionClass) =>
      url = @getEndpointUrlFor collectionClass
      urlWithQueryString = @getEndpointRegexWithQueryStringFor collectionClass
      @server.respondWith 'GET', urlWithQueryString, (xhr) => @handleRequest(xhr, collectionClass)
      if _.indexOf(responseUrls, url) < 0
        responseUrls.push url
        url = @getEndpointRegexFor collectionClass
        @server.respondWith 'POST', url, (xhr) => @handleRequest(xhr, collectionClass)
        @server.respondWith 'PUT', url, (xhr) => @handleRequest(xhr, collectionClass)
        @server.respondWith 'DELETE', url, (xhr) => @handleRequest(xhr, collectionClass)
  
  ###*
  Returns the API endpoint URL associated with a given collection class.
  @method getEndpointUrlFor
  @param {AP.collection.Collection} collectionClass a collection class
  @return {String} the API enpoint URL for the collection class
  ###
  getEndpointUrlFor: (collectionClass) ->
    collectionClass::apiEndpoint
  
  ###*
  Returns a regular expression used to match URLs for the given
  collection class.
  @method getEndpointRegexFor
  @param {AP.collection.Collection} collectionClass a collection class
  @return {RegExp} a regular expression matching the API endpoint URL of the
  collection class
  ###
  getEndpointRegexFor: (collectionClass) ->
    new RegExp "#{@getEndpointUrlFor(collectionClass).replace('.json', '')}".replace('.', '\\.')
  
  ###*
  Returns a regular expression used to match URLs for the given
  collection class with respect for URL query parameters matching the collection
  class' `extraParams`.
  @method getEndpointRegexWithQueryStringFor
  @param {AP.collection.Collection} collectionClass a collection class
  @return {RegExp} a regular expression matching the API endpoint URL of the
  collection class with respect for `extraParams` as query parameters
  ###
  getEndpointRegexWithQueryStringFor: (collectionClass) ->
    new RegExp "#{@getEndpointUrlFor(collectionClass)}?#{$.param collectionClass::extraParams}".replace('?', '\\?').replace('&', '\\&').replace('.', '\\.')
  
  ###*
  Gets the previously instantiated collection matching the given colleciton
  class, if one exists in the internal datastore, otherwise instantiates one.
  @method getOrCreateCollectionInstanceFor
  @param {AP.collection.Collection} collectionClass a collection class
  @return {AP.collection.Collection} a collection instance from the datastore
  ###
  getOrCreateCollectionInstanceFor: (collectionClass) ->
    name = collectionClass::model.name
    collection = @collections.findWhere {name: name}
    if !collection
      collection = AP.utility.MockServer.Collections.createCollectionInstanceFor collectionClass
      @collections.add
        id: collectionClass::collectionId
        name: name
        instance: collection
    collection?.get('instance') or collection
  
  ###*
  Resets internal datastore.
  This is useful when tests require consistent datastore behavior across runs.
  @method resetDatastore
  ###
  resetDatastore: ->
    @collections.reset([])
  
  ###*
  Parses query parameters out of URL, if any, and transforms them according to
  the given collection class' query fields, if any.
  See `AP.collection.ScopeCollection`.
  @method parseQuery
  @param {AP.collection.Collection} collectionClass a collection class
  @return {Object} query parameters parsed from a URL with respect to the given
  collection class' query fields
  ###
  parseQuery: (url, collectionClass) ->
    modelClass = collectionClass::model
    queryFields = collectionClass::queryFields
    parsed = _.map url.split('?')[1].split('&'), (bits) ->
      bits = bits.split('=')
      [decodeURIComponent(bits[0]), decodeURIComponent(bits[1])]
    # filter out non-query parameters
    query = _.filter parsed, (pair) -> pair[0].indexOf('query') == 0
    if query.length
      # unwrap query keys (`query[id]` becomes `id`)
      query = _.map query, (pair) ->
        key = pair[0].replace(/query\[(.*)\]/, '$1')
        value = pair[1]
        [key, value]
      # convert query parameters into associated query fields, if necessary
      query = _.map query, (pair) ->
        queryField = _.findWhere queryFields, {paramName: pair[0]}
        pair[0] = queryField.fieldName if queryField
        pair
      # cast values, if necessary
      query = _.map query, (pair) =>
        key = pair[0]
        value = @castValue(modelClass, key, pair[1])
        [key, value]
      # return query array as an object
      _.object query
    else
      null
  
  ###*
  @method castValue
  @param {AP.model.Model} modelClass a model class
  @param {String} fieldName name of field in `modelClass`
  @param {String} fieldValue uncast value of field
  ###
  castValue: (modelClass, fieldName, fieldValue) ->
    fieldDef = _.findWhere modelClass::fieldDefinitions, {name: fieldName}
    # Cast all values except IDs.
    # IDs are formatted as deterministic strings for simplified testing.
    # See `createInstancesFor` for details.
    if fieldDef.name == modelClass::idAttribute
      fieldValue
    else
      switch fieldDef.type
        when 'integer' then parseInt(fieldValue, 10)
        when 'float' then parseFloat(fieldValue)
        else fieldValue
  
  ###*
  Delegates an intercepted XHR request to the appropriate method, depending on
  the request method.  `GET`, `POST`, and `PUT` are supported at this time, but
  `DELETE` is not.
  @method handleRequest
  @param {AP.collection.Collection} collectionClass a collection class
  @return {Object} query parameters parsed from a URL with respect to the given
  collection class' query fields
  ###
  handleRequest: (xhr, collectionClass) ->
    switch xhr.method.toLowerCase()
      when 'get' then @handleGetRequest(xhr, collectionClass)
      when 'post' then @handlePostRequest(xhr, collectionClass)
      when 'put' then @handlePutRequest(xhr, collectionClass)
      when 'delete' then @handleDeleteRequest(xhr, collectionClass)
  
  ###*
  Handles an intercepted XHR `GET` request for the given collection class.  If
  no query is passed, all model instances in the appropriate collection are
  serialized to JSON and returned via a mock XHR `200` response.
  
  If a query is passed, only matching models are returned.
  
  @method handleGetRequest
  @param {Object} xhr mock XHR request object generated by sinon
  @param {AP.collection.Collection} collectionClass the collection class to
  which this request applies
  ###
  handleGetRequest: (xhr, collectionClass) ->
    query = @parseQuery xhr.url, collectionClass
    collectionInstance = @getOrCreateCollectionInstanceFor collectionClass
    results = collectionInstance.where(query) if query
    responseBody = JSON.stringify(results or collectionInstance.toJSON())
    xhr.respond 200, {"Content-Type": "application/json"}, responseBody
  
  ###*
  Handles an intercepted XHR `POST` request for the given collection class.  The
  passed request body must be valid JSON.  It is parsed and used to instantiate
  a new model instance of the appropriate type using a randomly generated ID.
  The new model instance is added to the internal datastore and will be returned
  by future requests to the collection.  The resulting model instances is JSON
  serialized and returned via a mock XHR `201` response.
  @method handlePostRequest
  @param {Object} xhr mock XHR request object generated by sinon
  @param {AP.collection.Collection} collectionClass the collection class to
  which this request applies
  ###
  handlePostRequest: (xhr, collectionClass) ->
    collectionInstance = @getOrCreateCollectionInstanceFor collectionClass
    model = collectionInstance.model
    data = JSON.parse xhr.requestBody
    instance = new (model)(data)
    idFieldDef = _.findWhere(instance.fieldDefinitions, {name: model::idAttribute})
    instance.set model::idAttribute, AP.utility.MockServer.Models.generateRandomFieldDataFor(idFieldDef)
    collectionInstance.add instance
    responseBody = JSON.stringify(instance.toJSON())
    xhr.respond 201, {"Content-Type": "application/json"}, responseBody
  
  ###*
  Handles an intercepted XHR `PUT` request for the given collection class.  The
  passed request body must be valid JSON and must contain an ID attribute.
  It is parsed and used to update an existing model instance of the appropriate
  type within the datastore.
  
  If the requested instance exists, it is JSON  serialized and returned via a
  mock XHR `200` response.
  
  If the requested instance does not exist, a mock XHR `404` response is sent.
  
  @method handlePutRequest
  @param {Object} xhr mock XHR request object generated by sinon
  @param {AP.collection.Collection} collectionClass the collection class to
  which this request applies
  ###
  handlePutRequest: (xhr, collectionClass) ->
    collectionInstance = @getOrCreateCollectionInstanceFor collectionClass
    model = collectionInstance.model
    data = JSON.parse xhr.requestBody
    id = xhr.url.split('/').reverse()[0].replace('.json', '')
    idAttribute = model::idAttribute
    whereClause = {}
    whereClause[idAttribute] = @castValue(model, idAttribute, id)
    instance = collectionInstance.findWhere(whereClause)
    if instance
      instance.set data
      responseBody = JSON.stringify(instance.toJSON())
      xhr.respond 200, {"Content-Type": "application/json"}, responseBody
    else
      xhr.respond 404
  
  ###*
  Handles an intercepted XHR `DELETE` request for the given collection class.
  The passed request body must be valid JSON and must contain an ID attribute.
  It is parsed and used to remove an existing model instance from the datastore.
  
  If the requested instance exists, an empty XHR `204` response is returned.
  
  If the requested instance does not exist, a mock XHR `404` response is sent.
  
  @method handleDeleteRequest
  @param {Object} xhr mock XHR request object generated by sinon
  @param {AP.collection.Collection} collectionClass the collection class to
  which this request applies
  ###
  handleDeleteRequest: (xhr, collectionClass) ->
    collectionInstance = @getOrCreateCollectionInstanceFor collectionClass
    model = collectionInstance.model
    id = xhr.url.split('/').reverse()[0].replace('.json', '')
    idAttribute = model::idAttribute
    whereClause = {}
    whereClause[idAttribute] = @castValue(model, idAttribute, id)
    instance = collectionInstance.findWhere(whereClause)
    if instance
      collectionInstance.remove instance
      responseBody = ''
      xhr.respond 204, {"Content-Type": "application/json"}, responseBody
    else
      xhr.respond 404
