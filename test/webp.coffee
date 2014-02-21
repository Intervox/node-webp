{read, write} = require './utils'

Webp = require '../lib'

describe 'Webp', ->

  describe 'write', ->

    it 'should report an external error', ->
      webp = new Webp 'FAIL'
      write(webp, 'out.json').then (data) ->
        throw new Error 'Should not be fulfilled'
      , (err) ->
        should(err).be.Error

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
        should(data._[0]).be.equal filename
        should(data._[1]).be.equal cmd

    it 'should trigger callback on error', (done) ->
      webp = new Webp 'filename'
      webp.write undefined, (err) ->
        should(err).be.Error
        done()
      return

    it 'should trigger callback on success', (done) ->
      filename = Math.random().toString(36)
      webp = new Webp filename
      webp.write 'out.json', (err) ->
        should(err).not.be.ok
        data = read 'out.json'
        should(data._[0]).be.equal filename
        done()
      return
