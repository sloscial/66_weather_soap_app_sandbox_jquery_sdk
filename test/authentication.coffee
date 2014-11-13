assert = chai.assert


describe 'AP.auth.Authentication', ->
  authSettings = AP.auth.Authentication.getAuthenticationSettings()
  authServer = null
  authSessionId = null
  authSessionHeader = null
  authHeaders = null
  authCreds = null
  
  # test only if application has authentication enabled
  if authSettings
    beforeEach ->
      # reset auth store
      AP.auth.Authentication.store = new AP.utility.TransientStore()
      # setup mock authentication server
      authServer = sinon.fakeServer.create()
      authSessionId = _.uniqueId 'x-session-id-'
      authCreds = id: _.uniqueId 'auth-id-'
      authCreds[authSettings.match_field] = 'password123'
      authCreds[authSettings.lookup_field] = 'user123'
      authSessionHeader = AP.auth.Authentication.getAuthSessionIdHeaderName()
      authHeaders =
        'Content-Type': 'application/json'
        'Access-Control-Allow-Origin': '*'
        'Access-Control-Expose-Headers': authSessionHeader
      authHeaders[authSessionHeader] = authSessionId
      authServer.respondWith 'POST',
        authSettings.authentication_url,
        [
          201
          authHeaders
          JSON.stringify authCreds
        ]
  
    afterEach ->
      # teardown mock authentication server
      authServer.restore()
    
    describe 'isAuthenticated()', ->
      it 'should return false before authentication', ->
        assert.isFalse AP.auth.Authentication.isAuthenticated()
      it 'should return true after authentication', ->
        AP.auth.Authentication.login authCreds
        authServer.respond()
        assert.isTrue AP.auth.Authentication.isAuthenticated()
      it 'should return false after authentication if the session ID is missing', ->
        # a missing session ID should be interpreted as being _not_ logged-in
        delete authHeaders[authSessionHeader]
        AP.auth.Authentication.login authCreds
        authServer.respond()
        assert.isFalse AP.auth.Authentication.isAuthenticated()
  
    describe 'makeHTTPBasicAuthHeader()', ->
      it 'should return base64-encoded HTTP basic auth header', ->
        assert.equal 'Basic dXNlcjEyMzpwYXNzd29yZDEyMw==', AP.auth.Authentication.makeHTTPBasicAuthHeader(authCreds)
  
    describe 'authenticate()', ->
      describe 'failure contingency', ->
        it 'shoud report user is unauthenticated when authentication is unsuccessful', ->
          authServer = sinon.fakeServer.create()
          authServer.respondWith 'POST', authSettings.authentication_url, [401, {}, '']
          assert.isFalse AP.auth.Authentication.isAuthenticated()
          AP.auth.Authentication.authenticate authCreds
          authServer.respond()
          assert.isFalse AP.auth.Authentication.isAuthenticated()
      describe 'success contingency', ->
        it 'should set "ap-auth-session" and "ap-auth-session-id" keys in auth store when authentication is successful', ->
          AP.auth.Authentication.authenticate authCreds
          authServer.respond()
          assert.isTrue AP.auth.Authentication.isAuthenticated()
          assert.isNotNull AP.auth.Authentication.store.get('ap-auth-session')
          assert.isNotNull AP.auth.Authentication.store.get('ap-auth-session-id')
          assert.deepEqual authCreds, AP.auth.Authentication.getAuthSessionData()
          assert.equal authSessionId, AP.auth.Authentication.getAuthSessionId()
        it 'should return current username from getUsername() when authentication is successful', ->
          AP.auth.Authentication.authenticate authCreds
          authServer.respond()
          assert.isTrue AP.auth.Authentication.isAuthenticated()
          assert.equal authCreds[authSettings.lookup_field], AP.auth.Authentication.getUsername()
        it 'should return current user role from getUserRole() when authentication is successful', ->
          AP.auth.Authentication.authenticate authCreds
          authServer.respond()
          assert.isTrue AP.auth.Authentication.isAuthenticated()
          assert.equal authCreds[authSettings.role_field], AP.auth.Authentication.getUserRole()
        if authSettings.session_id_field?
          it 'should authenticate successfully when session ID is passed through payload instead of response headers', ->
            authServer = sinon.fakeServer.create()
            delete authHeaders[authSessionHeader]
            authCreds[authSettings.session_id_field] = authSessionId
            authServer.respondWith 'POST',
              authSettings.authentication_url,
              [
                201
                authHeaders
                JSON.stringify authCreds
              ]
            AP.auth.Authentication.authenticate authCreds
            authServer.respond()
            assert.isTrue AP.auth.Authentication.isAuthenticated()
            assert.isNotNull AP.auth.Authentication.store.get('ap-auth-session-id')
            assert.equal authSessionId, AP.auth.Authentication.getAuthSessionId()
        it 'should set an "ap-auth-session-wwwbaseurlcom" key in auth store when base URL is http://www.baseurl.com/ authentication is successful', ->
          baseUrl = AP.baseUrl
          AP.baseUrl = 'http://www.baseurl.com/'
          AP.auth.Authentication.authenticate authCreds
          authServer.respond()
          assert.isNotNull AP.auth.Authentication.store.get('ap-auth-wwwbaseurlcom')
          assert.deepEqual authCreds, AP.auth.Authentication.getAuthSessionData()
          AP.baseUrl = baseUrl
        it 'shoud report user is authenticated when authentication is successful', ->
          assert.isFalse AP.auth.Authentication.isAuthenticated()
          AP.auth.Authentication.authenticate authCreds
          authServer.respond()
          assert.isTrue AP.auth.Authentication.isAuthenticated()
          assert.isObject AP.auth.Authentication.getAuthSessionData()
  
    describe 'deauthenticate()', ->
      describe 'failure contingency', ->
        it 'should report user as unauthenticated, even on failure', ->
          authServer.respondWith 'POST', authSettings.deauthentication_url, [401, {}, '']
          AP.auth.Authentication.authenticate authCreds
          authServer.respond()
          assert.isTrue AP.auth.Authentication.isAuthenticated()
          AP.auth.Authentication.deauthenticate()
          authServer.respond()
          assert.isFalse AP.auth.Authentication.isAuthenticated()
      describe 'success contingency', ->
        it 'should report user as unauthenticated on success', ->
          authServer.respondWith 'POST', authSettings.deauthentication_url, [200, {}, '']
          AP.auth.Authentication.authenticate authCreds
          authServer.respond()
          assert.isTrue AP.auth.Authentication.isAuthenticated()
          AP.auth.Authentication.deauthenticate()
          authServer.respond()
          assert.isFalse AP.auth.Authentication.isAuthenticated()
