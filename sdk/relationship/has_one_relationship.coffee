###*
A has-one relationship is simlar to a {@link AP.relationship.BelongsTo}
relationship except that the relationship information is stored in foreign key
fields on the related instances instead of on owner instances.

In implementation, a has-one relationship functions like has-many, except that
the value of the generated {@link #name} field is a related
{@link #model model instance} instead of a collection.

Relationships should not be instantiated directly.  Please see
{@link AP.model.Model#relationshipDefinitions} for more information on
declaring relationships.

@module AP
@submodule relationship
@class HasOne
@extends AP.relationship.HasMany
###
class AP.relationship.HasOne extends AP.relationship.HasMany
  initializeEvents: ->
    @listenTo @collection, "change:#{@foreignKey}", @onForeignKeyChange
    @listenTo @owner, "change:#{@name}", @onFieldForRelatedInstanceChange
    super
  
  ###*
  Sets the {@link #name} generated field on the owner model to the first model
  instance in the collection after syncing.
  @method onCollectionSync
  ###
  onCollectionSync: -> @owner.set @name, @collection.first()
  
  ###*
  Called whenever the related instance's {@link #foreignKey} field is changed.
  If the foreign key of the related instance referes to a different owner, then
  the {@link #name} field is set to null.  To obtain the related instance after
  the field is nulled, the relationship must be fetched again.
  @method onForeignKeyChange
  ###
  onForeignKeyChange: ->
    related = @owner.get(@name)
    if related and (related.get(@foreignKey) != @owner.get(@owner.idAttribute))
      @owner.set @name, null
  
  ###*
  Called whenever the owner instance's {@link #name} field is changed.  If the
  foreign key of the new related instance is different than the ID of the owner,
  the foreign key field of the related instance is set to the ID of the owner.
  @method onFieldForRelatedInstanceChange
  ###
  onFieldForRelatedInstanceChange: ->
    related = @owner.get(@name)
    ownerId = @owner.get(@owner.idAttribute)
    if related and (related.get(@foreignKey) != ownerId)
      related.set @foreignKey, ownerId
  
  ###*
  The default value for a has-one relationship is null like belongs-to.
  @method getDefault
  @return {Object} null
  ###
  getDefault: -> null
  
  ###*
  Querys the server for related instances.
  @method fetch
  @param {Function} callback function executed upon query success; called with
  one argument:  the related instance (if any)
  ###
  fetch: (callback) ->
    @collection.query @getQuery(),
      reset: true
      success: => callback(@owner, @collection.first()) if _.isFunction(callback)
