###*
Similar to `AP.collection.Collection` except that query data are
optionally mapped to alternative parameter names.  Specify query fields when
request parameters have different names than model fields.

For example (Coffeescript):
@example
    class PeopleScope extends AP.collection.ScopeCollection
      @collectionId: 'people_scope'
      model: Person
      apiEndpoint: '/person/'
      extraParams:
        scope: 'scoped'
      queryFields: [
        fieldName: 'name'
        paramName: 'person_name'
      ]

@module AP
@submodule collection
@class ScopeCollection
@extends AP.collection.Collection
###
class AP.collection.ScopeCollection extends AP.collection.Collection
  ###*
  Copies `data` to new object and replaces keys which match any `queryFields`
  mapping configurations with the alternative parameter name.  For example,
  with `queryFields` `[{fieldName: 'name', paramName: 'person_name'}] and
  input object `{name: 'John', age: 35}`, output object
  is `{person_name: 'John', age: 35}`.
  @method mapQueryFieldKeys
  @param {Object} data name/value pairs to map
  @return {Object} a new object with mapped keys
  ###
  mapQueryFieldKeys: (data) ->
    '''
    Maps key names in data to equivalent param names in @queryFields if
    any match.  On match, original key names are not retained.  Returns a new
    object leaving original intact.
    '''
    mapped = {}
    for key, value of data
      paramName = (_.find(@queryFields, (field) -> field.fieldName == key) or {}).paramName
      mappedKey = paramName or key
      mapped[mappedKey] = value if value
    mapped
  
  ###*
  Fetches objects from the collection instance's URL.  All arguments are passed-
  through to {@link AP.collection.Collection#fetch}, except for `options.query`
  which is transformed first by {@link #mapQueryFieldKeys}.
  @method fetch
  @param {Object} options optional request data
  @param {Object} options.query optional query parameters are passed through
  request URL after being transformed by {@link #mapQuerParams}
  @param args... optional additional arguments passed-through
  to {@link AP.collection.Collection#fetch}
  ###
  fetch: (options, args...) ->
    options ?= {}
    query = @mapQueryFieldKeys(options.query) if options?.query
    options.query = query if query
    AP.collection.Collection.prototype.fetch.apply @, [options].concat(args)
