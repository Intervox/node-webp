fs = require 'fs'

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

    it 'should report verbose errors', ->
      webp = new CWebp data.corrupt
      webp.verbose().toBuffer().then ->
        throw new Error 'Should not be fulfilled'
      , (err) ->
        err.should.be.Error
        err.message.should.match /Premature end of JPEG file/
        err.message.should.match /JPEG datastream contains no image/

    it 'should allow default verbose rewriting', ->
      class Webp3 extends CWebp
        @verbose: true
      webp = new Webp3 data.corrupt
      webp.toBuffer().then ->
        throw new Error 'Should not be fulfilled'
      , (err) ->
        err.should.be.Error
        err.message.should.match /Premature end of JPEG file/
        err.message.should.match /JPEG datastream contains no image/

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
