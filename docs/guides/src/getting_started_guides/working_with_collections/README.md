Collections are sets of model instances.  They are the primary means to GET records from the server.  Using collections is easy:

#### Fetch
    
    collection = new AppSdk.collections.ObjectAll()
    collection.fetch()

#### Paginate:  get no more than five objects, starting at the fifteenth
    
    collection = new AppSdk.collections.ObjectAll()
    collection.fetch({data: {limit: 5, offset: 15}})

#### Query for one specific object
    
    collection = new AppSdk.collections.ObjectExactMatch()
    collection.query {id: '12345'},
      complete: ->
        alert 'completed'

Since collections fetch records from a server via asynchronous calls, working with their records is generally accomplished with event handlers.  In BackboneJS 1.0 or later, listen for a collection's sync event. In versions prior to 1.0, listen for the reset event.  Review the collections documentation for details.

#### Create an event handler function

    onCollectionSync = ->
      // log each record in the collection to the console
      @each (record) -> console.log record
    // Attach event handler to collection sync event
    collection.on('sync', onCollectionSync, collection)

Once a collection is fetched it provides a number of useful methods.  See the BackboneJS documentation for a complete list.

#### Iterate over every record in a collection
    
    collection.each (record) ->
      alert record.id

#### Get the first object from a collection

    instance = collection.first()
    
#### Find all local records with matching attributes

    results = collection.where
      value: 1

#### Get only the first object with matching attributes

    instance = collection.findWhere
      value: 1

####  Get a sorted array of objects
    
    results = collection.sortBy (record) ->
      record.get 'value'

####  Flatten collection to an array of values
    
    collection.map (record) ->
      record.get 'value'

### Event Handling

    # do something useful after fetch
    todos.on 'reset', ->
      alert 'reloaded!'

    # do useful things after a record changes
    todos.on 'change', ->
      alert 'a model changed!'
