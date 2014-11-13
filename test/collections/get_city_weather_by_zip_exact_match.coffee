assert = chai.assert


sdk = WeatherSoapAppSdk
modelName = 'GetCityWeatherByZip'
collectionName = 'GetCityWeatherByZipExactMatch'


describe 'Scope Collection Class:  WeatherSoapAppSdk.collections.GetCityWeatherByZipExactMatch', ->
  modelClass = undefined
  collectionClass = undefined
  modelInstance = undefined
  collectionInstance = undefined

  beforeEach ->
    sdk.mockServer.resetDatastore()
    modelClass = sdk.getModel modelName
    collectionClass = sdk.getCollection collectionName

  afterEach ->
    modelClass = undefined
    collectionClass = undefined
    modelInstance = undefined
    collectionInstance = undefined

  it 'exists', ->
    assert.isDefined collectionClass

  it 'uses the model `GetCityWeatherByZip`', ->
    assert.equal modelClass, collectionClass::model

  
  it 'performs GET requests with query parameters and, on success, contains model instances of `GetCityWeatherByZip`', (done) ->
    datastoreInstance = AP.getActiveApp().mockServer.getOrCreateCollectionInstanceFor(collectionClass)
    query = {}
    query[modelClass::idAttribute] = datastoreInstance.first().get(modelClass::idAttribute)
    collectionInstance = new collectionClass()
    collectionInstance.query query,
      success: ->
        assert.equal collectionInstance.length, 1
        collectionInstance.each (modelInstance) ->
          assert.instanceOf modelInstance, modelClass
        done()
      error: -> done(new Error)
  it 'caches successful GET requests with query parameters and, on AJAX failure, succeeds with cached response', (done) ->
    datastoreInstance = AP.getActiveApp().mockServer.getOrCreateCollectionInstanceFor(collectionClass)
    query = {}
    query[modelClass::idAttribute] = datastoreInstance.first().get(modelClass::idAttribute)
    collectionInstance1 = new collectionClass()
    collectionInstance1.query query,
      success: ->
        assert.equal collectionInstance1.length, 1
        collectionInstance1.each (modelInstance) -> assert.instanceOf modelInstance, modelClass
        # create new server to simulate a server error / offline mode
        sdk.mockServer.server.restore()
        server = sinon.fakeServer.create()
        server.autoRespond = true
        url = sdk.mockServer.getEndpointRegexWithQueryStringFor collectionClass
        server.respondWith 'GET', url, [500, null, '']
        collectionInstance2 = new collectionClass()
        collectionInstance2.query query,
          success: ->
            assert.equal server.requests.length, 1
            assert.equal server.requests[0].method, 'GET'
            assert.equal server.requests[0].status, 500
            assert.equal collectionInstance2.length, 1
            collectionInstance2.each (modelInstance, i) ->
              assert.instanceOf modelInstance, modelClass
              assert.deepEqual modelInstance.toJSON(), collectionInstance1.at(i).toJSON()
            sdk.mockServer = new AP.utility.MockServer(sdk) if AP.useMockServer
            done()
          error: -> done(new Error)
  
