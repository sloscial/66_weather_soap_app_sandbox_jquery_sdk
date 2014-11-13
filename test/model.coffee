assert = chai.assert


describe 'AP.model.Model', ->
  describe 'CRUD', ->
    instance = null
    server = null
    beforeEach ->
      server = sinon.fakeServer.create()
      class ModelClass extends AP.model.Model
        urlRoot: '/model'
      instance = new ModelClass
        name: 'John Doe'
        age: 36
        hasDog: true
    afterEach -> server.restore()
    describe 'reload()', ->
      beforeEach -> sinon.stub instance, 'fetch'
      afterEach -> instance.fetch.restore()
      it 'should fetch the model', ->
        instance.reload()
        assert.isTrue instance.fetch.called
    describe 'fetch()', ->
      it 'should make a GET request replace instance values with those from the response', ->
        server.respondWith 'GET', '/model/12345.json',
          [
            200
            {'Content-Type': 'application/json'}
            '{"age": 40, "hasDog": false}'
          ]
        assert.equal instance.get('age'), 36
        assert.isTrue instance.get('hasDog')
        instance.set 'id', '12345'
        instance.fetch()
        server.respond()
        assert.equal server.requests[0].method, 'GET'
        assert.equal instance.get('age'), 40
        assert.isFalse instance.get('hasDog')
      it 'should properly load fields of any type', ->
        server.respondWith 'GET', '/model/12345.json',
          [
            200
            {'Content-Type': 'application/json'}
            '{"id": "12345", "string": "string", "integer": 1, "float": 1.5, "boolean": true, "array": [1, 2, 3], "hash": {"string": "string", "integer": 1, "float": 1.5, "boolean": true}}'
          ]
        instance.set 'id', '12345'
        instance.fetch()
        server.respond()
        assert.isString instance.get('string')
        assert.isNumber instance.get('integer')
        assert.equal instance.get('integer'), 1
        assert.isNumber instance.get('float')
        assert.equal instance.get('float'), 1.5
        assert.isBoolean instance.get('boolean')
        assert.isArray instance.get('array')
        assert.isObject instance.get('hash')
    describe 'save()', ->
      it 'should make a POST request if instance is new', ->
        server.respondWith 'POST', '/model.json',
          [
            201
            {'Content-Type': 'application/json'}
            '{"id": "12345", "name": "John Doe", "age": 36, "hasDog": true}'
          ]
        assert.isTrue instance.isNew()
        assert.isUndefined instance.get('id')
        instance.save()
        server.respond()
        assert.equal server.requests[0].method, 'POST'
        assert.isFalse instance.isNew()
      it 'should make a PUT request if instance exists', ->
        server.respondWith 'PUT', '/model/12345.json',
          [
            200
            {'Content-Type': 'application/json'}
            '{"id": "12345", "name": "John Doe", "age": 40, "hasDog": false}'
          ]
        assert.equal instance.get('age'), 36
        assert.isTrue instance.get('hasDog')
        instance.set 'id', '12345'
        instance.set 'age', 40
        instance.set 'hasDog', false
        assert.isFalse instance.isNew()
        instance.save()
        server.respond()
        assert.equal server.requests[0].method, 'PUT'
        assert.isFalse instance.isNew()
        assert.equal instance.get('age'), 40
        assert.isFalse instance.get('hasDog')
      it 'should fire `before_change` ahead of attribute changes', ->
        assert.equal instance.get('age'), 36
        assert.isTrue instance.get('hasDog')
        instance.on 'before_change', (record, attributes) ->
          assert.equal instance.get('age'), 36
          assert.isTrue instance.get('hasDog')
        instance.set({age: 37, hasDog: false})
        assert.equal instance.get('age'), 37
        assert.isFalse instance.get('hasDog')
      it 'should fire `before_save` ahead of the server request', ->
        server.respondWith 'POST', '/model.json',
          [
            201
            {'Content-Type': 'application/json'}
            '{"id": "12345", "name": "John Doe", "age": 36, "hasDog": true}'
          ]
        assert.isTrue instance.isNew()
        assert.equal server.requests.length, 0
        instance.on 'before_save', ->
          assert.isTrue instance.isNew()
          assert.equal server.requests.length, 0
        instance.save()
        server.respond()
        assert.isFalse instance.isNew()
        assert.equal server.requests.length, 1
    describe 'delete()', ->
      beforeEach -> sinon.stub instance, 'destroy'
      afterEach -> instance.destroy.restore()
      it 'should call destroy on the model', ->
        instance.delete()
        assert.isTrue instance.destroy.called
    describe 'destroy()', ->
      it 'should make a DELETE request if instance exists', ->
        server.respondWith 'DELETE', '/model/12345.json',
          [
            204
            {'Content-Type': 'application/json'}
            ''
          ]
        instance.set 'id', '12345'
        assert.isFalse instance.isNew()
        instance.destroy()
        server.respond()
        assert.equal server.requests[0].method, 'DELETE'
      it 'should do nothing if instance is new', ->
        server.respondWith 'DELETE', '/model/',
          [
            204
            {'Content-Type': 'application/json'}
            ''
          ]
        assert.isTrue instance.isNew()
        instance.destroy()
        server.respond()
        assert.isTrue instance.isNew()
        assert.lengthOf server.requests, 0
      it 'should fire `before_delete` ahead of the server request', ->
        server.respondWith 'DELETE', '/model/12345.json',
          [
            204
            {'Content-Type': 'application/json'}
            ''
          ]
        instance.set 'id', '12345'
        assert.isFalse instance.isNew()
        assert.equal server.requests.length, 0
        instance.on 'before_delete', ->
          assert.equal server.requests.length, 0
        instance.destroy()
        server.respond()
        assert.equal server.requests.length, 1
        assert.equal server.requests[0].method, 'DELETE'
  
  
  describe 'relationship', ->
    instance = null
    server = null
    beforeEach ->
      server = sinon.fakeServer.create()
      class RelatedModelClass extends AP.model.Model
        # pass
      class ModelClass extends AP.model.Model
        urlRoot: '/model/'
        relationshipDefinitions: [
          'type': 'BelongsTo'
          model: RelatedModelClass
          name: 'belongs'
          collection: Backbone.Collection
          foreignKey: 'belongs_id'
        ,
          'type': 'HasMany'
          model: RelatedModelClass
          name: 'many'
          collection: Backbone.Collection
          foreignKey: 'many_id'
        ,
          'type': 'HasOne'
          model: RelatedModelClass
          name: 'one'
          collection: Backbone.Collection
          foreignKey: 'one_id'
        ]
      instance = new ModelClass
        name: 'John Doe'
        age: 36
        hasDog: true
    describe 'relationshipDefinitions', ->
      it 'should be initialized on model instance initialization', ->
        assert.isArray instance._relationships
        assert.lengthOf instance._relationships, 3
    describe 'getRelationship()', ->
      it 'should return initialized relationships available by name', ->
        assert.isFunction instance.getRelationship
        assert.instanceOf instance.getRelationship('belongs'), AP.relationship.BelongsTo
        assert.instanceOf instance.getRelationship('belongs'), AP.relationship.Relationship
        assert.instanceOf instance.getRelationship('many'), AP.relationship.HasMany
        assert.instanceOf instance.getRelationship('many'), AP.relationship.Relationship
        assert.instanceOf instance.getRelationship('one'), AP.relationship.HasOne
        assert.instanceOf instance.getRelationship('one'), AP.relationship.Relationship

  
  describe 'validation', ->
    instance = null
    beforeEach ->
      instance = new AP.model.Model
        name: 'John Doe'
        age: 36
        hasDog: true
    describe 'isValid()', ->
      it 'should return true when model has no validations', ->
        assert.lengthOf instance.validations, 0
        assert.isTrue instance.isValid()
      it 'should return true when model has validations and model is valid', ->
        instance.validations.push {field: 'name', validate: 'required'}
        assert.lengthOf instance.validations, 1
        assert.isTrue instance.isValid()
      it 'should return false when model has validations and model is invalid', ->
        instance.validations.push {field: 'hasCat', validate: 'required'}
        assert.lengthOf instance.validations, 1
        assert.isFalse instance.isValid()
    describe 'validate()', ->
      it 'should return undefined when model is valid', ->
        assert.isTrue instance.isValid()
        assert.isUndefined instance.validate()
      it 'should return non-empty array when model is invalid', ->
        instance.validations.push {field: 'hasCat', validate: 'required'}
        assert.isFalse instance.isValid()
        assert.isArray instance.validate()
        assert.lengthOf instance.validate(), 1
    describe 'errors()', ->
      it 'should return an empty array when model has no validations', ->
        assert.lengthOf instance.validations, 0
        assert.isArray instance.errors()
        assert.lengthOf instance.errors(), 0
