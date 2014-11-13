class AP.utility.TransientCookieStore extends AP.utility.TransientStore
  @supported: (->
    supported = window.document.cookie?
    # test for cookie support by setting and getting a cookie
    if supported
      key = _.uniqueId 'ap-cookie-support-test'
      value = 'success'
      AP.utility.Cookie.set key, value
      actualValue = AP.utility.Cookie.get key
      supported = false if value != actualValue
    supported
  )()
  
  getFromUnderlayingStorage: (qualifiedKey) ->
    value = super
    value = AP.utility.Cookie.get qualifiedKey if AP.utility.TransientCookieStore.supported
    value
  
  setToUnderlayingStorage: (qualifiedKey, value, expirationDate) ->
    super
    AP.utility.Cookie.set qualifiedKey, value, expirationDate if AP.utility.TransientCookieStore.supported
  
  removeFromUnderlayingStorage: (qualifiedKey) ->
    super
    AP.utility.Cookie.del qualifiedKey if AP.utility.TransientCookieStore.supported
