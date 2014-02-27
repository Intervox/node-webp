rawBody = require 'raw-body'
nodefn = require 'when/node/function'

{Buffer} = require 'buffer'
{Stream} = require 'stream'

{read, write} = require './utils'

Webp = require '../lib'

streamToBuffer = nodefn.lift rawBody

describe 'Webp', ->

  describe 'io', ->

    describe 'output', ->

      it 'should write file', ->
        filename = Math.random().toString(36)
        webp = new Webp filename
        write(webp, 'out.json').then (data) ->
          data.should.have.keys '_', 'o'
          data._.should.containEql filename

      it 'should return buffer', ->
        filename = Math.random().toString(36)
        (new Webp filename).toBuffer().then (buffer) ->
          buffer.should.be.instanceof Buffer
          data = JSON.parse buffer
          data.should.have.keys '_', 'o'
          data._.should.containEql filename

      it 'should return stream', ->
        filename = Math.random().toString(36)
        (new Webp filename).stream().then (stream) ->
          stream.should.be.instanceof Stream
          streamToBuffer stream
        .then (buffer) ->
          data = JSON.parse buffer
          data.should.have.keys '_', 'o'
          data._.should.containEql filename

