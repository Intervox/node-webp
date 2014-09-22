{CWebp, DWebp} = require '../src'
data = require './utils/data'

describe 'round trip', ->

  describe 'using toBuffer', ->

    it 'should round trip jpeg image', ->
      encoder = new CWebp data.jpeg
      encoder.toBuffer().then (buffer) ->
        decoder = new DWebp buffer
        decoder.toBuffer()
      .then (buffer) ->
        buffer.toString('utf8', 1, 4).should.be.equal 'PNG'

    it 'should round trip webp image', ->
      decoder = new DWebp data.webp
      decoder.toBuffer().then (buffer) ->
        encoder = new CWebp buffer
        encoder.toBuffer()
      .then (buffer) ->
        buffer.toString('utf8', 0, 4).should.be.equal 'RIFF'
        buffer.toString('utf8', 8, 12).should.be.equal 'WEBP'

  describe 'streaming', ->

    it 'should round trip jpeg image', ->
      encoder = new CWebp data.jpeg
      encoder.stream().then (stream) ->
        decoder = new DWebp stream
        decoder.toBuffer()
      .then (buffer) ->
        buffer.toString('utf8', 1, 4).should.be.equal 'PNG'

    it 'should round trip webp image', ->
      decoder = new DWebp data.webp
      decoder.stream().then (stream) ->
        encoder = new CWebp stream
        encoder.toBuffer()
      .then (buffer) ->
        buffer.toString('utf8', 0, 4).should.be.equal 'RIFF'
        buffer.toString('utf8', 8, 12).should.be.equal 'WEBP'
