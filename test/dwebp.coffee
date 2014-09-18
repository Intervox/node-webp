{dwebp: bin} = require 'webp'
fs = require 'fs'

{DWebp} = require '../src'

data = 'UklGRlAAAABXRUJQVlA4IEQAAAAQBACdASo8ADwAPpFIoEwlpCMiIggAsBIJaQB2APwAACBupqAK8QtyAAD+7JeP//rK/mV/Mr/fI///G7cYb70AAAAAAA'
corrupt = '/9j/4AAQSkZJRgABAQEASABIAAD/7gAOQWRvYmUAZH//Z'

describe 'Webp', ->

  describe 'main', ->

    it 'should allow default bin rewriting', ->
      class Webp2 extends DWebp
        @bin: bin
      webp = new Webp2 new Buffer data, 'base64'
      webp.toBuffer().then (buffer) ->
        buffer.toString('utf8', 1, 4).should.be.equal 'PNG'

    it 'should accept bin as a constructor option', ->
      webp = new DWebp (new Buffer data, 'base64'), bin
      webp.toBuffer().then (buffer) ->
        buffer.toString('utf8', 1, 4).should.be.equal 'PNG'

    it 'should report errors', ->
      webp = new DWebp (new Buffer corrupt, 'base64'), bin
      webp.toBuffer().then ->
        throw new Error 'Should not be fulfilled'
      , (err) ->
        err.should.be.Error
        err.message.should.match /Status: 3 \(BITSTREAM_ERROR\)/

    it 'should cleanup tmp files on error', ->
      filename = ''
      webp = new DWebp (new Buffer corrupt, 'base64'), bin
      promise = webp.toBuffer()
      webp._tmpFilename.then (tmpFilename) ->
        filename = tmpFilename
        filename.should.not.be.empty
        fs.existsSync(filename).should.be.true
        promise
      .then ->
        throw new Error 'Should not be fulfilled'
      , (err) ->
        err.should.be.Error
        filename.should.not.be.empty
        fs.existsSync(filename).should.be.false
