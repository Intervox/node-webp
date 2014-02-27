{read, write} = require './utils'

Webp = require '../lib'

describe 'Webp', ->

  describe 'main', ->

    it 'should report an external error', ->
      webp = new Webp 'FAIL'
      write(webp, 'out.json').then ->
        throw new Error 'Should not be fulfilled'
      , (err) ->
        err.should.be.Error

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
