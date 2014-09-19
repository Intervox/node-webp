{cwebp: bin} = require 'webp'

data = require './utils/data'

run_tests (Webp) ->

  describe 'main', ->

    it 'should allow default bin rewriting', ->
      stdout = ''
      class Webp2 extends Webp
        @bin: bin
      webp = new Webp2
      {promise, stdout} = webp._spawn ['-version'], false, true
      stdout.on 'data', (data) ->
        stdout += data
      promise.then  ->
        stdout.should.match /0\.3\.1/

    it 'should accept bin as a constructor option', ->
      stdout = ''
      webp = new Webp null, bin
      {promise, stdout} = webp._spawn ['-version'], false, true
      stdout.on 'data', (data) ->
        stdout += data
      promise.then  ->
        stdout.should.match /0\.3\.1/

    it 'should support filenames', ->
      webp = new Webp '-filename'
      webp.toBuffer().then ->
        throw new Error 'Should not be fulfilled'
      , (err) ->
        err.should.be.Error
        err.message.should.match /cannot open input file/i
        err.message.should.match /'-filename'/
