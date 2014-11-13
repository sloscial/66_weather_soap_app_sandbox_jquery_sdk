###*
Base model class.  In addition to the standard methods provided by the
[BackboneJS model class](http://backbonejs.org/#Model), this base model
implements full validations support.

This model should be subclassed, not used directly.  For example (Coffeescript):
@example
    class Person extends AP.model.Model
      @modelId: 'person'
      name: 'Person'
      urlRoot: '/person/'
      fieldDefinitions: [
        name: 'name'
        type: 'string'
      ,
        name: 'age'
        type: 'integer'
      ]
      validations: [
        field: 'name'
        validate: 'type'
        is: 'string'
      ,
        field: 'name'
        validate: 'required'
      ,
        field: 'age'
        validate: 'type'
        is: 'integer'
      ]

For full model usage documentation,
refer to [Backbone JS](http://backbonejs.org/#Model).

@module AP
@submodule model
@class Model 
@extends Backbone.Model
###
class AP.model.Model extends Backbone.Model
  ###*
  An internal reference to initialized relationship instances for this
  model instance.
  @property _relationships
  @type AP.relationship.Relationship[]
  @private
  ###
  _relationships: null
  
  ###*
  An internal reference to the validator instance used by the model instance.
  @property _validator
  @type AP.utility.Validator
  @private
  ###
  _validator: null
  
  ###*
  An array of validation configurations.  For more information about
  validations, refer to
  the {@link AP.utility.Validator Validator documentation}.
  @property validations
  @type Object[]
  ###
  validations: []
  
  initialize: ->
    @initializeRelationships()
    @initializeValidations()
    @on 'sync', => @constructor.trigger?.apply @constructor, ['sync'].concat _.toArray(arguments)
  
  initializeRelationships: ->
    @_relationships = []
    _.each @relationshipDefinitions, (definition) =>
      relationship = new AP.relationship[definition.type] @, definition
      @_relationships.push relationship
  
  initializeValidations: ->
    @validations = _.clone(@validations)
    @_validator = new AP.utility.Validator
  
  ###*
  Retrieves the initialized relationship instance of the given name.
  @method getRelationship
  @param {String} name the name of the relationship
  @return {AP.relationship.Relationship} matching relationship instance
  ###
  getRelationship: (name) -> _.where(@_relationships, {name: name})[0]
  
  ###*
  Performs a `fetch` on the specified relationship.
  @method fetchRelated
  @param {String} name the name of the relationship
  @param {Function} callback called when fetching completes
  ###
  fetchRelated: (name, callback) -> @getRelationship(name)?.fetch(callback)
  
  ###*
  Appends `.json` to the end of the default URL.
  @method url
  @return {String} the URL for this model instance
  ###
  url: ->
    "#{super}.json"
  
  ###*
  Simple proxy to the model's underlaying `fetch` method inherited
  from Backbone JS `Model`.
  @method reload
  ###
  reload: -> @fetch.apply @, arguments
  
  ###*
  Simple override of the built-in Backbone.js `destroy` method to enable
  `before_delete` event handlers.
  @method destroy
  ###
  destroy: ->
    ###*
    @event 'before_delete'
    Triggered on a model instance immediately before being destroyed.
    ###
    @trigger 'before_delete'
    super
  
  ###*
  Simple proxy to the model's underlaying `destroy` method inherited
  from Backbone JS `Model`.
  @method delete
  ###
  delete: -> @destroy.apply @, arguments
  
  ###*
  Simple override of the built-in Backbone.js `set` method to enable
  `before_change` event handlers.
  @method set
  ###
  set: (key, val, options = {}) ->
    # Handle both `"key", value` and `{key: value}` -style arguments.
    if _.isObject key
      attrs = key
      options = val or {}
    else
      attrs = {}
      attrs[key] = val
    if attrs
      ###*
      @event 'before_change'
      Triggered on a model instance immediately before being changed.
      ###
      @trigger 'before_change', @, attrs
    super
  
  ###*
  Simple override of the built-in Backbone.js `save` method to enable
  `before_save` event handlers.
  @method save
  ###
  save: ->
    ###*
    @event 'before_save'
    Triggered on a model instance immediately before being saved.
    ###
    @trigger 'before_save'
    super
  
  ###*
  Validates the model instance and returns any errors reported by the instance's
  validator instance.
  @method errors
  @return {String[]} the errors array reported by the validator
  instance's {@link AP.utility.Validator#errors errors method}.
  ###
  errors: ->
    @validate()
    @_validator.errors()
  
  ###*
  Validates the model instance and returns `true` if the instance is valid,
  otherwise `false`.
  @method isValid
  @return {Boolean} the value reported by the validator
  instance's {@link AP.utility.Validator#isValid isValid method}.
  ###
  isValid: ->
    @validate()
    @_validator.isValid()
  
  ###*
  Copies the instance data (or optional `values` argument) and the instance
  validations into the {@link #_validator validator instance}.  Returns
  `undefined` if values are valid, otherwise returns
  an {@link #errors errors array}.
  @method validate
  @param {Object} values optional hash of field name/value pairs to validate 
  against this instance's validations.  Pass `values` to validate arbitrary
  data instead of instance data.
  @return {String[]/undefined} if valid, returns `undefined` as expected by
  the underlaying [Backbone JS model class](http://backbonejs.org/#Model).
  If invalid, returns the {@link #errors errors array}.
  ###
  validate: (values) ->
    # get the latest data and validations
    @_validator.data = _.extend({}, values or @attributes)
    @_validator.validations = @validations.slice()
    # Return undefined if validation passes.
    # Backbone treats any value, including "true", as a validation error.
    if @_validator.validate()
      undefined
    else
      @_validator.errors()
  
  ###*
  Recurses into nested models and calls toJSON.
  @method toJSON
  @return {Object} JSON representation of this model instance
  ###
  toJSON: ->
    json = super
    for key, value of json
      json[key] = value.toJSON() if _.isFunction(value?.toJSON)
    json
