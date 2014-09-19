fs = require 'fs'

data = require './utils/data'

run_tests (Webp) ->

  describe 'main', ->

    it 'should cleanup tmp files on error', ->
      filename = ''
      webp = new Webp data.corrupt
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

    it 'should support filenames', ->
      webp = new Webp '-filename'
      webp.toBuffer().then ->
        throw new Error 'Should not be fulfilled'
      , (err) ->
        err.should.be.Error
        err.message.should.match /cannot open input file/i
        err.message.should.match /'-filename'/
