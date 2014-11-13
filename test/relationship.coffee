assert = chai.assert


describe 'AP.relationship.Relationship', ->
  oldGetActiveApp = null
  server = null
  organizations = null
  people = null
  automobiles = null
  afterEach ->
    window.AP.getActiveApp = oldGetActiveApp
    server.restore()
  beforeEach ->
    # quick and dirty mock application object
    oldGetActiveApp = window.AP.getActiveApp
    activeApp =
      getModel: (name) -> AP.model[name]
      getCollection: (name) -> AP.collection[name]
    window.AP.getActiveApp = -> activeApp
    # models
    class AP.model.Organization extends AP.model.Model
      urlRoot: '/organization/'
      relationshipDefinitions: [
        type: 'HasMany'
        model: 'Person'
        collection: 'PersonAll'
        name: 'people'
        foreignKey: 'organization_id'
      ]
    class AP.model.Person extends AP.model.Model
      urlRoot: '/person/'
      relationshipDefinitions: [
        type: 'BelongsTo'
        model: 'Organization'
        collection: 'OrganizationAll'
        name: 'organization'
        foreignKey: 'organization_id'
      ,
        type: 'HasOne'
        model: 'Automobile'
        collection: 'AutomobileAll'
        name: 'automobile'
        foreignKey: 'person_id'
      ]
    class AP.model.Automobile extends AP.model.Model
      urlRoot: '/automobile/'
    # collections
    class AP.collection.OrganizationAll extends AP.collection.ScopeCollection
      @collectionId: 'organization'
      model: AP.model.Organization
      url: '/organization/'
    class AP.collection.PersonAll extends AP.collection.ScopeCollection
      @collectionId: 'person'
      model: AP.model.Person
      apiEndpoint: '/person/'
    class AP.collection.AutomobileAll extends AP.collection.ScopeCollection
      @collectionId: 'automobile'
      model: AP.model.Automobile
      apiEndpoint: '/automobile/'
    organizations = new AP.collection.OrganizationAll
    people = new AP.collection.PersonAll
    automobiles = new AP.collection.AutomobileAll
    # fake server
    server = sinon.fakeServer.create()
    # fake responses
    server.respondWith 'GET', '/organization/',
      [
        200
        {'Content-Type': 'application/json'}
        '[{"id": "1", "name": "Acme Co."}, {"id": "2", "name": "Acme Co."}, {"id": "3", "name": "Acme Co."}]'
      ]
    server.respondWith 'GET', '/organization/?query%5Bid%5D=1',
      [
        200
        {'Content-Type': 'application/json'}
        '[{"id": "1", "name": "Acme Co."}]'
      ]
    server.respondWith 'GET', '/person/',
      [
        200
        {'Content-Type': 'application/json'}
        '[{"id": "1", "organization_id": "1"}, {"id": "2", "organization_id": "1"}, {"id": "3", "organization_id": "2"}, {"id": "4", "organization_id": "2"}]'
      ]
    server.respondWith 'GET', '/person/?query%5Borganization_id%5D=1',
      [
        200
        {'Content-Type': 'application/json'}
        '[{"id": "1", "organization_id": "1"}, {"id": "2", "organization_id": "1"}]'
      ]
    server.respondWith 'GET', '/automobile/',
      [
        200
        {'Content-Type': 'application/json'}
        '[{"id": "1", "person_id": "1"}, {"id": "2", "person_id": "2"}]'
      ]
    server.respondWith 'GET', '/automobile/?query%5Bperson_id%5D=1',
      [
        200
        {'Content-Type': 'application/json'}
        '[{"id": "1", "person_id": "1"}]'
      ]
  
  describe 'test server', ->
    it 'should work', ->
      organizations.fetch()
      people.fetch()
      server.respond()
      organizationPeople = organizations.first().get 'people'
      organizations.first().fetchRelated 'people'
      server.respond()
      assert.equal organizations.size(), 3
      assert.equal organizationPeople.size(), 2
      assert.equal people.size(), 4
  
  describe 'AP.relationship.HasMany', ->
    describe 'model serialization with toJSON()', ->
      it 'should return a nested object', ->
        organizations.fetch()
        server.respond()
        org = organizations.first()
        org.fetchRelated 'people'
        server.respond()
        assert.deepEqual org.toJSON(), {
          id: '1'
          name: 'Acme Co.'
          people: [
            id: '1'
            organization_id: '1'
            organization: null
            automobile: null
          ,
            id: '2'
            organization_id: '1'
            organization: null
            automobile: null
          ]
        }
    describe 'generated attribute field on owner instance', ->
      it 'should be of the specfied class', ->
        organizations.fetch()
        server.respond()
        assert.isDefined organizations.first().get('people')
        assert.instanceOf organizations.first().get('people'), AP.collection.PersonAll
      it 'should contain only related items with foreign keys matching owner id', ->
        organizations.fetch()
        server.respond()
        owner = organizations.first()
        owner.fetchRelated 'people'
        server.respond()
        ownerPeople = owner.get 'people'
        relationship = owner.getRelationship 'people'
        ownerPeople.each (person) ->
          assert.equal owner.get(owner.idAttribute), person.get(relationship.foreignKey)
    describe 'relationship collection', ->
      it 'should set an instance foreign key to owner ID when added to collection', ->
        organizations.fetch()
        people.fetch()
        server.respond()
        owner = organizations.first()
        owner.fetchRelated 'people'
        server.respond()
        ownerPeople = owner.get 'people'
        relationship = owner.getRelationship 'people'
        whereClause = {}
        whereClause[relationship.foreignKey] = '2'
        unrelatedPerson = people.findWhere(whereClause)
        assert.equal owner.get(owner.idAttribute), '1'
        assert.equal unrelatedPerson.get(relationship.foreignKey), '2'
        ownerPeople.add unrelatedPerson
        assert.equal unrelatedPerson.get(relationship.foreignKey), '1'
      it 'should set an instance foreign key to null when removed from collection', ->
        organizations.fetch()
        server.respond()
        owner = organizations.first()
        owner.fetchRelated 'people'
        server.respond()
        ownerPeople = owner.get 'people'
        relationship = owner.getRelationship 'people'
        assert.equal owner.get(owner.idAttribute), '1'
        person = ownerPeople.first()
        assert.equal person.get(relationship.foreignKey), '1'
        ownerPeople.remove person
        assert.equal person.get(relationship.foreignKey), null
      it 'should remove an instance from collection when its foreign key is changed and no longer equal to owner ID', ->
        organizations.fetch()
        server.respond()
        owner = organizations.first()
        owner.fetchRelated 'people'
        server.respond()
        ownerPeople = owner.get 'people'
        relationship = owner.getRelationship 'people'
        assert.equal owner.get(owner.idAttribute), '1'
        person = ownerPeople.first()
        assert.equal person.get(relationship.foreignKey), '1'
        person.set(relationship.foreignKey, '1')
        assert.equal person.get(relationship.foreignKey), '1'
        assert.isTrue ownerPeople.contains person
        person.set(relationship.foreignKey, '2')
        assert.equal person.get(relationship.foreignKey), '2'
        assert.isFalse ownerPeople.contains person
  
  describe 'AP.relationship.HasOne', ->
    describe 'model serialization with toJSON()', ->
      it 'should return a nested object', ->
        people.fetch()
        server.respond()
        person = people.first()
        person.fetchRelated 'automobile'
        server.respond()
        assert.deepEqual person.toJSON(), {
          id: '1'
          organization_id: '1'
          organization: null
          automobile:
            id: '1'
            person_id: '1'
        }
    describe 'generated attribute field on owner instance', ->
      it 'should be null before load', ->
        people.fetch()
        server.respond()
        assert.isNull people.first().get('automobile')
      it 'should be an automobile instance after load', ->
        people.fetch()
        server.respond()
        person = people.first()
        person.fetchRelated 'automobile'
        server.respond()
        assert.instanceOf person.get('automobile'), AP.model.Automobile
      it 'should be set to null when related instance foreign key is changed and no longer equal to owner ID', ->
        people.fetch()
        server.respond()
        person = people.first()
        relationship = person.getRelationship 'automobile'
        person.fetchRelated 'automobile'
        server.respond()
        related = person.get 'automobile'
        assert.equal person.get('automobile').get(related.idAttribute), related.get(related.idAttribute)
        assert.equal person.get(person.idAttribute), related.get(relationship.foreignKey)
        related.set(relationship.foreignKey, 'foobars')
        assert.equal person.get('automobile'), null
        assert.notEqual person.get(person.idAttribute), related.get(relationship.foreignKey)
    describe 'foreign key field', ->
      it 'should be set to the ID of instance in generated attribute field', ->
        people.fetch()
        automobiles.fetch()
        server.respond()
        person = people.first()
        auto2 = automobiles.models[1]
        relationship = person.getRelationship 'automobile'
        person.fetchRelated 'automobile'
        server.respond()
        related = person.get 'automobile'
        assert.equal person.get(person.idAttribute), related.get(relationship.foreignKey)
        assert.notEqual related.get(relationship.foreignKey), auto2.get(relationship.foreignKey)
        person.set('automobile', auto2)
        assert.equal person.get(person.idAttribute), auto2.get(relationship.foreignKey)
  
  describe 'AP.relationship.BelongsTo', ->
    describe 'model serialization with toJSON()', ->
      it 'should return a nested object', ->
        people.fetch()
        server.respond()
        person = people.first()
        person.fetchRelated 'organization'
        server.respond()
        assert.deepEqual person.toJSON(), {
          id: '1'
          organization_id: '1'
          automobile: null
          organization:
            id: '1'
            name: 'Acme Co.'
            people: []
        }
    describe 'generated attribute field on owner instance', ->
      it 'should be null before load', ->
        people.fetch()
        server.respond()
        assert.isNull people.first().get('organization')
      it 'should be an organization instance after load', ->
        people.fetch()
        server.respond()
        person = people.first()
        person.fetchRelated 'organization'
        server.respond()
        assert.instanceOf person.get('organization'), AP.model.Organization
      it 'should be set to null when owner foreign key is changed and no longer equal to related instance ID', ->
        people.fetch()
        server.respond()
        person = people.first()
        relationship = person.getRelationship 'organization'
        person.fetchRelated 'organization'
        server.respond()
        related = person.get 'organization'
        assert.equal person.get('organization'), related
        assert.equal person.get(relationship.foreignKey), related.get(related.idAttribute)
        person.set(relationship.foreignKey, null)
        assert.notEqual person.get('organization'), related
        assert.notEqual person.get(relationship.foreignKey), related.get(related.idAttribute)
    describe 'foreign key field', ->
      it 'should be set to the ID of instance in generated attribute field', ->
        people.fetch()
        organizations.fetch()
        server.respond()
        person = people.first()
        org2 = organizations.models[1]
        relationship = person.getRelationship 'organization'
        person.fetchRelated 'organization'
        server.respond()
        related = person.get 'organization'
        assert.equal person.get(relationship.foreignKey), related.get(related.idAttribute)
        assert.notEqual related.get(related.idAttribute), org2.get(org2.idAttribute)
        person.set('organization', org2)
        assert.notEqual person.get(relationship.foreignKey), related.get(related.idAttribute)
        assert.equal person.get(relationship.foreignKey), org2.get(org2.idAttribute)
