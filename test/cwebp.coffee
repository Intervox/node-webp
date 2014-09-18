{cwebp: bin} = require 'webp'
fs = require 'fs'

{CWebp} = require '../src'

data = 'iVBORw0KGgoAAAANSUhEUgAAADwAAAA8AQMAAAAAMksxAAAAA1BMVEX/pQDKkkGbAAAAD0lEQVQoz2NgGAWjADsAAAIcAAE79LKOAAAAAElFTkSuQmCC'
corrupt = '/9j/4AAQSkZJRgABAQEASABIAAD/7gAOQWRvYmUAZH//Z'

describe 'CWebp', ->

  describe 'main', ->

    it 'should allow default bin rewriting', ->
      class Webp2 extends CWebp
        @bin: bin
      webp = new Webp2 new Buffer data, 'base64'
      webp.toBuffer().then (buffer) ->
        buffer.toString('utf8', 0, 4).should.be.equal 'RIFF'
        buffer.toString('utf8', 8, 12).should.be.equal 'WEBP'

    it 'should accept bin as a constructor option', ->
      webp = new CWebp (new Buffer data, 'base64'), bin
      webp.toBuffer().then (buffer) ->
        buffer.toString('utf8', 0, 4).should.be.equal 'RIFF'
        buffer.toString('utf8', 8, 12).should.be.equal 'WEBP'

    it 'should report verbose errors', ->
      webp = new CWebp (new Buffer corrupt, 'base64'), bin
      webp.verbose().toBuffer().then ->
        throw new Error 'Should not be fulfilled'
      , (err) ->
        err.should.be.Error
        err.message.should.match /Premature end of JPEG file/
        err.message.should.match /JPEG datastream contains no image/

    it 'should allow default verbose rewriting', ->
      class Webp3 extends CWebp
        @bin: bin
        @verbose: true
      webp = new Webp3 (new Buffer corrupt, 'base64'), bin
      webp.toBuffer().then ->
        throw new Error 'Should not be fulfilled'
      , (err) ->
        err.should.be.Error
        err.message.should.match /Premature end of JPEG file/
        err.message.should.match /JPEG datastream contains no image/

    it 'should cleanup tmp files on error', ->
      filename = ''
      webp = new CWebp (new Buffer corrupt, 'base64'), bin
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
