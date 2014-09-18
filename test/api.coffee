{read, write} = require './utils/io'

run_tests (Webp) ->

  describe 'api', ->

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

    it 'should work without new', ->
      filename = Math.random().toString(36)
      write(Webp(filename), 'out.json').then (argv) ->
        argv.should.have.keys '_', 'o'
        argv._.should.containEql filename
