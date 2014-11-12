assert = chai.assert


describe 'AP.Application', ->
  class AppClass extends AP.Application
    @setup()
    models: {
      model1: {
        modelId: '1234'
        name: 'MyModel1'
      }
      model2: {
        modelId: '0987'
        name: 'MyModel2'
      }
    }
    collections: {
      collection1: {
        collectionId: '1234'
        name: 'MyCollection1'
      }
      collection2: {
        collectionId: '0987'
        name: 'MyCollection2'
      }
    }
  
  describe 'getModel()', ->
    it 'should return a model by ID', ->
      assert.deepEqual AppClass.getModel('1234'), AppClass.models.model1
      assert.deepEqual AppClass.getModel('0987'), AppClass.models.model2
    it 'should return a model by name', ->
      assert.deepEqual AppClass.getModel('MyModel1'), AppClass.models.model1
      assert.deepEqual AppClass.getModel('MyModel2'), AppClass.models.model2
    it 'should return a model by key', ->
      assert.deepEqual AppClass.getModel('model1'), AppClass.models.model1
      assert.deepEqual AppClass.getModel('model2'), AppClass.models.model2
  describe 'getCollection()', ->
    it 'should return a collection by ID', ->
      assert.deepEqual AppClass.getCollection('1234'), AppClass.models.collection1
      assert.deepEqual AppClass.getCollection('0987'), AppClass.models.collection2
    it 'should return a collection by name', ->
      assert.deepEqual AppClass.getCollection('MyCollection1'), AppClass.models.collection1
      assert.deepEqual AppClass.getCollection('MyCollection2'), AppClass.models.collection2
    it 'should return a collection by key', ->
      assert.deepEqual AppClass.getCollection('collection1'), AppClass.models.collection1
      assert.deepEqual AppClass.getCollection('collection2'), AppClass.models.collection2
