assert = chai.assert


describe 'AP', ->
  beforeEach ->
    AP.registerApp({}, 'App1')
  describe 'registerApp()', ->
    it 'should add an object to the apps object', ->
      assert.deepEqual AP.apps.App1, {}
  describe 'getApp()', ->
    it 'should return an app by name', ->
      assert.deepEqual AP.getApp('App1'), {}
