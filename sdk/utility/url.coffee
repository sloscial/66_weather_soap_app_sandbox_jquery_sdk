###*
Utility singleton for working with URLs and paths.
@module AP
@submodule utility
@class Url
@static
@private
###
class AP.utility.Url
  ###*
  @method parseUrl
  @static
  @param {String} url the URL to parse
  @return {Object} the bits and pieces of a URL as key/value pairs
  ###
  @parseUrl: (url) ->
    path =
      urlParseRE: /^\s*(((([^:\/#\?]+:)?(?:(\/\/)((?:(([^:@\/#\?]+)(?:\:([^:@\/#\?]+))?)@)?(([^:\/#\?\]\[]+|\[[^\/\]@#?]+\])(?:\:([0-9]+))?))?)?)?((\/?(?:[^\/\?#]+\/+)*)([^\?#]*)))?(\?[^#]+)?)(#.*)?/
      getLocation: (url) ->
        uri = if url then this.parseUrl(url) else location
        hash = this.parseUrl(url || location.href).hash
        hash = if hash == '#' then '' else hash
        return uri.protocol + '//' + uri.host + uri.pathname + uri.search + hash
    return url if $.type(url) == 'object'
    matches = path.urlParseRE.exec(url || '') || []
    {
      href:         matches[  0 ] || ''
      hrefNoHash:   matches[  1 ] || ''
      hrefNoSearch: matches[  2 ] || ''
      domain:       matches[  3 ] || ''
      protocol:     matches[  4 ] || ''
      doubleSlash:  matches[  5 ] || ''
      authority:    matches[  6 ] || ''
      username:     matches[  8 ] || ''
      password:     matches[  9 ] || ''
      host:         matches[ 10 ] || ''
      hostname:     matches[ 11 ] || ''
      port:         matches[ 12 ] || ''
      pathname:     matches[ 13 ] || ''
      directory:    matches[ 14 ] || ''
      filename:     matches[ 15 ] || ''
      search:       matches[ 16 ] || ''
      hash:         matches[ 17 ] || ''
    }
