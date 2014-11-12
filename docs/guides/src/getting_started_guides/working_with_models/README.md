A model instance represents a single record.  Additionally, models validate data, encapsulate CRUD logic, and much more.  See the [Backbone.js model documentation](http://backbonejs.org/#Model) for additional information.

## Working with Model Instances

Models are easy to work with.  Model instances may be created and saved in two ways.

    // Create a new model instance and save it
    instance = new AppSdk.models.Object
      name: 'Test'
      phone: '0000'
    instance.save() // fires a POST request
    
    // Create a new model instance within a collection
    // Model instances created in this manner are saved immediately
    collection = new AppSdk.collections.ObjectAll()
    instance = collection.create({name: 'Test', phone: '0000'})

Updating (PUT) model instances uses almost the same syntax.  Deleting records (DELETE) is equally simple.

    // Update a model instance and save it
    instance.set('name', 'Services')
    instance.save()
    
    // Delete instance
    instance.delete()

Most CRUD methods accept callbacks.

    instance.save null,
      success: -> alert('success')
      error: -> alert('FAIL!')

    instance.delete
      success: -> alert('success')
      error: -> alert('FAIL!')

Whenever an action is taken on a model instance, an event is fired.  Event handlers are easy to setup.

    instance.on 'change', ->
      alert 'something changed!'

    instance.on 'change:title', ->
      alert 'title changed!'

## Define a Model Class in CoffeeScript

    class AppSdk.models.MyModel extends AP.model.Model
