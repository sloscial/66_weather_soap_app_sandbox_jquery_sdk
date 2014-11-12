# Superclass interface for transient storage mechanisms such as cookies and/or
# expiring local storage.
class AP.utility.TransientStore
  namespace: 'ap' # appended to all keys
  expiresAfter: 7 # default expires after, in days
  _data: null

  constructor: (options = {}) ->
    @namespace = options?.namespace or @namespace
    @expiresAfter = options?.expiresAfter or @expiresAfter
    @_data = {}

  # override the following three methods in subclasses
  getFromUnderlayingStorage: (qualifiedKey) ->
    @_data[qualifiedKey]

  setToUnderlayingStorage: (qualifiedKey, value, expirationDate) ->
    @_data[qualifiedKey] = value

  removeFromUnderlayingStorage: (qualifiedKey) ->
    delete @_data[qualifiedKey]

  encodeValue: (value) ->
    encoded = JSON.stringify([value])
    AP.utility.Base64.encode encoded

  decodeValue: (value) ->
    decoded = AP.utility.Base64.decode value if value
    try
      decoded = JSON.parse decoded
    catch error
      # pass
    decoded?[0]
  
  getKeyString: (key) ->
    strKey = @encodeValue key
    strKey
  
  getQualifiedKey: (key) ->
    strKey = @getKeyString key
    "#{@namespace}-#{strKey}"

  getQualifiedExpireKey: (key) ->
    strKey = @getKeyString key
    "#{@namespace}-expire-#{strKey}"

  getExpirationDate: (days) ->
    d = new Date()
    d.setTime d.getTime() + (days * 86400000)
    d
  
  get: (key) ->
    qKey = @getQualifiedKey key
    expireKey = @getQualifiedExpireKey key
    record = @getFromUnderlayingStorage qKey
    expire = parseInt(@decodeValue(@getFromUnderlayingStorage(expireKey)), 10) if @getFromUnderlayingStorage(expireKey)
    if _.isNumber(expire) and (expire <= Date.now())
      @remove key
      record = @getFromUnderlayingStorage qKey
    @decodeValue record

  set: (key, value, expiresAfter) ->
    qKey = @getQualifiedKey key
    expireKey = @getQualifiedExpireKey key
    expirationDate = @getExpirationDate(expiresAfter or @expiresAfter)
    @setToUnderlayingStorage qKey, @encodeValue(value), expirationDate
    @setToUnderlayingStorage expireKey, @encodeValue(expirationDate.getTime()), expirationDate

  remove: (key) ->
    qKey = @getQualifiedKey key
    expireKey = @getQualifiedExpireKey key
    @removeFromUnderlayingStorage qKey
    @removeFromUnderlayingStorage expireKey
