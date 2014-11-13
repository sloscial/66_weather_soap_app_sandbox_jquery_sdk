###*
WeatherByZip model for application `WeatherSoapAppSdk`.  See
`AP.model.Model` for more information about models.

@module WeatherSoapAppSdk
@submodule models
@class WeatherByZip
@extends AP.model.Model
###
class WeatherSoapAppSdk.models.WeatherByZip extends AP.model.Model
  # mixin Backbone events on the model class
  _.extend @, Backbone.Events
  
  ###*
  The model ID may be used to look-up a model from an application class.
  @property modelId
  @type String
  @static
  ###
  @modelId: ''
  
  ###*
  The model name may be used to look-up a model from an application class.
  @property name
  @type String
  ###
  name: 'WeatherByZip'
  
  ###*
  Server requests for model instances use this URL.
  @property urlRoot
  @type String
  ###
  urlRoot: '/api/v7/weather_by_zips'
  
  ###*
  Array of field definition configurations.  Field definitions describe fields
  available on this model.
  @property fieldDefinitions
  @type Array
  ###
  fieldDefinitions: [
  
    # TODO where is the field ID?
    #id: 
    name: 'id'
    label: 'id'
    
    
    type: 'integer'
    required: false
    file_url: false
    file_type: 'Image'
  ,
  
    # TODO where is the field ID?
    #id: 
    name: 'get_city_weather_by_zip'
    label: 'get_city_weather_by_zip'
    
    
    type: 'string'
    required: false
    file_url: false
    file_type: 'Image'
  ,
  
    # TODO where is the field ID?
    #id: 
    name: 'get_city_weather_by_zip_response'
    label: 'get_city_weather_by_zip_response'
    
    
    type: 'string'
    required: false
    file_url: false
    file_type: 'Image'
  ,
  
  ]
  
  ###*
  Array of field names.  Auto keys, generally such as `id`, have their values
  filled automatically by the server.  Non-auto keys are all other fields.
  @property nonAutoKeyFields
  @type Array
  ###
  nonAutoKeyFields: [
  
  ]
  
  ###*
  Array of relationship definitions.
  @property relationshipDefinitions
  @type Array
  ###
  relationshipDefinitions: [
    
    
    
  ]
  
  ###*
  Array of validation configurations.  See `AP.model.Model` for more information
  about validations.
  @property validations
  @type Array
  ###
  validations: [
  
  
  
  
  
  
  
  ]
