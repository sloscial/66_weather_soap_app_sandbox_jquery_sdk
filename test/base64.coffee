assert = chai.assert


describe 'AP.utility.Base64', ->
  describe 'encode()', ->
    it 'should return an base64-encoded string', ->
      assert.notEqual 'hello world', AP.utility.Base64.encode('hello world')
      assert.equal 'aGVsbG8gd29ybGQ=', AP.utility.Base64.encode('hello world')
  
  describe 'decode()', ->
    it 'should return an base64-decoded string', ->
      assert.notEqual 'aGVsbG8gd29ybGQ=', AP.utility.Base64.decode('aGVsbG8gd29ybGQ=')
      assert.equal 'hello world', AP.utility.Base64.decode('aGVsbG8gd29ybGQ=')
