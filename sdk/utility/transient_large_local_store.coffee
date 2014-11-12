class AP.utility.TransientLargeLocalStore extends AP.utility.TransientStore
  @supported: window.LargeLocalStorage?
  storage: null
  storageCapacity: 64 * 1024 * 1024 # request capacity in bytes
  storageName: 'large-local-storage' # name for underlaying storage

  constructor: ->
    super
    if AP.utility.TransientLargeLocalStore.supported
      @storage = new LargeLocalStorage
        size: @storageCapacity
        name: "#{@namespace}-#{@storageName}"

  getFromUnderlayingStorage: (qualifiedKey) ->
    if @storage? and AP.utility.TransientLargeLocalStore.supported
      @storage.initialized.then => @storage.getContents qualifiedKey
    else
      super

  setToUnderlayingStorage: (qualifiedKey, value, expirationDate) ->
    if @storage? and AP.utility.TransientLargeLocalStore.supported
      @storage.initialized.then => @storage.setContents qualifiedKey, value
    else
      super

  removeFromUnderlayingStorage: (qualifiedKey) ->
    if @storage? and AP.utility.TransientLargeLocalStore.supported
      @storage.initialized.then => @storage.rm qualifiedKey
    else
      super

  get: (key, options={}) ->
    qKey = @getQualifiedKey key
    expireKey = @getQualifiedExpireKey key
    callback = (value) ->
      if value?
        # there is a value:  success callback
        options.success value if _.isFunction options.success
      else if _.isFunction options.error
        # there is no value:  error callback
        options.error()
    if @storage? and (_.isFunction options.success or _.isFunction options.error)
      @storage?.initialized.then =>
        @getFromUnderlayingStorage(qKey).then (record) =>
          @getFromUnderlayingStorage(expireKey).then (expireRecord) =>
            expire = +@decodeValue(expireRecord) if expireRecord
            if _.isNumber(expire) and (expire <= Date.now())
              @remove key
              record = null
            value = @decodeValue record
            callback(value)
    else
      callback(super)
