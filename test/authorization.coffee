assert = chai.assert


describe 'AP.auth.Authorization', ->
  authSettings = AP.auth.Authentication.getAuthenticationSettings()
  authServer = null
  authSessionId = null
  authSessionHeader = null
  authHeaders = null
  authCreds = null
  
  # test simple case if application has no authentication enabled
  if !authSettings
    describe 'isAuthorized()', ->
      it 'should return true when user is unauthenticated and there are no rules', ->
        assert.isFalse AP.auth.Authentication.isAuthenticated()
        assert.isTrue AP.auth.Authorization.isAuthorized([])
  
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
      authCreds[authSettings.role_field] = 'admin,manager,editor'
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
  
    describe 'isAuthorized()', ->
      it 'should return false when user is unauthenticated', ->
        assert.isFalse AP.auth.Authentication.isAuthenticated()
        assert.isFalse AP.auth.Authorization.isAuthorized([roles: 'admin,manager,editor'])
        assert.isFalse AP.auth.Authorization.isAuthorized([roles: 'admin,role123'])
        assert.isFalse AP.auth.Authorization.isAuthorized([roles: 'admin'])
      it 'should return false when authenticated user has no roles', ->
        authServer = sinon.fakeServer.create()
        delete authCreds[authSettings.role_field]
        authServer.respondWith 'POST',
          authSettings.authentication_url,
          [
            201
            authHeaders
            JSON.stringify authCreds
          ]
        AP.auth.Authentication.login authCreds
        authServer.respond()
        assert.isTrue AP.auth.Authentication.isAuthenticated()
        assert.isFalse AP.auth.Authorization.isAuthorized([roles: 'admin,manager,editor'])
        assert.isFalse AP.auth.Authorization.isAuthorized([roles: 'admin,role123'])
        assert.isFalse AP.auth.Authorization.isAuthorized([roles: 'admin'])
      it 'should return false when authenticated user has no matching roles', ->
        AP.auth.Authentication.login authCreds
        authServer.respond()
        assert.isTrue AP.auth.Authentication.isAuthenticated()
        assert.isFalse AP.auth.Authorization.isAuthorized([roles: 'role123,viewer,superuser'])
        assert.isFalse AP.auth.Authorization.isAuthorized([roles: 'superuser,role123'])
        assert.isFalse AP.auth.Authorization.isAuthorized([roles: 'viewer'])
      it 'should return true when user is authenticated and there are no rules', ->
        AP.auth.Authentication.login authCreds
        authServer.respond()
        assert.isTrue AP.auth.Authentication.isAuthenticated()
        assert.isTrue AP.auth.Authorization.isAuthorized([])
      it 'should return true when authenticated user has at least one matching role', ->
        authServer = sinon.fakeServer.create()
        authCreds[authSettings.role_field] = 'admin'
        authServer.respondWith 'POST',
          authSettings.authentication_url,
          [
            201
            authHeaders
            JSON.stringify authCreds
          ]
        AP.auth.Authentication.login authCreds
        authServer.respond()
        assert.isTrue AP.auth.Authentication.isAuthenticated()
        assert.isTrue AP.auth.Authorization.isAuthorized([roles: 'admin,manager,editor'])
        assert.isTrue AP.auth.Authorization.isAuthorized([roles: 'admin,role123'])
        assert.isTrue AP.auth.Authorization.isAuthorized([roles: 'admin'])
