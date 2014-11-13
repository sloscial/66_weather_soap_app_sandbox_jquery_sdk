###*
GetCityWeatherByZipExactMatchis a scope collection for application `WeatherSoapAppSdk`.  See
`AP.collection.ScopeCollection` for more information about scopes.

@module WeatherSoapAppSdk
@submodule collections
@class GetCityWeatherByZipExactMatch
@extends AP.collection.ScopeCollection
###
class WeatherSoapAppSdk.collections.GetCityWeatherByZipExactMatch extends AP.collection.ScopeCollection
  ###*
  The collection ID may be used to look-up a collection from an
  application class.
  @property collectionId
  @type String
  @static
  ###
  @collectionId: ''
  
  ###*
  The model associated with this collection.  Results returned by server
  requests for this collection are converted into instances of this model.
  @property model
  @type AP.model.Model
  ###
  model: WeatherSoapAppSdk.models.GetCityWeatherByZip
  
  ###*
  Server requests for this collection use this URL.
  @property apiEndpoint
  @type String
  ###
  apiEndpoint: '/api/v12/get_city_weather_by_zips.json'
  
  ###*
  Name/value pairs included with every server request.  Extra parameters are
  converted to URL parameters at request-time.
  @property extraParams
  @type Object
  ###
  extraParams:
    scope: 'exact_match'
  
  ###*
  Array of query field configurations.  Query fields map model field names onto
  URL parameter names.  See `AP.collection.ScopeCollection` to learn more
  about query fields.
  @property queryFields
  @type Array
  ###
  queryFields: [
  
  ]
