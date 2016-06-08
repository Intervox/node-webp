fs = require 'fs'
os = require 'os'

{CWebp} = require '../src'
data = require './utils/data'

describe 'cwebp', ->

  describe 'cwebp', ->

    it 'should encode images', ->
      webp = new CWebp data.jpeg
      webp.toBuffer().then (buffer) ->
        buffer.toString('utf8', 0, 4).should.be.equal 'RIFF'
        buffer.toString('utf8', 8, 12).should.be.equal 'WEBP'

    it 'should work without new', ->
      webp = CWebp data.jpeg
      webp.toBuffer().then (buffer) ->
        buffer.toString('utf8', 0, 4).should.be.equal 'RIFF'
        buffer.toString('utf8', 8, 12).should.be.equal 'WEBP'

    it 'should report errors', ->
      webp = new CWebp data.corrupt
      webp.toBuffer().then ->
        throw new Error 'Should not be fulfilled'
      , (err) ->
        err.should.be.Error
        err.message.should.match /Could not process file/
        err.message.should.match /Cannot read input picture file/

    it 'should cleanup tmp files on error', ->
      filename = ''
      webp = new CWebp data.corrupt
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
