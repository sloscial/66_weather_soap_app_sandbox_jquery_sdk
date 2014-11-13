assert = chai.assert


sdk = WeatherSoapAppSdk
modelName = 'WeatherByZip'
collectionName = 'WeatherByZipCountExactMatch'


describe 'Aggregate Collection Class:  WeatherSoapAppSdk.collections.WeatherByZipCountExactMatch', ->
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
