data = require './utils/data'

run_mocked 'spawn', (Webp) ->

  it 'should allow default bin rewriting', ->
    res = ''
    cmd = "webp-mock-#{Math.random()}"
    class Webp2 extends Webp
      @bin: cmd
    webp = new Webp2
    {promise, stdout} = webp._spawn ['-version'], false, true
    stdout.on 'data', (data) ->
      res += data
    promise.then  ->
      res.should.be.equal cmd

  it 'should accept bin as a constructor option', ->
    res = ''
    cmd = "webp-mock-#{Math.random()}"
    webp = new Webp null, cmd
    {promise, stdout} = webp._spawn ['-version'], false, true
    stdout.on 'data', (data) ->
      res += data
    promise.then  ->
      res.should.be.equal cmd

  it 'should accept custom spawn options', ->
    filename = Math.random().toString(36)
    webp = new Webp filename
    webp.spawnOptions detached: true
    webp.toBuffer().then (buffer) ->
      argv = JSON.parse buffer
      argv.should.have.keys '__opts'
      argv.__opts.should.have.property 'detached', true
