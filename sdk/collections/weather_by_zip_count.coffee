null
###*
WeatherByZipCountis an aggregate collection for application `WeatherSoapAppSdk`.  See
`AP.collection.AggregateCollection` to learn about about aggregates.
@module WeatherSoapAppSdk
@submodule collections
@class WeatherByZipCount
@extends AP.collection.AggregateCollection
###
class WeatherSoapAppSdk.collections.WeatherByZipCount extends AP.collection.AggregateCollection
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
  model: WeatherSoapAppSdk.models.WeatherByZip
  
  ###*
  Server requests for this collection use this URL.
  @property apiEndpoint
  @type String
  ###
  apiEndpoint: '/api/v7/weather_by_zips.json'
  
  ###*
  Name/value pairs included with every server request.  Extra parameters are
  converted to URL parameters at request-time.
  @property extraParams
  @type Object
  ###
  extraParams:
    scope: 'count'
  
  ###*
  Array of query field configurations.  Query fields map model field names onto
  URL parameter names.  See `AP.collection.ScopeCollection` to learn more
  about query fields.
  @property queryFields
  @type Array  
  ###
  queryFields: [
  
  ]
