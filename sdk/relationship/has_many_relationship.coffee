###*
A has-many relationship is one where the owner model instance is related to
any number of related instances.  In this scheme, the relationship
information is stored in a foreign key on the related instance(s).  The related
instances are stored in the {@link #collection} on a generated field
{@link #name} once fetched.

Relationships should not be instantiated directly.  Please see
{@link AP.model.Model#relationshipDefinitions} for more information on
declaring relationships.

@module AP
@submodule relationship
@class HasMany
@extends AP.relationship.Relationship
###
class AP.relationship.HasMany extends AP.relationship.Relationship
  initialize: ->
    super
    @listenTo @collection, "reset", @onCollectionReset
    @listenTo @collection, "change:#{@foreignKey}", @onRelatedInstanceForeignKeyChange
  
  ###*
  Sets the {@link #foreignKey} of the related instance to the ID of the owner
  instance when added to the collection.  Triggers a change event on the
  generated relationship field {@link #name}.
  @method onCollectionAdd
  @param {Object} record the added model instance
  ###
  onCollectionAdd: (record) ->
    record.set @foreignKey, @owner.get(@owner.idAttribute)
    @owner.trigger "change:#{@name}"
  
  ###*
  Unset the {@link #foreignKey} of the related instance when removed from
  the collection.  Triggers a change event on the generated relationship
  field {@link #name}.
  @method onCollectionRemove
  @param {Object} record the removed model instance
  ###
  onCollectionRemove: (record) ->
    if record.get(@foreignKey) == @owner.get(@owner.idAttribute)
      record.set @foreignKey, null
    @owner.trigger "change:#{@name}"
  
  ###*
  Triggers a change event on the generated relationship field {@link #name} when
  the collection is reset.  See {@link #filterCollection}.
  @method onCollectionReset
  ###
  onCollectionReset: -> @owner.trigger "change:#{@name}"
  
  ###*
  Calls {@link #filterCollection} whenever the foreign key field of a related
  instance is changed.
  @method onRelatedInstanceForeignKeyChange
  ###
  onRelatedInstanceForeignKeyChange: -> @filterCollection()
  
  ###*
  Removes any stale related instances from the collection.  Stale instances are
  instances with foreign keys that no longer refer to the owner instance.
  See {@link #onCollectionReset}.
  @method filterCollection
  ###
  filterCollection: ->
    whereClause = {}
    whereClause[@foreignKey] = @owner.get(@owner.idAttribute)
    filtered = @collection.where(whereClause)
    @collection.reset filtered, {reset: true}
  
  ###*
  Returns the default value of the generated field {@link #name}.  For many-to-
  many relationships, the value is always the {@link #collection} instance.
  @method getDefault
  @return {AP.collection.Collection} the collection instance declared
  by {@link #collection}.
  ###
  getDefault: -> @collection
  
  ###*
  Returns a query used to obtain the related instances from the server.
  @method getQuery
  @return {Object} parameters used to query server for the related instances
  ###
  getQuery: ->
    query = super
    query[@foreignKey] = @owner.get(@owner.idAttribute)
    query
  
  ###*
  Querys the server for related instances.
  @method fetch
  @param {Function} callback function executed upon query success; called with
  one argument:  the collection of related instances
  ###
  fetch: (callback) ->
    @collection.query @getQuery(),
      reset: true
      success: => callback(@owner, @collection) if _.isFunction(callback)
