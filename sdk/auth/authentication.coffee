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
