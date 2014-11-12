###*
Simplifies interaction with browser cookies.
@module AP
@submodule utility
@class Cookie
@static
###
class AP.utility.Cookie
  ###*
  @method getFromCookieStorage
  @static
  @return {String} a copy of the raw cookie string
  ###
  @getFromCookieStorage: -> document.cookie.toString()
  
  ###*
  Saves cookie to document cookies.
  @method saveToCookieStorage
  @static
  @param {String} cookie a formatted cookie-string to save to document cookies
  ###
  @saveToCookieStorage: (cookie) -> document.cookie = cookie
  
  ###*
  Formats an expiration date for a cookie string.
  @method formatCookieStorageDate
  @static
  @param {Integer/Date} expiration number of days from today after which to
  expire cookie *or* a JavaScript `Date` of the absolute expiration date.
  ###
  @formatCookieStorageDate: (expiration) ->
    if _.isNumber expiration
      d = new Date()
      d.setTime d.getTime() + (expiration * 86400000)
      expiration = d
    expiration.toGMTString() if _.isDate expiration
  
  ###*
  Builds a formatted cookie-string for saving to `document.cookies`.
  @method buildCookieStorageString
  @static
  @param {String} n name of cookie
  @param {String} v value of cookie
  @param {Integer/Date} expiration optional number of days from today after
  which to expire cookie *or* a JavaScript `Date` of the absolute
  expiration date.
  ###
  @buildCookieStorageString: (n, v, expiration) ->
    e = ''
    if expiration
      e = '; expires=' + @formatCookieStorageDate(expiration)
    n + '=' + v + e + '; path=/'
  
  ###*
  Saves a cookie to `document.cookies`.
  @method set
  @static
  @param {String} n name of cookie
  @param {String} v value of cookie
  @param {Integer/Date} expiration optional number of days from today after
  which to expire cookie *or* a JavaScript `Date` of the absolute
  expiration date.
  ###
  @set: (n, v, expiration) ->
    cookie = @buildCookieStorageString n, v, expiration
    @saveToCookieStorage cookie
  
  ###*
  Returns a cookie with name `n` from underlaying cookie
  storage, `document.cookie`.
  @method get
  @static
  @param {String} n name of cookie
  @return {String} the cookie value, if any
  ###
  @get: (n) ->
    ca = @getFromCookieStorage().split ';'
    match = n + '='
    c = ''
    i = 0
    while i < ca.length
      c = ca[i].replace /^\s*/, ''
      if c.indexOf(match) is 0
        return c.substring match.length, c.length
      i++
    null
  
  ###*
  Deletes a cookie with name `n` from underlaying cookie storage.
  @method del
  @static
  @param {String} n name of cookie
  ###
  @del: (n) ->
    @set n, '', -1
