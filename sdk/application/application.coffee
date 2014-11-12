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
