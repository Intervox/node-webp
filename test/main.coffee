{spawn} = child_process = require 'child_process'

run_tests 'main', (Webp) ->

  it 'should support filenames', ->
    webp = new Webp '-filename'
    webp.toBuffer().then ->
      throw new Error 'Should not be fulfilled'
    , (err) ->
      err.should.be.Error
      err.message.should.match /cannot open input file/i
      err.message.should.match /'-filename'/

  it 'should cleanup all event listeners', ->
    proc = null
    child_process.spawn = (cmd, args, opts) ->
      child_process.spawn = spawn
      proc = spawn.apply this, arguments
    webp = new Webp '-filename'
    webp.toBuffer().then ->
      throw new Error 'Should not be fulfilled'
    , (err) ->
      err.should.be.Error
      proc._events.should.be.empty
      {stdout, stderr} = proc
      stdout.listeners('data').should.be.empty
      stderr.listeners('data').should.be.empty
    .ensure ->
      child_process.spawn = spawn
