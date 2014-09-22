rawBody = require 'raw-body'
nodefn = require 'when/node'
{ReadableStreamBuffer} = require 'stream-buffers'

{Buffer} = require 'buffer'
{Stream} = require 'stream'

{read, write} = require './utils/io'

streamToBuffer = nodefn.lift rawBody

run_mocked (Webp) ->

  describe 'io', ->

    describe 'output', ->

      it 'should write file', ->
        filename = Math.random().toString(36)
        webp = new Webp filename
        write(webp, 'out.json').then (argv) ->
          argv.should.have.keys '_', 'o'
          argv._.should.containEql filename

      it 'should return buffer', ->
        filename = Math.random().toString(36)
        (new Webp filename).toBuffer().then (buffer) ->
          buffer.should.be.instanceof Buffer
          argv = JSON.parse buffer
          argv.should.have.keys '_', 'o'
          argv._.should.containEql filename

      it 'should return stream', ->
        filename = Math.random().toString(36)
        stream = (new Webp filename).stream()
        stream.should.be.instanceof Stream
        streamToBuffer(stream).then (buffer) ->
          argv = JSON.parse buffer
          argv.should.have.keys '_', 'o'
          argv._.should.containEql filename

    describe 'input', ->

      it 'should read buffers', ->
        data = Math.random().toString(36)
        (new Webp new Buffer data).toBuffer().then (buffer) ->
          argv = JSON.parse buffer
          argv.should.have.keys '_', 'o', 'data'
          argv.data.should.be.eql data

      it 'should read streams', ->
        data = Math.random().toString(36)
        stream = new ReadableStreamBuffer
        stream.put data
        (new Webp stream).toBuffer().then (buffer) ->
          argv = JSON.parse buffer
          argv.should.have.keys '_', 'o', 'data'
          argv.data.should.be.eql data

      it 'should throw type error', ->
        (new Webp {}).toBuffer().then ->
          throw new Error 'Should not be fulfilled'
        , (err) ->
          err.should.be.Error
          err.message.should.be.equal 'Mailformed source'
