assert = chai.assert


sdk = WeatherSoapAppSdk
modelName = 'GetCityWeatherByZip'
collectionName = 'GetCityWeatherByZipCount'


describe 'Aggregate Collection Class:  WeatherSoapAppSdk.collections.GetCityWeatherByZipCount', ->
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
  
  it 'uses the model `GetCityWeatherByZip`', ->
    assert.equal modelClass, collectionClass::model
