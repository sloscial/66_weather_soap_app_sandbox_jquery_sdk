assert = chai.assert


describe 'AP.utility.Validator', ->
  validator = null
  data =
    name: 'John Doe'
    age: 36
    hasDog: true
    netWorth: -1.50
    amount: '1.5'
  validations = [
    field: 'name'
    validate: 'required'
  ,
    field: 'name'
    validate: 'type'
    is: 'string'
  ,
    field: 'age'
    validate: 'type'
    is: 'integer'
  ,
    field: 'age'
    validate: 'numericality'
  ,
    field: 'hasDog'
    validate: 'type'
    is: 'boolean'
  ,
    field: 'netWorth'
    validate: 'type'
    is: 'float'
  ,
    field: 'netWorth'
    validate: 'numericality'
  ,
    field: 'amount'
    validate: 'numericality'
  ]
  beforeEach ->
    validator = new AP.utility.Validator data, validations
  describe 'constructor()', ->
    it 'should accept data and validations', ->
      assert.deepEqual data, validator.data
      assert.deepEqual validations, validator.validations
  describe 'isValid()', ->
    it 'should return true for valid data', ->
      validator.validate()
      assert.isTrue validator.isValid()
    it 'should return false for invalid data', ->
      validator.data = {hasDog: false}
      validator.validate()
      assert.isFalse validator.isValid()
  describe 'validate()', ->
    it 'should return the value of isValid() if validate is called first', ->
      assert.equal validator.validate(), validator.isValid()
      validator.data = {hasDog: false}
      assert.equal validator.validate(), validator.isValid()
    it 'should run sepcified validations', ->
      calledRequiredValidation = false
      calledTypeValidation = false
      validator.required = -> calledRequiredValidation = true
      validator.type = -> calledTypeValidation = true
      validator.validate()
      assert.isTrue calledRequiredValidation
      assert.isTrue calledTypeValidation
  describe 'addError()', ->
    it 'should add errors to the errors array', ->
      assert.lengthOf validator.errors(), 0
      validator.addError 'name', 'required'
      assert.lengthOf validator.errors(), 1
  describe 'errors()', ->
    it 'should be an array of 0 or more length', ->
      validator.validate()
      assert.isArray validator.errors()
      assert.lengthOf validator.errors(), 0
      validator.data = {hasDog: false}
      validator.validate()
      assert.isArray validator.errors()
      assert.lengthOf validator.errors(), 1
  describe 'required()', ->
    it 'should validate the presence of a field', ->
      assert.lengthOf validator.errors(), 0
      validator.required('hello world', {field: 'title'})
      assert.lengthOf validator.errors(), 0
      validator.required(undefined, {field: 'title'})
      assert.lengthOf validator.errors(), 1
      validator.required('', {field: 'title'})
      assert.lengthOf validator.errors(), 1
  describe 'numericality()', ->
    it 'should validate the numericality of a field of both string and number types', ->
      assert.lengthOf validator.errors(), 0
      validator.numericality('-1.693', {field: 'amount'})
      assert.lengthOf validator.errors(), 0
      validator.numericality('+3057.693', {field: 'amount'})
      assert.lengthOf validator.errors(), 0
      validator.numericality('500', {field: 'amount'})
      assert.lengthOf validator.errors(), 0
      validator.numericality(-1.693, {field: 'amount'})
      assert.lengthOf validator.errors(), 0
      validator.numericality(3057.693, {field: 'amount'})
      assert.lengthOf validator.errors(), 0
      validator.numericality(500, {field: 'amount'})
      assert.lengthOf validator.errors(), 0
      validator.numericality('hello world', {field: 'amount'})
      assert.lengthOf validator.errors(), 1
  describe 'type()', ->
    it 'should validate the type of a field', ->
      assert.lengthOf validator.errors(), 0
      validator.type('hello world', {is: 'string', field: 'title'})
      assert.lengthOf validator.errors(), 0
      validator.type('hello world', {is: 'number', field: 'title'})
      assert.lengthOf validator.errors(), 1
      validator.type(1, {is: 'number', field: 'title'})
      assert.lengthOf validator.errors(), 1
  describe 'booleanType()', ->
    it 'should validate that the type of a field is boolean', ->
      assert.lengthOf validator.errors(), 0
      validator.type(true, {is: 'boolean', field: 'title'})
      assert.lengthOf validator.errors(), 0
      validator.type('hello world', {is: 'boolean', field: 'title'})
      assert.lengthOf validator.errors(), 1
  describe 'stringType()', ->
    it 'should validate that the type of a field is string', ->
      assert.lengthOf validator.errors(), 0
      validator.type('hello world', {is: 'string', field: 'title'})
      assert.lengthOf validator.errors(), 0
      validator.type(true, {is: 'string', field: 'title'})
      assert.lengthOf validator.errors(), 1
  describe 'numberType()', ->
    it 'should validate that the type of a field is number', ->
      assert.lengthOf validator.errors(), 0
      validator.type(1, {is: 'number', field: 'title'})
      validator.type(1.5, {is: 'number', field: 'title'})
      assert.lengthOf validator.errors(), 0
      validator.type('hello world', {is: 'number', field: 'title'})
      assert.lengthOf validator.errors(), 1
  describe 'floatType()', ->
    it 'should validate that the type of a field is number', ->
      assert.lengthOf validator.errors(), 0
      validator.type(1, {is: 'float', field: 'title'})
      validator.type(1.5, {is: 'float', field: 'title'})
      assert.lengthOf validator.errors(), 0
      validator.type('hello world', {is: 'float', field: 'title'})
      assert.lengthOf validator.errors(), 1
  describe 'integerField()', ->
    it 'should validate that the type of a field is number and integer', ->
      assert.lengthOf validator.errors(), 0
      validator.type(1, {is: 'integer', field: 'title'})
      assert.lengthOf validator.errors(), 0
      validator.type(1.5, {is: 'integer', field: 'title'})
      validator.type('hello world', {is: 'integer', field: 'title'})
      assert.lengthOf validator.errors(), 2
  describe 'dateType()', ->
    it 'should validate that the type of a field is date (with time 00:00:00)'
  describe 'timeType()', ->
    it 'should validate that the type of a field is date'
