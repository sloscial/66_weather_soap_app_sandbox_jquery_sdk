class AP.utility.TransientLocalStore extends AP.utility.TransientStore
  @supported: window.localStorage?
  storage: window.localStorage
  
  getFromUnderlayingStorage: (qualifiedKey) ->
    value = super
    value = @storage.getItem qualifiedKey if AP.utility.TransientLocalStore.supported
    value
  
  setToUnderlayingStorage: (qualifiedKey, value, expirationDate) ->
    super
    @storage.setItem qualifiedKey, value if AP.utility.TransientLocalStore.supported
  
  removeFromUnderlayingStorage: (qualifiedKey) ->
    super
    @storage.removeItem qualifiedKey if AP.utility.TransientLocalStore.supported
