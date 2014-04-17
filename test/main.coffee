{cwebp: bin} = require 'webp'
fs = require 'fs'

{read, write} = require './utils/io'

Webp = require '../src'

data = 'iVBORw0KGgoAAAANSUhEUgAAADwAAAA8AQMAAAAAMksxAAAAA1BMVEX/pQDKkkGbAAAAD0lEQVQoz2NgGAWjADsAAAIcAAE79LKOAAAAAElFTkSuQmCC'
corrupt = '/9j/4AAQSkZJRgABAQEASABIAAD/7gAOQWRvYmUAZH//Z'

describe 'Webp', ->

  describe 'main', ->

    it 'should report an external error', ->
      webp = new Webp 'FAIL'
      write(webp, 'out.json').then ->
        throw new Error 'Should not be fulfilled'
      , (err) ->
        err.should.be.Error
        err.should.have.property 'code', 1
        err.should.have.property 'signal', null
        err.message.should.match /^Command failed: Error: FAIL/

    it 'should report an internal error', ->
      webp = new Webp 'filename'
      write(webp, undefined).then ->
        throw new Error 'Should not be fulfilled'
      , (err) ->
        err.should.be.Error

    it 'should send command', ->
      filename = Math.random().toString(36)
      cmd = Math.random().toString(36)
      webp = (new Webp filename).command cmd
      write(webp, 'out.json').then (argv) ->
        argv.should.have.keys '_', 'o'
        argv._.should.containEql filename
        argv._.should.containEql cmd

    it 'should trigger callback on error', (done) ->
      webp = new Webp 'filename'
      webp.write undefined, (err) ->
        err.should.be.Error
        done()
      return

    it 'should trigger callback on success', (done) ->
      filename = Math.random().toString(36)
      webp = new Webp filename
      webp.write 'out.json', (err) ->
        should(err).not.be.ok
        argv = read 'out.json'
        argv.should.have.keys '_', 'o'
        argv._.should.containEql filename
        done()
      return

    it 'should ignore non-functions passed as callbacks', ->
      filename = Math.random().toString(36)
      (new Webp filename).toBuffer 'not a function'

    it 'should allow default bin rewriting', ->
      class Webp2 extends Webp
        @bin: bin
      webp = new Webp2 new Buffer data, 'base64'
      webp.toBuffer().then (buffer) ->
        buffer.toString('utf8', 0, 4).should.be.equal 'RIFF'
        buffer.toString('utf8', 8, 12).should.be.equal 'WEBP'

    it 'should accept bin as a constructor option', ->
      webp = new Webp (new Buffer data, 'base64'), bin
      webp.toBuffer().then (buffer) ->
        buffer.toString('utf8', 0, 4).should.be.equal 'RIFF'
        buffer.toString('utf8', 8, 12).should.be.equal 'WEBP'

    it 'should report verbose errors', ->
      webp = new Webp (new Buffer corrupt, 'base64'), bin
      webp.verbose().toBuffer().then ->
        throw new Error 'Should not be fulfilled'
      , (err) ->
        err.should.be.Error
        err.message.should.match /Premature end of JPEG file/
        err.message.should.match /JPEG datastream contains no image/

    it 'should allow default verbose rewriting', ->
      class Webp3 extends Webp
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
      webp = new Webp (new Buffer corrupt, 'base64'), bin
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

    it 'should work without new', ->
      filename = Math.random().toString(36)
      write(Webp(filename), 'out.json').then (argv) ->
        argv.should.have.keys '_', 'o'
        argv._.should.containEql filename
