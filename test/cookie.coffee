assert = chai.assert


describe 'AP.utility.Cookie', ->
  oldGetFrom = AP.utility.Cookie.getFromCookieStorage
  oldSaveTo = AP.utility.Cookie.saveToCookieStorage
  mockCookie = null
  beforeEach ->
    mockCookie = ''
    AP.utility.Cookie.getFromCookieStorage = -> mockCookie.toString()
    AP.utility.Cookie.saveToCookieStorage = (cookie) -> mockCookie = cookie
  afterEach ->
    AP.utility.Cookie.getFromCookieStorage = oldGetFrom
    AP.utility.Cookie.saveToCookieStorage = oldSaveTo
  describe 'formatCookieStorageDate()', ->
    it 'should return undefined if no arguments passed', ->
      assert.isUndefined AP.utility.Cookie.formatCookieStorageDate()
    it 'should format a date for use with underlaying cookie storage', ->
      assert.match AP.utility.Cookie.formatCookieStorageDate(1), /\w{3}, \d{2} \w{3} \d{4} \d{2}:\d{2}:\d{2} \w{3}/
  describe 'buildCookieStorageString()', ->
    it 'should format a string from name and value for use with underlaying cookie storage', ->
      assert.equal AP.utility.Cookie.buildCookieStorageString('key', 'value'), 'key=value; path=/'
    it 'should format a string from name, value, and days for use with underlaying cookie storage', ->
      assert.match AP.utility.Cookie.buildCookieStorageString('key', 'value', 1), /key=value; expires=\w{3}, \d{2} \w{3} \d{4} \d{2}:\d{2}:\d{2} \w{3}; path=\//
  describe 'get()', ->
    it 'should return a cookie if previously set', ->
      AP.utility.Cookie.set('key', 'value')
      assert.equal AP.utility.Cookie.get('key'), 'value'
    it 'should return null if not previously set', ->
      assert.isNull AP.utility.Cookie.get('no-such-cookie')
  describe 'set()', ->
    it 'should save a cookie to the underlaying cookie storage', ->
      assert.equal mockCookie, ''
      AP.utility.Cookie.set('key', 'value')
      assert.equal mockCookie, 'key=value; path=/'
