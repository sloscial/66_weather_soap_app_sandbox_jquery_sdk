###*
A belongs-to relationship is one where the owner model instance is related to
no more than one other model instance.  In this scheme, the relationship
information is stored in a foreign key on the owner model.  The related instance
is stored in a generated field {@link #name} once fetched.

For example, if the foreign key is `user_id` and the relationship name is `user`
then the related instance may be obtained by calling:
@example
    ownerInstance.get('user')
    // set related instance
    ownerInstance.set('user', userInstance)
    // or set foreign key
    ownerInstance.set('user_id', 4)
    // setting the foreign key directly will null the related instance:
    ownerInstance.get('user') == null // evaluates to true

A has-one relationship is similar, except the relationship information is stored
in a foreign key on the target model, not the owner.  See
{@link AP.relationship.HasOne} for more information about has-one relationships.

Relationships should not be instantiated directly.  Please see
{@link AP.model.Model#relationshipDefinitions} for more information on
declaring relationships.

@module AP
@submodule relationship
@class BelongsTo
@extends AP.relationship.Relationship
###
class AP.relationship.BelongsTo extends AP.relationship.Relationship
  initialize: ->
    super
    @listenTo @owner, "change:#{@foreignKey}", @onForeignKeyChange
    @listenTo @owner, "change:#{@name}", @onFieldForRelatedInstanceChange
  
  ###*
  Sets the {@link #name} generated field on the owner model to the first model
  instance in the collection after syncing.
  @method onCollectionSync
  ###
  onCollectionSync: -> @owner.set @name, @collection.first()
  
  ###*
  Called whenever the owner instance's {@link #foreignKey} field is changed.
  If the foreign key is different than the related instance in the generated
  {@link #name} field, the {@link #name} field is set to null.  To obtain the
  related instance, the relationship must be fetched again.
  @method onForeignKeyChange
  ###
  onForeignKeyChange: ->
    if @owner.get(@foreignKey) != @owner.get(@name)?.get(@model::idAttribute)
      @owner.set @name, null
  
  ###*
  Called whenever the owner instance's {@link #name} field is changed.  If the
  ID of the related instance is different than the value of {@link #foreignKey},
  the foreign key field is updated with the related instance's ID.
  @method onFieldForRelatedInstanceChange
  ###
  onFieldForRelatedInstanceChange: ->
    relatedId = @owner.get(@name)?.get(@model::idAttribute)
    if relatedId and (@owner.get(@foreignKey) != relatedId)
      @owner.set @foreignKey, relatedId
  
  ###*
  Returns a query used to obtain the related instance from the server.
  @method getQuery
  @return {Object} parameters used to query server for the related instance
  ###
  getQuery: ->
    query = super
    query[@model::idAttribute] = @owner.get(@foreignKey)
    query
  
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
