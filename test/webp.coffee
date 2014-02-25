{read, write} = require './utils'

Webp = require '../lib'

describe 'Webp', ->

  describe 'write', ->

    it 'should report an external error', ->
      webp = new Webp 'FAIL'
      write(webp, 'out.json').then (data) ->
        throw new Error 'Should not be fulfilled'
      , (err) ->
        err.should.be.Error

    it 'should report an internal error', ->
      webp = new Webp 'filename'
      write(webp, undefined).then (data) ->
        throw new Error 'Should not be fulfilled'
      , (err) ->
        err.should.be.Error

    it 'should send command', ->
      filename = Math.random().toString(36)
      cmd = Math.random().toString(36)
      webp = (new Webp filename).command cmd
      write(webp, 'out.json').then (data) ->
        data.should.have.keys '_', 'o'
        data._.should.containEql filename
        data._.should.containEql cmd

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
        data = read 'out.json'
        data.should.have.keys '_', 'o'
        data._.should.containEql filename
        done()
      return
