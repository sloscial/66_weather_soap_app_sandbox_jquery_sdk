###*
Simple namespace class for this application.

Example application look-up:
@example
    app = AP.getApp('WeatherSoapAppSdk')

Example model and collection look-ups:
@example
    modelClass = app.getModel('modelName')
    collectionClass = app.getCollection('collectionName')

@class WeatherSoapAppSdk
@extends AP.Application
@static
###
class window.WeatherSoapAppSdk extends AP.Application
  @setup()
  
  ###*
  Application name.
  @static
  @property name
  @type String
  ###
  @name: 'WeatherSoapAppSdk'
  
  ###*
  Application description.
  @static
  @property description
  @type String
  ###
  @description: ''
  
  @init: ->
    window.AP.activeAppName = 'WeatherSoapApp'
    super
