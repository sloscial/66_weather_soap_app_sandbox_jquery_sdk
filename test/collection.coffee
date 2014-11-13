assert = chai.assert


describe 'AP.collection.Collection', ->
  collection = null
  data = null
  mapped = null
  
  beforeEach ->
    collection = new AP.collection.Collection()
    data = {field1: 1, field2: 2}
    mapped = collection.mapQueryParams data
  
  
  describe 'mapQueryParams()', ->
    it 'should return a new object', ->
      assert.isObject mapped
      assert.notDeepEqual data, mapped
    it 'should map key names to the format "query[keyName]"', ->
      assert.isUndefined mapped.field1
      assert.isUndefined mapped.field2
      assert.equal 1, mapped['query[field1]']
      assert.equal 2, mapped['query[field2]']
  
  
  describe 'fetch()', ->
    server = null
    beforeEach ->
      server = sinon.fakeServer.create()
      collection.url = -> '/models/'
    afterEach -> server.restore()
    it 'should make a GET request', ->
      server.respondWith 'GET', '/models/',
        [
          200
          {'Content-Type': 'application/json'}
          '[{"id": "12345", "age": 40, "hasDog": false}]'
        ]
      assert.equal collection.size(), 0
      collection.fetch()
      server.respond()
      assert.equal collection.size(), 1
      assert.equal server.requests[0].method, 'GET'
  
  
  describe 'fetch()', ->
    fetchOptions = null
    beforeEach ->
      fetchOptions = []
      # intercept arguments to the underlaying fetch method and then do nothing
      sinon.stub Backbone.Collection::, 'fetch', (options) -> fetchOptions = options
    afterEach ->
      Backbone.Collection::fetch.restore()
    it 'should extend options.data with extraParams', ->
      collection.extraParams = {key: 'value'}
      collection.fetch()
      assert.deepEqual fetchOptions.data, {key: 'value'}
      collection.fetch({data: {test: 1}})
      assert.deepEqual fetchOptions.data, {key: 'value', test: 1}
    it 'should apply mapQueryParams() to options.query and add the result to options.data', ->
      collection.fetch({query: {key: 'value'}})
      assert.deepEqual fetchOptions.data, {'query[key]': 'value'}
      collection.fetch({query: {key: 'value'}, data: {key: 'value'}})
      assert.deepEqual fetchOptions.data, {'query[key]': 'value', key: 'value'}
    it 'should merge extraparams, options.data, and processed otions.query', ->
      collection.extraParams = {test: 1}
      collection.fetch({query: {key: 'value'}})
      assert.deepEqual fetchOptions.data, {'query[key]': 'value', test: 1}
      collection.fetch({query: {key: 'value'}, data: {key: 'value'}})
      assert.deepEqual fetchOptions.data, {'query[key]': 'value', key: 'value', test: 1}
  
  describe 'query()', ->
    beforeEach -> sinon.stub collection, 'fetch'
    afterEach -> collection.fetch.restore()
    it 'should call fetch(), passing first argument as fetch query', ->
      collection.query({name: 'John Doe', age: 36})
      assert.isTrue collection.fetch.called
      assert.deepEqual collection.fetch.firstCall.args[0].query, {name: 'John Doe', age: 36}
