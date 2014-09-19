{DWebp} = require '../src'
data = require './utils/data'

describe 'dwebp', ->

  describe 'dwebp', ->

    it 'should decode images', ->
      webp = new DWebp data.webp
      webp.toBuffer().then (buffer) ->
        buffer.toString('utf8', 1, 4).should.be.equal 'PNG'

    it 'should work without new', ->
      webp = DWebp data.webp
      webp.toBuffer().then (buffer) ->
        buffer.toString('utf8', 1, 4).should.be.equal 'PNG'

    it 'should report errors', ->
      webp = new DWebp data.corrupt
      webp.toBuffer().then ->
        throw new Error 'Should not be fulfilled'
      , (err) ->
        err.should.be.Error
        err.message.should.match /Status: 3/
        err.message.should.match /\(BITSTREAM_ERROR\)/
