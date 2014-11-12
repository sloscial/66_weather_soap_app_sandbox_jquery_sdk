assert = chai.assert


sdk = WeatherSoapAppSdk
modelName = 'WeatherByZip'
collectionName = 'WeatherByZipCount'


describe 'Aggregate Collection Class:  WeatherSoapAppSdk.collections.WeatherByZipCount', ->
  modelClass = undefined
  collectionClass = undefined
  modelInstance = undefined
  collectionInstance = undefined
  
  beforeEach ->
    modelClass = sdk.getModel modelName
    collectionClass = sdk.getCollection collectionName
  
  afterEach ->
    modelClass = undefined
    collectionClass = undefined
    modelInstance = undefined
    collectionInstance = undefined
  
  it 'exists', ->
    assert.isDefined collectionClass
  
  it 'uses the model `WeatherByZip`', ->
    assert.equal modelClass, collectionClass::model
