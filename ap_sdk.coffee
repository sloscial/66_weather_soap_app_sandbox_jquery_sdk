###*
Provides the global namespace for SDK framework classes.  Provides convenience
methods for app management.
@module AP
@static
###
class AP
  ###*
  Name of the active application.
  @property activeAppName
  @type String
  ###
  @activeAppName: null
  
  ###*
  Namespace for authentication/authorization classes.
  @property auth
  @type Object
  ###
  @auth: {}
  
  ###*
  Namespace for general utility classes.
  @property utility
	@type Object
  ###
  @utility: {}
  
  ###*
  Namespace for SDK model superclasses.
  @property model
	@type Object
  ###
  @model: {}
  
  ###*
  Namespace for SDK collection superclasses.
  @property collection
	@type Object
  ###
  @collection: {}
  
  ###*
  Namespace for model relationship classes.
  @property relationship
	@type Object
  ###
  @relationship: {}
  
  ###*
  Namespace for apps.  In most cases only one app is present.
  @property apps
	@type Object
  ###
  @apps: {}
  
  ###*
  Base URL for all XHR requests.
  @property baseUrl
	@type String
  ###
  @baseUrl: null
  
  ###*
  Enables mock server in all applications.  SinonJS is required if
  `useMockServer` is `true`.
  @property useMockServer
	@type Boolean
  ###
  @useMockServer: false
  
  ###*
  Enables offline caching of successful `GET` requests.
  @property useOfflineCache
	@type Boolean
  ###
  @useOfflineCache: true
  
  ###*
  Offline cache storage capacity in bytes.
  @property offlineStorageCapacity
  @type Number
  ###
  @offlineStorageCapacity: 5 * 1024 * 1024 # request capacity in bytes
  
  ###*
  Registers an app class with a given name.  The name may be used later
  for look-up.  Registering an app with a duplicate name replaces any
  existing app.
  @method registerApp
  @param {AP.Application} app the application class
  @param {String} name the name of the application
  ###
  @registerApp: (app, name) -> @apps[name] = (app) if app and name
  
  ###*
  Returns an app class registered under the given name.
  @method getApp
  @param {String} name the name of the application to look up
  @return {AP.Application} the application class
  ###
  @getApp: (name) -> @apps[name]
  
  ###*
  Returns the currently active app, if any.
  @method getActiveApp
  @return {AP.Application} the active application class, if any.
  ###
  @getActiveApp: -> AP.getApp @activeAppName


window.AP = AP

###*
Utility singleton for encoding and decoding Base64 strings.
@module AP
@submodule utility
@class Base64
@static
@private
###
class AP.utility.Base64
  ###*
  @property _keyStr
  @type String
  @static
  @private
  ###
  @_keyStr: 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/='
  
  ###*
  Encodes an input string to Base64.
  @method encode
  @static
  @param {String} input the string to be Base64-encoded
  @return {String} a Base64-encoded string
  ###
  @encode: (input) ->
    output = ''
    i = 0
    input = Base64._utf8_encode(input)
    while i < input.length
      chr1 = input.charCodeAt(i++)
      chr2 = input.charCodeAt(i++)
      chr3 = input.charCodeAt(i++)
      enc1 = chr1 >> 2
      enc2 = ((chr1 & 3) << 4) | (chr2 >> 4)
      enc3 = ((chr2 & 15) << 2) | (chr3 >> 6)
      enc4 = chr3 & 63
      if isNaN(chr2)
        enc3 = enc4 = 64
      else enc4 = 64  if isNaN(chr3)
      output = output +
        @_keyStr.charAt(enc1) +
        @_keyStr.charAt(enc2) +
        @_keyStr.charAt(enc3) +
        @_keyStr.charAt(enc4)
    output
  
  ###*
  Decodes an input string from Base64.
  @method decode
  @static
  @param {String} input the string to be Base64-decoded
  @return {String} a string decoded from Base64
  ###
  @decode: (input) ->
    output = ''
    i = 0
    input = input.replace(/[^A-Za-z0-9\+\/\=]/g, '')
    while i < input.length
      enc1 = @_keyStr.indexOf(input.charAt(i++))
      enc2 = @_keyStr.indexOf(input.charAt(i++))
      enc3 = @_keyStr.indexOf(input.charAt(i++))
      enc4 = @_keyStr.indexOf(input.charAt(i++))
      chr1 = (enc1 << 2) | (enc2 >> 4)
      chr2 = ((enc2 & 15) << 4) | (enc3 >> 2)
      chr3 = ((enc3 & 3) << 6) | enc4
      output = output + String.fromCharCode(chr1)
      output = output + String.fromCharCode(chr2)  unless enc3 is 64
      output = output + String.fromCharCode(chr3)  unless enc4 is 64
    output = Base64._utf8_decode(output)
    output
  
  ###*
  @private
  @method _utf8_encode
  @static
  ###
  @_utf8_encode: (string) ->
    string = string.replace(/\r\n/g, '\n')
    utftext = ''
    n = 0
    while n < string.length
      c = string.charCodeAt(n)
      if c < 128
        utftext += String.fromCharCode(c)
      else if (c > 127) and (c < 2048)
        utftext += String.fromCharCode((c >> 6) | 192)
        utftext += String.fromCharCode((c & 63) | 128)
      else
        utftext += String.fromCharCode((c >> 12) | 224)
        utftext += String.fromCharCode(((c >> 6) & 63) | 128)
        utftext += String.fromCharCode((c & 63) | 128)
      n++
    utftext
  
  ###*
  @private
  @method _utf8_decode
  @static
  ###
  @_utf8_decode: (utftext) ->
    string = ''
    i = 0
    c = c1 = c2 = 0
    while i < utftext.length
      c = utftext.charCodeAt(i)
      if c < 128
        string += String.fromCharCode(c)
        i++
      else if (c > 191) and (c < 224)
        c2 = utftext.charCodeAt(i + 1)
        string += String.fromCharCode(((c & 31) << 6) | (c2 & 63))
        i += 2
      else
        c2 = utftext.charCodeAt(i + 1)
        c3 = utftext.charCodeAt(i + 2)
        string += String.fromCharCode(((c & 15) << 12) | ((c2 & 63) << 6) | (c3 & 63))
        i += 3
    string

###*
Simplifies interaction with browser cookies.
@module AP
@submodule utility
@class Cookie
@static
###
class AP.utility.Cookie
  ###*
  @method getFromCookieStorage
  @static
  @return {String} a copy of the raw cookie string
  ###
  @getFromCookieStorage: -> document.cookie.toString()
  
  ###*
  Saves cookie to document cookies.
  @method saveToCookieStorage
  @static
  @param {String} cookie a formatted cookie-string to save to document cookies
  ###
  @saveToCookieStorage: (cookie) -> document.cookie = cookie
  
  ###*
  Formats an expiration date for a cookie string.
  @method formatCookieStorageDate
  @static
  @param {Integer/Date} expiration number of days from today after which to
  expire cookie *or* a JavaScript `Date` of the absolute expiration date.
  ###
  @formatCookieStorageDate: (expiration) ->
    if _.isNumber expiration
      d = new Date()
      d.setTime d.getTime() + (expiration * 86400000)
      expiration = d
    expiration.toGMTString() if _.isDate expiration
  
  ###*
  Builds a formatted cookie-string for saving to `document.cookies`.
  @method buildCookieStorageString
  @static
  @param {String} n name of cookie
  @param {String} v value of cookie
  @param {Integer/Date} expiration optional number of days from today after
  which to expire cookie *or* a JavaScript `Date` of the absolute
  expiration date.
  ###
  @buildCookieStorageString: (n, v, expiration) ->
    e = ''
    if expiration
      e = '; expires=' + @formatCookieStorageDate(expiration)
    n + '=' + v + e + '; path=/'
  
  ###*
  Saves a cookie to `document.cookies`.
  @method set
  @static
  @param {String} n name of cookie
  @param {String} v value of cookie
  @param {Integer/Date} expiration optional number of days from today after
  which to expire cookie *or* a JavaScript `Date` of the absolute
  expiration date.
  ###
  @set: (n, v, expiration) ->
    cookie = @buildCookieStorageString n, v, expiration
    @saveToCookieStorage cookie
  
  ###*
  Returns a cookie with name `n` from underlaying cookie
  storage, `document.cookie`.
  @method get
  @static
  @param {String} n name of cookie
  @return {String} the cookie value, if any
  ###
  @get: (n) ->
    ca = @getFromCookieStorage().split ';'
    match = n + '='
    c = ''
    i = 0
    while i < ca.length
      c = ca[i].replace /^\s*/, ''
      if c.indexOf(match) is 0
        return c.substring match.length, c.length
      i++
    null
  
  ###*
  Deletes a cookie with name `n` from underlaying cookie storage.
  @method del
  @static
  @param {String} n name of cookie
  ###
  @del: (n) ->
    @set n, '', -1

###*
Utility singleton for working with URLs and paths.
@module AP
@submodule utility
@class Url
@static
@private
###
class AP.utility.Url
  ###*
  @method parseUrl
  @static
  @param {String} url the URL to parse
  @return {Object} the bits and pieces of a URL as key/value pairs
  ###
  @parseUrl: (url) ->
    path =
      urlParseRE: /^\s*(((([^:\/#\?]+:)?(?:(\/\/)((?:(([^:@\/#\?]+)(?:\:([^:@\/#\?]+))?)@)?(([^:\/#\?\]\[]+|\[[^\/\]@#?]+\])(?:\:([0-9]+))?))?)?)?((\/?(?:[^\/\?#]+\/+)*)([^\?#]*)))?(\?[^#]+)?)(#.*)?/
      getLocation: (url) ->
        uri = if url then this.parseUrl(url) else location
        hash = this.parseUrl(url || location.href).hash
        hash = if hash == '#' then '' else hash
        return uri.protocol + '//' + uri.host + uri.pathname + uri.search + hash
    return url if $.type(url) == 'object'
    matches = path.urlParseRE.exec(url || '') || []
    {
      href:         matches[  0 ] || ''
      hrefNoHash:   matches[  1 ] || ''
      hrefNoSearch: matches[  2 ] || ''
      domain:       matches[  3 ] || ''
      protocol:     matches[  4 ] || ''
      doubleSlash:  matches[  5 ] || ''
      authority:    matches[  6 ] || ''
      username:     matches[  8 ] || ''
      password:     matches[  9 ] || ''
      host:         matches[ 10 ] || ''
      hostname:     matches[ 11 ] || ''
      port:         matches[ 12 ] || ''
      pathname:     matches[ 13 ] || ''
      directory:    matches[ 14 ] || ''
      filename:     matches[ 15 ] || ''
      search:       matches[ 16 ] || ''
      hash:         matches[ 17 ] || ''
    }

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

###*
Provides an extensible facility for validating arbitrary data.  While validator
is used primarily by {@link AP.model.Model}, it may be used to
validate any data object.

Subclass validator to implement additional validation types.  Built-in
validation types include:

- `required`:  field must have a non-null value
- `type`:  field type is consistent with the type specified in `is`

Example usage:
@example
    validator = new AP.utility.Validator();
    validator.data = {
      name: 'John Doe',
      age: 46
    };
    validator.validations = [{
      field: 'name',
      validate: 'required'
    }, {
      field: 'age',
      validate: 'type',
      is: 'integer'
    }];

    validator.validate();
    // true
    validator.data.age = null;
    validator.validate();
    // true
    // age is not required:  although "null" is not an integer, it is valid
    // because the type validator ignores null values.
    
    validator.data.name = '';
    validator.validate();
    // false

@module AP
@submodule utility
@class Validator
###
class AP.utility.Validator
  ###*
  Internal errors array.  If the errors array contains any errors then the
  validator is considered to be in an invalid state.
  @private
  @property _errors
  @type Object[]
  ###
  _errors: []
  
  ###*
  Internal hash of error messages.  Each key is an error type where its value
  is an error message string.
  @private
  @property _errorMessages
  @type Object
  ###
  _errorMessages: {
    required: 'this field is required'
    
    numericality: 'this field must resemble a number'
    
    booleanType: 'this field must be a boolean'
    stringType: 'this field must be a string'
    numberType: 'this field must be a number'
    integer: 'this field must be an integer'
    float: 'this field must be a float'
    
    missingType: 'this field cannot be validated as type {0}'
  }
  
  ###*
  The data object to validate.
  @property data
  @type Object
  ###
  data: {}
  
  ###*
  A list of validations to apply.  Validations is an array of validation
  configuration objects.  Validation configuration objects must contain at least
  the following members:
  
  - `field`:  a key in the {@link #data} object
  - `validate`:  a string reprenting the validation type
  
  Certain validations may require additional information.  For example, the
  `type` validation requires an `is` member, the data type.
  
  For example:
  @example
      [
        field: 'name'
        validate: 'required'
      ,
        field: 'amount'
        validate: 'numericality'
      ,
        field: 'age'
        validate: 'type'
        is: 'integer'
      ]
  
  @property validations
  @type Object[]
  ###
  validations: []
  
  constructor: (@data, @validations) ->
    @_errors = []
    @data = _.clone(@data)
    @validations = _.clone(@validations)
  
  ###*
  Returns true if the validator has no errors.  **Note**:  {@link #validate}
  should be executed before calling `isValid`.  Always returns `true` if
  executed before `validate`.
  @method isValid
  @return {Boolean} `true` if there 
  ###
  isValid: -> !@errors().length
  
  ###*
  Applies the validations specified in {@link #validations} to {@link #data},
  clearing any existing errors first.
  @method validate
  @return {Boolean} the return value of {@link #isValid}.
  ###
  validate: ->
    @_errors = []
    for validation in @validations
      if @[validation.validate]
        @[validation.validate](@data[validation.field], validation)
    @isValid()
  
  ###*
  Adds an error of `type` for field `fieldName` to the validator where `type` is
  a key in the internal {@link #_errorMessages error messages hash}.  Additional
  data may be passed as an array via `extra` which is interpolated into the
  error message.
  @method addError
  @param {String} fieldName the field to which the error applies
  @param {String} type the error type, corresponding to a key in the internal
  error messages hash.
  @param {String[]} [extra] optional array of strings to be interpolated into
  the error message
  ###
  addError: (fieldName, type, extra) ->
    message = @_errorMessages[type] or 'is invalid'
    if extra
      for value, i in extra
        message = message.replace("{#{i}}", value)
    @_errors.push
      field: fieldName
      message: message
  
  ###*
  Returns the internal errors array.
  @method errors
  @return {String[]} the internal errors array.
  ###
  errors: -> @_errors
  
  ###*
  Validates that the value is non-null.  If null or undefined, adds an error.
  @method required
  @param value the value to validate
  @param {Object} options a validation configuration object, for example:
      {field: 'title', validate: 'required'}
  ###
  required: (value, options) ->
    if value == null or value == undefined
      @addError(options.field, 'required')
  
  ###*
  Validates that the value looks like a number.  The value is allowed to be
  either a strict string or number type, as long as it looks like a number.
  @method numericality
  @param value the value to valiate as numerical
  @param {Object} options a validation configuration object, for example:
      {field: 'amount', validate: 'numericality'}
  ###
  numericality: (value, options) ->
    @addError(options.field, 'numericality') if value? and !value.toString().match /^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$/
  
  ###*
  Validates that the value is of a specified type.  Adds an error if the value
  is not of the specified type.
  @method type
  @param value the value to validate
  @param {Object} options a validation configuration object with an extra `is`
  member to specify type, for example:
      {field: 'title', validate: 'type', is: 'string'}
  ###
  type: (value, options) ->
    type = options.is.toLowerCase()
    if @["#{type}Type"]
      @["#{type}Type"](value, options)
    else
      @addError options.field, 'missingType', [type]
  
  ###*
  Validates that `value` is a boolean.  Adds an error if `value` is present but
  not of type boolean.
  @method booleanType
  @param value the value to validate
  @param {Object} options a validation configuration object with an extra `is`
  member to specify type, for example:
      {field: 'title', validate: 'type', is: 'boolean'}
  ###
  booleanType: (value, options) -> @addError(options.field, 'booleanType') if (((typeof value) != 'boolean') and (value != null and value != undefined))
  
  ###*
  Validates that `value` is a string.  Adds an error if `value` is present but
  not of type string.
  @method stringType
  @param value the value to validate
  @param {Object} options a validation configuration object with an extra `is`
  member to specify type, for example:
      {field: 'title', validate: 'type', is: 'string'}
  ###
  stringType: (value, options) -> @addError(options.field, 'stringType') if (((typeof value) != 'string') and  (value != null and value != undefined))
  
  ###*
  Validates that `value` is a number.  Adds an error if `value` is present but
  not of type number.
  @method numberType
  @param value the value to validate
  @param {Object} options a validation configuration object with an extra `is`
  member to specify type, for example:
      {field: 'title', validate: 'type', is: 'number'}
  ###
  numberType: (value, options) -> @addError(options.field, 'numberType') if (((typeof value) != 'number') and  (value != null and value != undefined))
  
  ###*
  Validates that `value` is a number.  Adds an error if `value` is present but
  not of type number.
  @method floatType
  @param value the value to validate
  @param {Object} options a validation configuration object with an extra `is`
  member to specify type, for example:
      {field: 'title', validate: 'type', is: 'float'}
  ###
  floatType: (value, options) -> @addError(options.field, 'floatType') if (((typeof value) != 'number') and  (value != null and value != undefined))
  
  ###*
  Validates that `value` is a whole number.  Adds an error if `value` is present
  but not of a whole number.
  @method integerType
  @param value the value to validate
  @param {Object} options a validation configuration object with an extra `is`
  member to specify type, for example:
      {field: 'title', validate: 'type', is: 'integer'}
  ###
  integerType: (value, options) ->
    if (value != null and value != undefined)
      if !(((typeof value) == 'number') and (value.toString().indexOf('.') == -1))
        @addError options.field, 'integerType'
  
  ###*
  **UNIMPLEMENTED***
  Validates that `value` is a data.
  @method dateType
  @beta
  @param value the value to validate
  @param {Object} options a validation configuration object with an extra `is`
  member to specify type, for example:
      {field: 'title', validate: 'type', is: 'date'}
  ###
  dateType: (value, options) ->
    # TODO
  
  ###*
  **UNIMPLEMENTED***
  Validates that `value` is a time.
  @method timeType
  @beta
  @param value the value to validate
  @param {Object} options a validation configuration object with an extra `is`
  member to specify type, for example:
      {field: 'title', validate: 'type', is: 'time'}
  ###
  timeType: (value, options) ->
    # TODO

# Superclass interface for transient storage mechanisms such as cookies and/or
# expiring local storage.
class AP.utility.TransientStore
  namespace: 'ap' # appended to all keys
  expiresAfter: 7 # default expires after, in days
  _data: null

  constructor: (options = {}) ->
    @namespace = options?.namespace or @namespace
    @expiresAfter = options?.expiresAfter or @expiresAfter
    @_data = {}

  # override the following three methods in subclasses
  getFromUnderlayingStorage: (qualifiedKey) ->
    @_data[qualifiedKey]

  setToUnderlayingStorage: (qualifiedKey, value, expirationDate) ->
    @_data[qualifiedKey] = value

  removeFromUnderlayingStorage: (qualifiedKey) ->
    delete @_data[qualifiedKey]

  encodeValue: (value) ->
    encoded = JSON.stringify([value])
    AP.utility.Base64.encode encoded

  decodeValue: (value) ->
    decoded = AP.utility.Base64.decode value if value
    try
      decoded = JSON.parse decoded
    catch error
      # pass
    decoded?[0]
  
  getKeyString: (key) ->
    strKey = @encodeValue key
    strKey
  
  getQualifiedKey: (key) ->
    strKey = @getKeyString key
    "#{@namespace}-#{strKey}"

  getQualifiedExpireKey: (key) ->
    strKey = @getKeyString key
    "#{@namespace}-expire-#{strKey}"

  getExpirationDate: (days) ->
    d = new Date()
    d.setTime d.getTime() + (days * 86400000)
    d
  
  get: (key) ->
    qKey = @getQualifiedKey key
    expireKey = @getQualifiedExpireKey key
    record = @getFromUnderlayingStorage qKey
    expire = parseInt(@decodeValue(@getFromUnderlayingStorage(expireKey)), 10) if @getFromUnderlayingStorage(expireKey)
    if _.isNumber(expire) and (expire <= Date.now())
      @remove key
      record = @getFromUnderlayingStorage qKey
    @decodeValue record

  set: (key, value, expiresAfter) ->
    qKey = @getQualifiedKey key
    expireKey = @getQualifiedExpireKey key
    expirationDate = @getExpirationDate(expiresAfter or @expiresAfter)
    @setToUnderlayingStorage qKey, @encodeValue(value), expirationDate
    @setToUnderlayingStorage expireKey, @encodeValue(expirationDate.getTime()), expirationDate

  remove: (key) ->
    qKey = @getQualifiedKey key
    expireKey = @getQualifiedExpireKey key
    @removeFromUnderlayingStorage qKey
    @removeFromUnderlayingStorage expireKey

class AP.utility.TransientCookieStore extends AP.utility.TransientStore
  @supported: (->
    supported = window.document.cookie?
    # test for cookie support by setting and getting a cookie
    if supported
      key = _.uniqueId 'ap-cookie-support-test'
      value = 'success'
      AP.utility.Cookie.set key, value
      actualValue = AP.utility.Cookie.get key
      supported = false if value != actualValue
    supported
  )()
  
  getFromUnderlayingStorage: (qualifiedKey) ->
    value = super
    value = AP.utility.Cookie.get qualifiedKey if AP.utility.TransientCookieStore.supported
    value
  
  setToUnderlayingStorage: (qualifiedKey, value, expirationDate) ->
    super
    AP.utility.Cookie.set qualifiedKey, value, expirationDate if AP.utility.TransientCookieStore.supported
  
  removeFromUnderlayingStorage: (qualifiedKey) ->
    super
    AP.utility.Cookie.del qualifiedKey if AP.utility.TransientCookieStore.supported

class AP.utility.TransientLocalStore extends AP.utility.TransientStore
  @supported: window.localStorage?
  storage: window.localStorage
  
  getFromUnderlayingStorage: (qualifiedKey) ->
    value = super
    value = @storage.getItem qualifiedKey if AP.utility.TransientLocalStore.supported
    value
  
  setToUnderlayingStorage: (qualifiedKey, value, expirationDate) ->
    super
    @storage.setItem qualifiedKey, value if AP.utility.TransientLocalStore.supported
  
  removeFromUnderlayingStorage: (qualifiedKey) ->
    super
    @storage.removeItem qualifiedKey if AP.utility.TransientLocalStore.supported

class AP.utility.TransientLargeLocalStore extends AP.utility.TransientStore
  @supported: window.LargeLocalStorage?
  storage: null
  storageCapacity: 64 * 1024 * 1024 # request capacity in bytes
  storageName: 'large-local-storage' # name for underlaying storage

  constructor: ->
    super
    if AP.utility.TransientLargeLocalStore.supported
      @storage = new LargeLocalStorage
        size: @storageCapacity
        name: "#{@namespace}-#{@storageName}"

  getFromUnderlayingStorage: (qualifiedKey) ->
    if @storage? and AP.utility.TransientLargeLocalStore.supported
      @storage.initialized.then => @storage.getContents qualifiedKey
    else
      super

  setToUnderlayingStorage: (qualifiedKey, value, expirationDate) ->
    if @storage? and AP.utility.TransientLargeLocalStore.supported
      @storage.initialized.then => @storage.setContents qualifiedKey, value
    else
      super

  removeFromUnderlayingStorage: (qualifiedKey) ->
    if @storage? and AP.utility.TransientLargeLocalStore.supported
      @storage.initialized.then => @storage.rm qualifiedKey
    else
      super

  get: (key, options={}) ->
    qKey = @getQualifiedKey key
    expireKey = @getQualifiedExpireKey key
    callback = (value) ->
      if value?
        # there is a value:  success callback
        options.success value if _.isFunction options.success
      else if _.isFunction options.error
        # there is no value:  error callback
        options.error()
    if @storage? and (_.isFunction options.success or _.isFunction options.error)
      @storage?.initialized.then =>
        @getFromUnderlayingStorage(qKey).then (record) =>
          @getFromUnderlayingStorage(expireKey).then (expireRecord) =>
            expire = +@decodeValue(expireRecord) if expireRecord
            if _.isNumber(expire) and (expire <= Date.now())
              @remove key
              record = null
            value = @decodeValue record
            callback(value)
    else
      callback(super)

AP.auth ?= {}


###*
Provides methods for user authentication and deauthentication.

To login (Coffeescript):
@example
    AP.auth.Authentication.login
      username: 'johndoe'
      password: 'doe123'
    
    AP.auth.Authentication.isAuthenticated()
    # true

To logout:
@example
    AP.auth.Authentication.logout()
    
    AP.auth.Authentication.isAuthenticated()
    # false

@module AP
@submodule auth
@class Authentication
@static
###
class AP.auth.Authentication
  _.extend @, Backbone.Events
  
  # if server ever responds with 401, assume the session expired
  $.ajaxSetup
    complete: _.debounce ((xhr, result) => @destroySession() if xhr.status == 401 and result == 'error'), 150
  
  
  
  ###*
  Custom header to send/retrieve the session ID when using CORS.
  @private
  @property _authSessionIdHeaderName
  @type String
  ###
  @_authSessionIdHeaderName: 'X-Session-Id'
  
  ###*
  Transient storage instance for persisting session data.
  @private
  @property store
  @type AP.utility.TransientStore
  ###
  @store: if AP.utility.TransientLocalStore.supported then new AP.utility.TransientLocalStore(namespace: 'ap-auth') else new AP.utility.TransientCookieStore(namespace: 'ap-auth')
  
  ###*
  Executes login request with passed `credentials`.
  @method login
  @static
  @param {Object} credentials the user credentials
  ###
  @login: (credentials) ->
    if !@isAuthenticated()
      @authenticate credentials
  
  ###*
  Executes logout request.
  @method logout
  @static
  ###
  @logout: ->
    if @isAuthenticated()
      @deauthenticate()
  
  ###*
  @method isAuthenticatable
  @static
  @return {Boolean} `true` if authentication is enabled
  ###
  @isAuthenticatable: -> !!@authenticationSettings
  
  ###*
  @method isAuthenticated
  @static
  @return {Boolean} `true` if a user is logged-in
  ###
  @isAuthenticated: -> !!(@getAuthSessionData() and @getAuthSessionId())
  
  ###*
  Performs authentication request with HTTP basic auth.  Upon a successful
  login the user object returned by the API is stored for later use.
  @method authenticate
  @static
  @param {Object} credentials user credentials object, for example:
  `{"username": "johndoe", "password": "doe123"}`.
  ###
  @authenticate: (credentials) ->
    AP = window.AP
    settings = @getAuthenticationSettings()
    $.ajax
      url: settings.authentication_url #+ '.json'
      type: 'POST'
      dataType: 'json'
      data: credentials
      beforeSend: (request, settings) =>
        baseUrl = AP.utility.Url.parseUrl AP.baseUrl
        requestUrl = AP.utility.Url.parseUrl settings.url
        hasNoRequestServer = !(requestUrl.host and requestUrl.protocol)
        isRequestUrlSameAsBaseUrlServer =
          (
            (baseUrl.protocol == requestUrl.protocol) and
            (baseUrl.host == requestUrl.host) and
            (baseUrl.port == requestUrl.port)
          ) or hasNoRequestServer
        if isRequestUrlSameAsBaseUrlServer
          # send the auth credentials
          request.setRequestHeader 'Authorization', @makeHTTPBasicAuthHeader(credentials)
        # point the request to the proper server
        if !AP.useMockServer and AP.baseUrl and hasNoRequestServer
          # if no host or protocol, add the base URL
          _.extend settings,
            crossDomain: true
            url: "#{AP.baseUrl}#{settings.url}"
            xhrFields: _.extend {}, settings.xhrFields, {withCredentials: true}
      success: (response, status, xhr) =>
        # save auth session data into store
        if response
          @store.set @getAuthSessionDataKey(), response, 7
        # save auth session ID into store
        sessionId = xhr.getResponseHeader @getAuthSessionIdHeaderName()
        if !sessionId and settings.session_id_field?
          sessionId = response?[settings.session_id_field]
        if sessionId
          @store.set @getAuthSessionIdKey(), sessionId, 7
        # successful login requires auth session data and an auth session ID
        if response and sessionId
          ###*
          @event 'auth:authenticated'
          An authenticated event is triggered after a successful login.
          ###
          @trigger 'auth:authenticated'
        else
          @trigger 'auth:error'
      error: =>
        ###*
        @event 'auth:error'
        An auth error event is triggered if a login or logout fails for
        any reason.
        ###
        @trigger 'auth:error'
  
  ###*
  Performs deauthentication request.  Upon a successful logout, stored user data
  is removed.
  @method deauthenticate
  @static
  ###
  @deauthenticate: () ->
    AP = window.AP
    settings = @getAuthenticationSettings()
    $.ajax
      url: settings.deauthentication_url #+ '.json'
      type: 'POST'
      dataType: 'text'
      beforeSend: (request, settings) =>
        baseUrl = AP.utility.Url.parseUrl AP.baseUrl
        requestUrl = AP.utility.Url.parseUrl settings.url
        hasNoRequestServer = !(requestUrl.host and requestUrl.protocol)
        isRequestUrlSameAsBaseUrlServer =
          (
            (baseUrl.protocol == requestUrl.protocol) and
            (baseUrl.host == requestUrl.host) and
            (baseUrl.port == requestUrl.port)
          ) or hasNoRequestServer
        if isRequestUrlSameAsBaseUrlServer
          # send the session ID with the deauthentication request
          authSessionIdHeader = @getAuthSessionIdHeaderName()
          authSessionId = @getAuthSessionId()
          request.setRequestHeader(authSessionIdHeader, authSessionId) if authSessionId
        # point the request to the proper server
        if !AP.useMockServer and AP.baseUrl and hasNoRequestServer
          # if no host or protocol, add the base URL
          _.extend settings,
            crossDomain: true
            url: "#{AP.baseUrl}#{settings.url}"
            xhrFields: _.extend {}, settings.xhrFields, {withCredentials: true}
      complete: (response) => @destroySession()
  
  ###*
  Destroys session by deleting data in auth store.
  @private
  @method destroySession
  @static
  ###
  @destroySession: ->
    # delete auth data
    @store.remove @getAuthSessionDataKey()
    @store.remove @getAuthSessionIdKey()
    ###*
    @event auth:deauthenticated
    A deauthenticated event is triggered after the session is destroyed.
    ###
    @trigger 'auth:deauthenticated'
  
  ###*
  Returns the name of the custom session ID header.
  @method getAuthSessionIdHeaderName
  @static
  ###
  @getAuthSessionIdHeaderName: -> @_authSessionIdHeaderName
  
  ###*
  Builds a base-URL-specific auth key.  Since multiple apps may
  sometimes be served from the same domain, auth keys must include the name
  of the base URL (API server) in the key name for uniqueness.
  @private
  @method getAuthSessionDataKey
  @static
  @return {String} auth store key, unique by base URL
  ###
  @getAuthSessionDataKey: ->
    baseName = 'session'
    baseUrl = AP.baseUrl.replace(/[^a-zA-Z\-0-9]/g, '') if AP.baseUrl
    if baseUrl then "#{baseName}-#{baseUrl}" else baseName
  
  ###*
  Builds a key name from `getAuthSessionDataKey` with `-session-id` appended.
  @private
  @static
  @method getAuthSessionIdKey
  @return {String} auth session ID key name
  ###
  @getAuthSessionIdKey: -> "#{@getAuthSessionDataKey()}-id"
  
  ###*
  Returns the auth session data (a user) from auth store if logged in.
  @method getAuthSessionData
  @static
  @return {Object/null} the authenticated user object
  ###
  @getAuthSessionData: ->
    @store.get @getAuthSessionDataKey()
  
  ###*
  Returns the lookup field value (username) of the currently logged-in user.
  @return {Object/null} the authenticated user's lookup field value (username)
  ###
  @getUsername: ->
    settings = @getAuthenticationSettings()
    credentials = @getAuthSessionData()
    credentials?[settings?.lookup_field]
  
  ###*
  Returns the role(s) of the currently logged-in user.
  @return {Object/null} the authenticated user's role(s)
  ###
  @getUserRole: ->
    settings = @getAuthenticationSettings()
    credentials = @getAuthSessionData()
    credentials?[settings?.role_field]
  
  ###*
  Returns the auth ID from auth store.
  @private
  @static
  @method getAuthSessionId
  @return {String/null} the current session ID
  ###
  @getAuthSessionId: ->
    data = @store.get @getAuthSessionIdKey()
  
  ###*
  @private
  @static
  @method getAuthenticationSettings
  @return {Object/null} the authenticatable object if one is specified.
  Otherwise null.
  ###
  @getAuthenticationSettings: -> @authenticationSettings or null
  
  ###*
  @private
  @static
  @method getAuthenticatableObject
  @return {Object/null} the model specified as the authenticatable object if one
  is specified.  Otherwise null.
  ###
  @getAuthenticatableObject: ->
    window.AP.getActiveApp().getModel(@getAuthenticationSettings()?.object_definition_id)
  
  ###*
  Builds a Base64-encoded HTTP basic auth header for use in an
  authentication request.
  @private
  @static
  @method makeHTTPBasicAuthHeader
  @param {Object} credentials the user credentials
  @return {String} Base-64 encoded HTTP basic auth header with user credentials
  ###
  @makeHTTPBasicAuthHeader: (credentials) ->
    settings = @getAuthenticationSettings()
    lookup = credentials[settings.lookup_field]
    match = credentials[settings.match_field]
    "Basic #{AP.utility.Base64.encode [lookup, match].join(':')}"

AP.auth ?= {}


###*
Authorizes arbitrary objects against the currently logged-in user (see
`AP.auth.Authentication`).  Any object may be made permission-based by adding
an auth rules field.  If the currently logged-in user has _any role_ specified
in the rules array, it is considered authorized.

Example arbitrary permission-based object (Coffeescript):
@example
    myObject1 =
      member1: 'foo'
      rules: [{roles: 'manager'}, {roles: 'admin'}]
    # authorized if logged-in user has _either_ `manager` _or_ `admin` roles
    
    myObject2 =
      member: 'bar'
      rules: [{roles: 'manager,admin'}]
    # authorized if logged-in user has both `manager` and `admin` roles

Example usage (Coffeescript):
@example
    AP.auth.Authorization.isAuthorized(myObject1.rules)
    AP.auth.Authorization.isAuthorized(myObject2.rules)

@module AP
@submodule auth
@class Authorization
@static
###
class AP.auth.Authorization
  ###*
  @method isAuthorized
  @static
  @param {String} rules array of rule objects
  @return {Boolean} `true` if logged-in user has any role in at least one
  rule _or_ there are no rules
  ###
  @isAuthorized: (rules) ->
    return true if !rules? or rules.length == 0
    @_passesAnyRule(rules)
  
  ###*
  @private
  @method _passesAnyRule
  @static
  @param {String} rules array of rule objects
  @return {Boolean} `true` if logged-in user has any role in at least
  one rule
  ###
  @_passesAnyRule: (rules) ->
    for rule in rules
      return true if @_passesRule(rule)
    false
  
  ###*
  @private
  @method _passesRule
  @static
  @param {String} rule rule object
  @return {Boolean} `true` if logged-in user has any roles in rule object or
  rule has no roles specified
  ###
  @_passesRule: (rule) ->
    @_ruleHasNoRoles(rule) or @_hasAnyRole(rule.roles)
  
  ###*
  @private
  @static
  @method _ruleHasNoRoles
  @param {String} rule rule object
  @return {Boolean} `true` if rule has no `roles` field
  ###
  @_ruleHasNoRoles: (rule) -> !rule.hasOwnProperty('roles')
  
  ###*
  @private
  @static
  @method _hasAnyRole
  @param {String} roles_string string containing comma-separated role names
  @return {Boolean} `true` if logged-in user has any role in the roles string
  ###
  @_hasAnyRole: (roles_string) ->
    user_roles = @_getRoles()
    for role in roles_string.split(',')
      return true if user_roles.indexOf($.trim(role)) >= 0
    # if roles string is empty, than user is considered to have a matching role
    # simple by being logged in
    if !roles_string and AP.auth.Authentication.isAuthenticated()
      return true
    false
  
  ###*
  @private
  @static
  @method _getRoles
  @return {String[]} array of roles for the currently logged-in user.  Returns
  an empty array if no user is logged in.
  ###
  @_getRoles: ->
    authSettings = AP.auth.Authentication.getAuthenticationSettings()
    rolesField = authSettings.role_field
    data = AP.auth.Authentication.getUserRole()
    roles = if data? then data.split(',') else []
    roles.map (x) -> $.trim(x)
    roles

###*
Base model class.  In addition to the standard methods provided by the
[BackboneJS model class](http://backbonejs.org/#Model), this base model
implements full validations support.

This model should be subclassed, not used directly.  For example (Coffeescript):
@example
    class Person extends AP.model.Model
      @modelId: 'person'
      name: 'Person'
      urlRoot: '/person/'
      fieldDefinitions: [
        name: 'name'
        type: 'string'
      ,
        name: 'age'
        type: 'integer'
      ]
      validations: [
        field: 'name'
        validate: 'type'
        is: 'string'
      ,
        field: 'name'
        validate: 'required'
      ,
        field: 'age'
        validate: 'type'
        is: 'integer'
      ]

For full model usage documentation,
refer to [Backbone JS](http://backbonejs.org/#Model).

@module AP
@submodule model
@class Model 
@extends Backbone.Model
###
class AP.model.Model extends Backbone.Model
  ###*
  An internal reference to initialized relationship instances for this
  model instance.
  @property _relationships
  @type AP.relationship.Relationship[]
  @private
  ###
  _relationships: null
  
  ###*
  An internal reference to the validator instance used by the model instance.
  @property _validator
  @type AP.utility.Validator
  @private
  ###
  _validator: null
  
  ###*
  An array of validation configurations.  For more information about
  validations, refer to
  the {@link AP.utility.Validator Validator documentation}.
  @property validations
  @type Object[]
  ###
  validations: []
  
  initialize: ->
    @initializeRelationships()
    @initializeValidations()
    @on 'sync', => @constructor.trigger?.apply @constructor, ['sync'].concat _.toArray(arguments)
  
  initializeRelationships: ->
    @_relationships = []
    _.each @relationshipDefinitions, (definition) =>
      relationship = new AP.relationship[definition.type] @, definition
      @_relationships.push relationship
  
  initializeValidations: ->
    @validations = _.clone(@validations)
    @_validator = new AP.utility.Validator
  
  ###*
  Retrieves the initialized relationship instance of the given name.
  @method getRelationship
  @param {String} name the name of the relationship
  @return {AP.relationship.Relationship} matching relationship instance
  ###
  getRelationship: (name) -> _.where(@_relationships, {name: name})[0]
  
  ###*
  Performs a `fetch` on the specified relationship.
  @method fetchRelated
  @param {String} name the name of the relationship
  @param {Function} callback called when fetching completes
  ###
  fetchRelated: (name, callback) -> @getRelationship(name)?.fetch(callback)
  
  ###*
  Appends `.json` to the end of the default URL.
  @method url
  @return {String} the URL for this model instance
  ###
  url: ->
    "#{super}.json"
  
  ###*
  Simple proxy to the model's underlaying `fetch` method inherited
  from Backbone JS `Model`.
  @method reload
  ###
  reload: -> @fetch.apply @, arguments
  
  ###*
  Simple override of the built-in Backbone.js `destroy` method to enable
  `before_delete` event handlers.
  @method destroy
  ###
  destroy: ->
    ###*
    @event 'before_delete'
    Triggered on a model instance immediately before being destroyed.
    ###
    @trigger 'before_delete'
    super
  
  ###*
  Simple proxy to the model's underlaying `destroy` method inherited
  from Backbone JS `Model`.
  @method delete
  ###
  delete: -> @destroy.apply @, arguments
  
  ###*
  Simple override of the built-in Backbone.js `set` method to enable
  `before_change` event handlers.
  @method set
  ###
  set: (key, val, options = {}) ->
    # Handle both `"key", value` and `{key: value}` -style arguments.
    if _.isObject key
      attrs = key
      options = val or {}
    else
      attrs = {}
      attrs[key] = val
    if attrs
      ###*
      @event 'before_change'
      Triggered on a model instance immediately before being changed.
      ###
      @trigger 'before_change', @, attrs
    super
  
  ###*
  Simple override of the built-in Backbone.js `save` method to enable
  `before_save` event handlers.
  @method save
  ###
  save: ->
    ###*
    @event 'before_save'
    Triggered on a model instance immediately before being saved.
    ###
    @trigger 'before_save'
    super
  
  ###*
  Validates the model instance and returns any errors reported by the instance's
  validator instance.
  @method errors
  @return {String[]} the errors array reported by the validator
  instance's {@link AP.utility.Validator#errors errors method}.
  ###
  errors: ->
    @validate()
    @_validator.errors()
  
  ###*
  Validates the model instance and returns `true` if the instance is valid,
  otherwise `false`.
  @method isValid
  @return {Boolean} the value reported by the validator
  instance's {@link AP.utility.Validator#isValid isValid method}.
  ###
  isValid: ->
    @validate()
    @_validator.isValid()
  
  ###*
  Copies the instance data (or optional `values` argument) and the instance
  validations into the {@link #_validator validator instance}.  Returns
  `undefined` if values are valid, otherwise returns
  an {@link #errors errors array}.
  @method validate
  @param {Object} values optional hash of field name/value pairs to validate 
  against this instance's validations.  Pass `values` to validate arbitrary
  data instead of instance data.
  @return {String[]/undefined} if valid, returns `undefined` as expected by
  the underlaying [Backbone JS model class](http://backbonejs.org/#Model).
  If invalid, returns the {@link #errors errors array}.
  ###
  validate: (values) ->
    # get the latest data and validations
    @_validator.data = _.extend({}, values or @attributes)
    @_validator.validations = @validations.slice()
    # Return undefined if validation passes.
    # Backbone treats any value, including "true", as a validation error.
    if @_validator.validate()
      undefined
    else
      @_validator.errors()
  
  ###*
  Recurses into nested models and calls toJSON.
  @method toJSON
  @return {Object} JSON representation of this model instance
  ###
  toJSON: ->
    json = super
    for key, value of json
      json[key] = value.toJSON() if _.isFunction(value?.toJSON)
    json

###*
Base relationship class.  Provides attributes and simple initialization common
to all relationships.  This class should not be used directly but subclassed.

Three relationship types are provided for convience.  Please refer to the
relationship documentation pages for more information:

- {@link AP.relationship.BelongsTo BelongsTo}
- {@link AP.relationship.HasMany HasMany}
- {@link AP.relationship.HasOne HasOne}

Relationships should not be instantiated directly.  Please see
{@link AP.model.Model#relationshipDefinitions} for more information on
declaring relationships.

@module AP
@submodule relationship
@class Relationship
@extends Backbone.Events
###
class AP.relationship.Relationship
  # mixin Backbone events
  _.extend @::, Backbone.Events
  
  ###*
  The owning model instance of this relationship.
  @property owner
  @type AP.model.Model
  ###
  owner: null
  
  ###*
  The field name for this relationship.  A relationship inserts a field into the
  owner model instance with a default value of {@link #getDefault}.
  The field name is preferably a variant of {@link #foreignKey}.  For instance,
  if `foreignKey` is `user_id`, then `name` should be `user` (or `users` for
  has-many relationships).
  @property name
  @type String
  ###
  name: null
  
  ###*
  Field name where the value of the relationship may be found.  In belongs-to
  relationships, `foreignKey` is found on the owner model instance.  In has-many
  and has-one relationships, `foreignKey` is found on the target model
  instance(s).  See {@link #model}.
  @property foreignKey
  @type String
  ###
  foreignKey: null
  
  ###*
  A string representing the class name of a model or a proper model class.  The
  model class is the target for this relationship.  Related instances must be of
  this model.
  @property model
  @type String/AP.model.Model
  ###
  model: null
  
  ###*
  A string representing the class name of a collection or a proper collection
  class.  The collection class is used by this relationship to store the related
  instance(s).  On initialization of this relationship, the collection is
  instantiated and this property becomes a reference to that instance.
  @property collection
  @type String/AP.collection.Collection
  ###
  collection: null
  
  constructor: -> @initialize.apply @, arguments
  
  initialize: (owner, @options={}) ->
    @app = window.AP.getActiveApp?()
    @owner = owner or @owner
    @name = @options.name or @name
    @foreignKey = @options.foreignKey or @foreignKey
    @initializeModel()
    @initializeCollection()
    @initializeDefault()
    @initializeEvents()
  
  initializeModel: ->
    @model = @options.model or @model
    @model = @app?.getModel(@model) or @model
  
  initializeCollection: ->
    @collection = @options.collection or @collection
    @collection = new (@app?.getCollection(@collection) or @collection)
  
  initializeEvents: ->
    @listenTo @collection, 'add', @onCollectionAdd
    @listenTo @collection, 'remove', @onCollectionRemove
    @listenTo @collection, 'sync', @onCollectionSync
    @listenTo @collection, 'change', @onRelatedChange
  
  initializeDefault: -> @owner.set @name, @getDefault(), {silent: true}
  
  ###*
  Handles the addition of instances into {@link #collection}.  Subclasses should
  implement this method if necessary.
  @method onCollectionAdd
  @param {AP.model.Model} record a model instance added to the collection
  ###
  onCollectionAdd: (record) ->
    # pass
  
  ###*
  Handles the addition of instances into {@link #collection}.  Subclasses should
  implement this method if necessary.
  @method onCollectionRemove
  @param {AP.model.Model} record a model instance added to the collection
  ###
  onCollectionRemove: (record) ->
    # pass
  
  ###*
  Called whenever {@link #collection} is synced with the server.  Subclasses
  should implement this method if necessary.
  @method onCollectionSync
  ###
  onCollectionSync: ->
    # pass
  
  ###*
  Called whenever an instance in {@link #collection} is changed.  By default,
  this method triggers a change event on the owner's {@link #name} field, the
  field generated by the relationship.
  @method onRelatedChange
  ###
  onRelatedChange: -> @owner.trigger "change:#{@name}"
  
  ###*
  Returns a default value for the generated {@link #name} field on
  {@link #owner}.  The generated field is created using the default value as
  soon as the relationship is initialized.
  @method getDefault
  @return {Object} default value for generated field on owner
  ###
  getDefault: -> null
  
  ###*
  Returns a hash of parameters passed to the {@link #collection} `query` method.
  @method getQuery
  @return {Object} parameters passed to collection's query method
  ###
  getQuery: -> {}
  
  ###*
  Query the underlaying {@link #collection} and execute `callback` upon success.
  The fetch method gets the model instance(s) for this relationship from the
  server.  Depending on the relationship type, the value of the {@link #name}
  field may be a single model instance or the {@link #collection} itself.  No
  default implementation of this method is provided.  Subclasses should provide
  an implementation.
  @method fetch
  @param {Function} callback function to execute upon fetch success.
  ###
  fetch: (callback) -> null

###*
A belongs-to relationship is one where the owner model instance is related to
no more than one other model instance.  In this scheme, the relationship
information is stored in a foreign key on the owner model.  The related instance
is stored in a generated field {@link #name} once fetched.

For example, if the foreign key is `user_id` and the relationship name is `user`
then the related instance may be obtained by calling:
@example
    ownerInstance.get('user')
    // set related instance
    ownerInstance.set('user', userInstance)
    // or set foreign key
    ownerInstance.set('user_id', 4)
    // setting the foreign key directly will null the related instance:
    ownerInstance.get('user') == null // evaluates to true

A has-one relationship is similar, except the relationship information is stored
in a foreign key on the target model, not the owner.  See
{@link AP.relationship.HasOne} for more information about has-one relationships.

Relationships should not be instantiated directly.  Please see
{@link AP.model.Model#relationshipDefinitions} for more information on
declaring relationships.

@module AP
@submodule relationship
@class BelongsTo
@extends AP.relationship.Relationship
###
class AP.relationship.BelongsTo extends AP.relationship.Relationship
  initialize: ->
    super
    @listenTo @owner, "change:#{@foreignKey}", @onForeignKeyChange
    @listenTo @owner, "change:#{@name}", @onFieldForRelatedInstanceChange
  
  ###*
  Sets the {@link #name} generated field on the owner model to the first model
  instance in the collection after syncing.
  @method onCollectionSync
  ###
  onCollectionSync: -> @owner.set @name, @collection.first()
  
  ###*
  Called whenever the owner instance's {@link #foreignKey} field is changed.
  If the foreign key is different than the related instance in the generated
  {@link #name} field, the {@link #name} field is set to null.  To obtain the
  related instance, the relationship must be fetched again.
  @method onForeignKeyChange
  ###
  onForeignKeyChange: ->
    if @owner.get(@foreignKey) != @owner.get(@name)?.get(@model::idAttribute)
      @owner.set @name, null
  
  ###*
  Called whenever the owner instance's {@link #name} field is changed.  If the
  ID of the related instance is different than the value of {@link #foreignKey},
  the foreign key field is updated with the related instance's ID.
  @method onFieldForRelatedInstanceChange
  ###
  onFieldForRelatedInstanceChange: ->
    relatedId = @owner.get(@name)?.get(@model::idAttribute)
    if relatedId and (@owner.get(@foreignKey) != relatedId)
      @owner.set @foreignKey, relatedId
  
  ###*
  Returns a query used to obtain the related instance from the server.
  @method getQuery
  @return {Object} parameters used to query server for the related instance
  ###
  getQuery: ->
    query = super
    query[@model::idAttribute] = @owner.get(@foreignKey)
    query
  
  ###*
  Querys the server for related instances.
  @method fetch
  @param {Function} callback function executed upon query success; called with
  one argument:  the related instance (if any)
  ###
  fetch: (callback) ->
    @collection.query @getQuery(),
      reset: true
      success: => callback(@owner, @collection.first()) if _.isFunction(callback)

###*
A has-many relationship is one where the owner model instance is related to
any number of related instances.  In this scheme, the relationship
information is stored in a foreign key on the related instance(s).  The related
instances are stored in the {@link #collection} on a generated field
{@link #name} once fetched.

Relationships should not be instantiated directly.  Please see
{@link AP.model.Model#relationshipDefinitions} for more information on
declaring relationships.

@module AP
@submodule relationship
@class HasMany
@extends AP.relationship.Relationship
###
class AP.relationship.HasMany extends AP.relationship.Relationship
  initialize: ->
    super
    @listenTo @collection, "reset", @onCollectionReset
    @listenTo @collection, "change:#{@foreignKey}", @onRelatedInstanceForeignKeyChange
  
  ###*
  Sets the {@link #foreignKey} of the related instance to the ID of the owner
  instance when added to the collection.  Triggers a change event on the
  generated relationship field {@link #name}.
  @method onCollectionAdd
  @param {Object} record the added model instance
  ###
  onCollectionAdd: (record) ->
    record.set @foreignKey, @owner.get(@owner.idAttribute)
    @owner.trigger "change:#{@name}"
  
  ###*
  Unset the {@link #foreignKey} of the related instance when removed from
  the collection.  Triggers a change event on the generated relationship
  field {@link #name}.
  @method onCollectionRemove
  @param {Object} record the removed model instance
  ###
  onCollectionRemove: (record) ->
    if record.get(@foreignKey) == @owner.get(@owner.idAttribute)
      record.set @foreignKey, null
    @owner.trigger "change:#{@name}"
  
  ###*
  Triggers a change event on the generated relationship field {@link #name} when
  the collection is reset.  See {@link #filterCollection}.
  @method onCollectionReset
  ###
  onCollectionReset: -> @owner.trigger "change:#{@name}"
  
  ###*
  Calls {@link #filterCollection} whenever the foreign key field of a related
  instance is changed.
  @method onRelatedInstanceForeignKeyChange
  ###
  onRelatedInstanceForeignKeyChange: -> @filterCollection()
  
  ###*
  Removes any stale related instances from the collection.  Stale instances are
  instances with foreign keys that no longer refer to the owner instance.
  See {@link #onCollectionReset}.
  @method filterCollection
  ###
  filterCollection: ->
    whereClause = {}
    whereClause[@foreignKey] = @owner.get(@owner.idAttribute)
    filtered = @collection.where(whereClause)
    @collection.reset filtered, {reset: true}
  
  ###*
  Returns the default value of the generated field {@link #name}.  For many-to-
  many relationships, the value is always the {@link #collection} instance.
  @method getDefault
  @return {AP.collection.Collection} the collection instance declared
  by {@link #collection}.
  ###
  getDefault: -> @collection
  
  ###*
  Returns a query used to obtain the related instances from the server.
  @method getQuery
  @return {Object} parameters used to query server for the related instances
  ###
  getQuery: ->
    query = super
    query[@foreignKey] = @owner.get(@owner.idAttribute)
    query
  
  ###*
  Querys the server for related instances.
  @method fetch
  @param {Function} callback function executed upon query success; called with
  one argument:  the collection of related instances
  ###
  fetch: (callback) ->
    @collection.query @getQuery(),
      reset: true
      success: => callback(@owner, @collection) if _.isFunction(callback)

###*
A has-one relationship is simlar to a {@link AP.relationship.BelongsTo}
relationship except that the relationship information is stored in foreign key
fields on the related instances instead of on owner instances.

In implementation, a has-one relationship functions like has-many, except that
the value of the generated {@link #name} field is a related
{@link #model model instance} instead of a collection.

Relationships should not be instantiated directly.  Please see
{@link AP.model.Model#relationshipDefinitions} for more information on
declaring relationships.

@module AP
@submodule relationship
@class HasOne
@extends AP.relationship.HasMany
###
class AP.relationship.HasOne extends AP.relationship.HasMany
  initializeEvents: ->
    @listenTo @collection, "change:#{@foreignKey}", @onForeignKeyChange
    @listenTo @owner, "change:#{@name}", @onFieldForRelatedInstanceChange
    super
  
  ###*
  Sets the {@link #name} generated field on the owner model to the first model
  instance in the collection after syncing.
  @method onCollectionSync
  ###
  onCollectionSync: -> @owner.set @name, @collection.first()
  
  ###*
  Called whenever the related instance's {@link #foreignKey} field is changed.
  If the foreign key of the related instance referes to a different owner, then
  the {@link #name} field is set to null.  To obtain the related instance after
  the field is nulled, the relationship must be fetched again.
  @method onForeignKeyChange
  ###
  onForeignKeyChange: ->
    related = @owner.get(@name)
    if related and (related.get(@foreignKey) != @owner.get(@owner.idAttribute))
      @owner.set @name, null
  
  ###*
  Called whenever the owner instance's {@link #name} field is changed.  If the
  foreign key of the new related instance is different than the ID of the owner,
  the foreign key field of the related instance is set to the ID of the owner.
  @method onFieldForRelatedInstanceChange
  ###
  onFieldForRelatedInstanceChange: ->
    related = @owner.get(@name)
    ownerId = @owner.get(@owner.idAttribute)
    if related and (related.get(@foreignKey) != ownerId)
      related.set @foreignKey, ownerId
  
  ###*
  The default value for a has-one relationship is null like belongs-to.
  @method getDefault
  @return {Object} null
  ###
  getDefault: -> null
  
  ###*
  Querys the server for related instances.
  @method fetch
  @param {Function} callback function executed upon query success; called with
  one argument:  the related instance (if any)
  ###
  fetch: (callback) ->
    @collection.query @getQuery(),
      reset: true
      success: => callback(@owner, @collection.first()) if _.isFunction(callback)

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

###*
Similar to `AP.collection.Collection` except that query data are
optionally mapped to alternative parameter names.  Specify query fields when
request parameters have different names than model fields.

For example (Coffeescript):
@example
    class PeopleScope extends AP.collection.ScopeCollection
      @collectionId: 'people_scope'
      model: Person
      apiEndpoint: '/person/'
      extraParams:
        scope: 'scoped'
      queryFields: [
        fieldName: 'name'
        paramName: 'person_name'
      ]

@module AP
@submodule collection
@class ScopeCollection
@extends AP.collection.Collection
###
class AP.collection.ScopeCollection extends AP.collection.Collection
  ###*
  Copies `data` to new object and replaces keys which match any `queryFields`
  mapping configurations with the alternative parameter name.  For example,
  with `queryFields` `[{fieldName: 'name', paramName: 'person_name'}] and
  input object `{name: 'John', age: 35}`, output object
  is `{person_name: 'John', age: 35}`.
  @method mapQueryFieldKeys
  @param {Object} data name/value pairs to map
  @return {Object} a new object with mapped keys
  ###
  mapQueryFieldKeys: (data) ->
    '''
    Maps key names in data to equivalent param names in @queryFields if
    any match.  On match, original key names are not retained.  Returns a new
    object leaving original intact.
    '''
    mapped = {}
    for key, value of data
      paramName = (_.find(@queryFields, (field) -> field.fieldName == key) or {}).paramName
      mappedKey = paramName or key
      mapped[mappedKey] = value if value
    mapped
  
  ###*
  Fetches objects from the collection instance's URL.  All arguments are passed-
  through to {@link AP.collection.Collection#fetch}, except for `options.query`
  which is transformed first by {@link #mapQueryFieldKeys}.
  @method fetch
  @param {Object} options optional request data
  @param {Object} options.query optional query parameters are passed through
  request URL after being transformed by {@link #mapQuerParams}
  @param args... optional additional arguments passed-through
  to {@link AP.collection.Collection#fetch}
  ###
  fetch: (options, args...) ->
    options ?= {}
    query = @mapQueryFieldKeys(options.query) if options?.query
    options.query = query if query
    AP.collection.Collection.prototype.fetch.apply @, [options].concat(args)

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

###*
Provides convenience methods common to apps.  Generally, apps are
namespaces not intended for instantiation.

All apps should inherit from this class and execute setup.  It is important to
execute setup before adding members.

For example (Coffeescript):
@example
    class AppClass extends AP.Application
      @setup()

@module AP
@class Application
@static
###
class AP.Application
  ###*
  Adds static members to the class:
  
  - `name`
  - `description`
  - `models`
  - `collections`
  
  It is important to execute setup before adding members.
  @method setup
  @static
  ###
  @setup: ->
    @name = @name or ''
    @description = @description or ''
    @models = {}
    @collections = {}
    @mockServer = null
  
  ###*
  @method init
  @static
  ###
  @init: ->
    AP = window.AP
    @mockServer = new AP.utility.MockServer(@) if AP.useMockServer
    @initOfflineCache() if AP.useOfflineCache
    @initAjaxSetup()
  
  ###*
  @method initOfflineCache
  @static
  ###
  @initOfflineCache: ->
    AP = window.AP
    AP.offlineDataStore = new AP.utility.TransientLargeLocalStore
      storageName: 'ap-offline-data-store'
      storageCapacity: AP.offlineStorageCapacity
    Backbone._sync = Backbone.sync
    Backbone.sync = (method, obj, options) ->
      url = options.url or _.result obj, 'url'
      # cache only on GET
      if url and method == 'read'
        data = options.data or JSON.stringify(options.attrs or obj?.toJSON options)
        oldSuccess = options.success
        oldError = options.error
        # build cache key
        user = null
        if AP.auth.Authentication.isAuthenticated()
          user =
            username: AP.auth.Authentication.getUsername()
            role: AP.auth.Authentication.getUserRole()
        cacheKey = [AP.baseUrl, url, data, user]
        # override success and error callbacks to handle caching
        options.success = (response) =>
          AP.offlineDataStore.set cacheKey, response
          oldSuccess.apply @, arguments
        options.error = (xhr) =>
          status = +xhr.status
          if status < 400 or status >=500
            AP.offlineDataStore.get cacheKey,
              success: (cached) => oldSuccess.apply @, [cached]
              error: => oldError.apply @, arguments
          else
            oldError.apply @, arguments
      Backbone._sync.apply @, arguments
  
  ###*
  @method initAjaxSetup
  @static
  ###
  @initAjaxSetup: ->
    AP = window.AP
    $.ajaxSetup
      beforeSend: (request, settings) ->
        baseUrl = AP.utility.Url.parseUrl AP.baseUrl
        requestUrl = AP.utility.Url.parseUrl settings.url
        hasNoRequestServer = !(requestUrl.host and requestUrl.protocol)
        isRequestUrlSameAsBaseUrlServer =
          (
            (baseUrl.protocol == requestUrl.protocol) and
            (baseUrl.host == requestUrl.host) and
            (baseUrl.port == requestUrl.port)
          ) or hasNoRequestServer
        if isRequestUrlSameAsBaseUrlServer
          # send the session ID with the deauthentication request
          authSessionIdHeader = AP.auth.Authentication.getAuthSessionIdHeaderName()
          authSessionId = AP.auth.Authentication.getAuthSessionId()
          request.setRequestHeader(authSessionIdHeader, authSessionId) if authSessionId
        # point the request to the proper server
        if !AP.useMockServer and AP.baseUrl and hasNoRequestServer
          # if no host or protocol, add the base URL
          _.extend settings,
            crossDomain: true
            url: "#{AP.baseUrl}#{settings.url}"
            xhrFields: _.extend {}, settings.xhrFields, {withCredentials: true}
  
  ###*
  @method proxy
  @static
  ###
  @proxy: (fn) -> (=> fn.apply @, arguments)
  
  ###*
  Returns a model class for this application by name or model ID.
  @method getModel
  @static
  @param {String} str the name or ID of a model
  @return {AP.model.Model} a model class
  ###
  @getModel: (str) ->
    _.find @models, (val, key) -> key == str or val.modelId == str or val.name == str
  
  ###*
  Returns a collection class for this application by name or collection ID.
  @param {String} str the name or ID of a collection
  @return {AP.collection.Collection} a collection class
  @method getCollection
  @static
  ###
  @getCollection: (str) ->
    _.find @collections, (val, key) -> key == str or val.collectionId == str or val.name == str

###*
Simple namespace class for this application.

Example application look-up:
@example
    app = AP.getApp('WeatherSoapAppSdk')

Example model and collection look-ups:
@example
    modelClass = app.getModel('modelName')
    collectionClass = app.getCollection('collectionName')

@class WeatherSoapAppSdk
@extends AP.Application
@static
###
class window.WeatherSoapAppSdk extends AP.Application
  @setup()
  
  ###*
  Application name.
  @static
  @property name
  @type String
  ###
  @name: 'WeatherSoapAppSdk'
  
  ###*
  Application description.
  @static
  @property description
  @type String
  ###
  @description: ''
  
  @init: ->
    window.AP.activeAppName = 'WeatherSoapApp'
    super

###
Registers the app with the global {@link AP AP namespace}.
###
AP.registerApp WeatherSoapAppSdk, 'WeatherSoapApp'

###*
WeatherByZip model for application `WeatherSoapAppSdk`.  See
`AP.model.Model` for more information about models.

@module WeatherSoapAppSdk
@submodule models
@class WeatherByZip
@extends AP.model.Model
###
class WeatherSoapAppSdk.models.WeatherByZip extends AP.model.Model
  # mixin Backbone events on the model class
  _.extend @, Backbone.Events
  
  ###*
  The model ID may be used to look-up a model from an application class.
  @property modelId
  @type String
  @static
  ###
  @modelId: ''
  
  ###*
  The model name may be used to look-up a model from an application class.
  @property name
  @type String
  ###
  name: 'WeatherByZip'
  
  ###*
  Server requests for model instances use this URL.
  @property urlRoot
  @type String
  ###
  urlRoot: '/api/v6/weather_by_zips'
  
  ###*
  Array of field definition configurations.  Field definitions describe fields
  available on this model.
  @property fieldDefinitions
  @type Array
  ###
  fieldDefinitions: [
  
    # TODO where is the field ID?
    #id: 
    name: 'id'
    label: 'id'
    
    
    type: 'integer'
    required: false
    file_url: false
    file_type: 'Image'
  ,
  
    # TODO where is the field ID?
    #id: 
    name: 'get_city_weather_by_zip'
    label: 'get_city_weather_by_zip'
    
    
    type: 'string'
    required: false
    file_url: false
    file_type: 'Image'
  ,
  
    # TODO where is the field ID?
    #id: 
    name: 'get_city_weather_by_zip_response'
    label: 'get_city_weather_by_zip_response'
    
    
    type: 'string'
    required: false
    file_url: false
    file_type: 'Image'
  ,
  
  ]
  
  ###*
  Array of field names.  Auto keys, generally such as `id`, have their values
  filled automatically by the server.  Non-auto keys are all other fields.
  @property nonAutoKeyFields
  @type Array
  ###
  nonAutoKeyFields: [
  
  ]
  
  ###*
  Array of relationship definitions.
  @property relationshipDefinitions
  @type Array
  ###
  relationshipDefinitions: [
    
    
    
  ]
  
  ###*
  Array of validation configurations.  See `AP.model.Model` for more information
  about validations.
  @property validations
  @type Array
  ###
  validations: [
  
  
  
  
  
  
  
  ]

###*
WeatherByZipAllis a scope collection for application `WeatherSoapAppSdk`.  See
`AP.collection.ScopeCollection` for more information about scopes.

@module WeatherSoapAppSdk
@submodule collections
@class WeatherByZipAll
@extends AP.collection.ScopeCollection
###
class WeatherSoapAppSdk.collections.WeatherByZipAll extends AP.collection.ScopeCollection
  ###*
  The collection ID may be used to look-up a collection from an
  application class.
  @property collectionId
  @type String
  @static
  ###
  @collectionId: ''
  
  ###*
  The model associated with this collection.  Results returned by server
  requests for this collection are converted into instances of this model.
  @property model
  @type AP.model.Model
  ###
  model: WeatherSoapAppSdk.models.WeatherByZip
  
  ###*
  Server requests for this collection use this URL.
  @property apiEndpoint
  @type String
  ###
  apiEndpoint: '/api/v6/weather_by_zips.json'
  
  ###*
  Name/value pairs included with every server request.  Extra parameters are
  converted to URL parameters at request-time.
  @property extraParams
  @type Object
  ###
  extraParams:
    scope: 'all'
  
  ###*
  Array of query field configurations.  Query fields map model field names onto
  URL parameter names.  See `AP.collection.ScopeCollection` to learn more
  about query fields.
  @property queryFields
  @type Array
  ###
  queryFields: [
  
  ]

null
###*
WeatherByZipCountis an aggregate collection for application `WeatherSoapAppSdk`.  See
`AP.collection.AggregateCollection` to learn about about aggregates.
@module WeatherSoapAppSdk
@submodule collections
@class WeatherByZipCount
@extends AP.collection.AggregateCollection
###
class WeatherSoapAppSdk.collections.WeatherByZipCount extends AP.collection.AggregateCollection
  ###*
  The collection ID may be used to look-up a collection from an
  application class.
  @property collectionId
  @type String
  @static
  ###
  @collectionId: ''
  
  ###*
  The model associated with this collection.  Results returned by server
  requests for this collection are converted into instances of this model.
  @property model
  @type AP.model.Model
  ###
  model: WeatherSoapAppSdk.models.WeatherByZip
  
  ###*
  Server requests for this collection use this URL.
  @property apiEndpoint
  @type String
  ###
  apiEndpoint: '/api/v6/weather_by_zips.json'
  
  ###*
  Name/value pairs included with every server request.  Extra parameters are
  converted to URL parameters at request-time.
  @property extraParams
  @type Object
  ###
  extraParams:
    scope: 'count'
  
  ###*
  Array of query field configurations.  Query fields map model field names onto
  URL parameter names.  See `AP.collection.ScopeCollection` to learn more
  about query fields.
  @property queryFields
  @type Array  
  ###
  queryFields: [
  
  ]

null
###*
WeatherByZipCountExactMatchis an aggregate collection for application `WeatherSoapAppSdk`.  See
`AP.collection.AggregateCollection` to learn about about aggregates.
@module WeatherSoapAppSdk
@submodule collections
@class WeatherByZipCountExactMatch
@extends AP.collection.AggregateCollection
###
class WeatherSoapAppSdk.collections.WeatherByZipCountExactMatch extends AP.collection.AggregateCollection
  ###*
  The collection ID may be used to look-up a collection from an
  application class.
  @property collectionId
  @type String
  @static
  ###
  @collectionId: ''
  
  ###*
  The model associated with this collection.  Results returned by server
  requests for this collection are converted into instances of this model.
  @property model
  @type AP.model.Model
  ###
  model: WeatherSoapAppSdk.models.WeatherByZip
  
  ###*
  Server requests for this collection use this URL.
  @property apiEndpoint
  @type String
  ###
  apiEndpoint: '/api/v6/weather_by_zips.json'
  
  ###*
  Name/value pairs included with every server request.  Extra parameters are
  converted to URL parameters at request-time.
  @property extraParams
  @type Object
  ###
  extraParams:
    scope: 'count_exact_match'
  
  ###*
  Array of query field configurations.  Query fields map model field names onto
  URL parameter names.  See `AP.collection.ScopeCollection` to learn more
  about query fields.
  @property queryFields
  @type Array  
  ###
  queryFields: [
  
  ]

###*
WeatherByZipExactMatchis a scope collection for application `WeatherSoapAppSdk`.  See
`AP.collection.ScopeCollection` for more information about scopes.

@module WeatherSoapAppSdk
@submodule collections
@class WeatherByZipExactMatch
@extends AP.collection.ScopeCollection
###
class WeatherSoapAppSdk.collections.WeatherByZipExactMatch extends AP.collection.ScopeCollection
  ###*
  The collection ID may be used to look-up a collection from an
  application class.
  @property collectionId
  @type String
  @static
  ###
  @collectionId: ''
  
  ###*
  The model associated with this collection.  Results returned by server
  requests for this collection are converted into instances of this model.
  @property model
  @type AP.model.Model
  ###
  model: WeatherSoapAppSdk.models.WeatherByZip
  
  ###*
  Server requests for this collection use this URL.
  @property apiEndpoint
  @type String
  ###
  apiEndpoint: '/api/v6/weather_by_zips.json'
  
  ###*
  Name/value pairs included with every server request.  Extra parameters are
  converted to URL parameters at request-time.
  @property extraParams
  @type Object
  ###
  extraParams:
    scope: 'exact_match'
  
  ###*
  Array of query field configurations.  Query fields map model field names onto
  URL parameter names.  See `AP.collection.ScopeCollection` to learn more
  about query fields.
  @property queryFields
  @type Array
  ###
  queryFields: [
  
  ]

class WeatherSoapAppSdk.ExampleCustomClass
  message: null
  
  constructor: ->
    @message = 'This is a custom class.'
  
  getMessage: -> @message
