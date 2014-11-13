###*
Utility singleton for encoding and decoding Base64 strings.
@module AP
@submodule utility
@class Base64
@static
@private
###
class AP.utility.Base64
  ###*
  @property _keyStr
  @type String
  @static
  @private
  ###
  @_keyStr: 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/='
  
  ###*
  Encodes an input string to Base64.
  @method encode
  @static
  @param {String} input the string to be Base64-encoded
  @return {String} a Base64-encoded string
  ###
  @encode: (input) ->
    output = ''
    i = 0
    input = Base64._utf8_encode(input)
    while i < input.length
      chr1 = input.charCodeAt(i++)
      chr2 = input.charCodeAt(i++)
      chr3 = input.charCodeAt(i++)
      enc1 = chr1 >> 2
      enc2 = ((chr1 & 3) << 4) | (chr2 >> 4)
      enc3 = ((chr2 & 15) << 2) | (chr3 >> 6)
      enc4 = chr3 & 63
      if isNaN(chr2)
        enc3 = enc4 = 64
      else enc4 = 64  if isNaN(chr3)
      output = output +
        @_keyStr.charAt(enc1) +
        @_keyStr.charAt(enc2) +
        @_keyStr.charAt(enc3) +
        @_keyStr.charAt(enc4)
    output
  
  ###*
  Decodes an input string from Base64.
  @method decode
  @static
  @param {String} input the string to be Base64-decoded
  @return {String} a string decoded from Base64
  ###
  @decode: (input) ->
    output = ''
    i = 0
    input = input.replace(/[^A-Za-z0-9\+\/\=]/g, '')
    while i < input.length
      enc1 = @_keyStr.indexOf(input.charAt(i++))
      enc2 = @_keyStr.indexOf(input.charAt(i++))
      enc3 = @_keyStr.indexOf(input.charAt(i++))
      enc4 = @_keyStr.indexOf(input.charAt(i++))
      chr1 = (enc1 << 2) | (enc2 >> 4)
      chr2 = ((enc2 & 15) << 4) | (enc3 >> 2)
      chr3 = ((enc3 & 3) << 6) | enc4
      output = output + String.fromCharCode(chr1)
      output = output + String.fromCharCode(chr2)  unless enc3 is 64
      output = output + String.fromCharCode(chr3)  unless enc4 is 64
    output = Base64._utf8_decode(output)
    output
  
  ###*
  @private
  @method _utf8_encode
  @static
  ###
  @_utf8_encode: (string) ->
    string = string.replace(/\r\n/g, '\n')
    utftext = ''
    n = 0
    while n < string.length
      c = string.charCodeAt(n)
      if c < 128
        utftext += String.fromCharCode(c)
      else if (c > 127) and (c < 2048)
        utftext += String.fromCharCode((c >> 6) | 192)
        utftext += String.fromCharCode((c & 63) | 128)
      else
        utftext += String.fromCharCode((c >> 12) | 224)
        utftext += String.fromCharCode(((c >> 6) & 63) | 128)
        utftext += String.fromCharCode((c & 63) | 128)
      n++
    utftext
  
  ###*
  @private
  @method _utf8_decode
  @static
  ###
  @_utf8_decode: (utftext) ->
    string = ''
    i = 0
    c = c1 = c2 = 0
    while i < utftext.length
      c = utftext.charCodeAt(i)
      if c < 128
        string += String.fromCharCode(c)
        i++
      else if (c > 191) and (c < 224)
        c2 = utftext.charCodeAt(i + 1)
        string += String.fromCharCode(((c & 31) << 6) | (c2 & 63))
        i += 2
      else
        c2 = utftext.charCodeAt(i + 1)
        c3 = utftext.charCodeAt(i + 2)
        string += String.fromCharCode(((c & 15) << 12) | ((c2 & 63) << 6) | (c3 & 63))
        i += 3
    string
