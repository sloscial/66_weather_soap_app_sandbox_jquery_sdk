assert = chai.assert


describe 'AP.collection.ScopeCollection', ->
  ScopeClass = null
  scope = null
  data = null
  mapped = null
  
  beforeEach ->
    ScopeClass = AP.collection.ScopeCollection.extend
      queryFields: [
        fieldName: 'color'
        paramName: 'colour'
      ,
        fieldName: 'test'
        paramName: 'testing'
      ]
    scope = new ScopeClass()
    data =
      color: 'red'
      test: 123
      hello: 'Hello World!'
      goodbye: 'Have a good day.'
    mapped = scope.mapQueryFieldKeys data
  
  
  describe 'mapQueryFieldKeys()', ->
    it 'should return a new object', ->
      assert.isObject mapped
      assert.notEqual data, mapped
    it 'should map key names when matching query fields and not map keys when not matching query fields', ->
      assert.isDefined mapped.colour
      assert.isDefined mapped.testing
      assert.isUndefined mapped.color
      assert.isUndefined mapped.test
      assert.equal 'red', mapped.colour
      assert.equal 123, mapped.testing
      assert.equal 'Hello World!', mapped.hello
      assert.equal 'Have a good day.', mapped.goodbye
  
  
  describe 'fetch()', ->
    server = null
    beforeEach ->
      server = sinon.fakeServer.create()
      scope.url = -> '/models/'
    afterEach -> server.restore()
    it 'should make a GET request', ->
      server.respondWith 'GET', '/models/',
        [
          200
          {'Content-Type': 'application/json'}
          '[{"id": "12345", "age": 40, "hasDog": false}]'
        ]
      assert.equal scope.size(), 0
      scope.fetch()
      server.respond()
      assert.equal scope.size(), 1
      assert.equal server.requests[0].method, 'GET'
  
  
  describe 'fetch()', ->
    fetchOptions = null
    beforeEach ->
      fetchOptions = []
      # intercept arguments to the underlaying fetch method and then do nothing
      sinon.stub AP.collection.Collection::, 'fetch', (options) -> fetchOptions = options
    afterEach ->
      AP.collection.Collection::fetch.restore()
    it 'should process and replace options.query with the results of mapQueryFieldKeys()', ->
      scope.fetch({query: data})
      assert.deepEqual fetchOptions.query,
        colour: 'red'
        testing: 123
        hello: 'Hello World!'
        goodbye: 'Have a good day.'
