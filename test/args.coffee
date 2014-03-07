{EventEmitter} = require 'events'
minimist = require 'minimist'

{spawn} = child_process = require 'child_process'


Webp = require '../lib'
methods = require '../lib/methods'

context = {}
write = (webp, outname) ->
  webp.write(outname).then -> context.argv

mock_spawn = (cmd, args) ->
  res = new EventEmitter
  res.stderr = new EventEmitter
  argv = minimist args.map (s) ->
    if typeof s is 'string'
      s.replace '-', '--'
    else
      s
  argv.__ = args
  setTimeout ->
    context.argv = argv
    res.emit 'close', 0, null
  , 100
  res

generate_args = (key, type) ->
  types = if type is 'boolean'
    []
  else
    [].concat type
  types.map (t) ->
    rnd = Math.random()
    if t is 'number'
      rnd
    else
      rnd.toString(36)

describe 'Webp', ->

  describe 'args', ->

    before (done) ->
      child_process.spawn = mock_spawn
      done()

    for name, params of methods then do (name, params) ->
      {key, type, exclude, aliases, description} = params
      key ||= name
      aliases ||= []

      for aliace in [].concat(name, aliases) then do (aliace) ->

        describe aliace, ->

          it 'should send argument', ->
            filename = Math.random().toString(36)
            args = generate_args aliace, type
            webp = (new Webp filename)[name] args...
            write(webp, 'out.json').then (data) ->
              data.should.have.keys key, '_', '__', 'o'
              data._.should.containEql filename
              if type is 'boolean'
                data[key].should.be.ok
              else
                data[key].should.be.equal args[0]
                for arg in args[1...]
                  data._.should.containEql arg
              data.__.should.containEql "-#{key}"

          unless type is 'boolean'
            it 'should throw type exceprions', ->
              filename = Math.random().toString(36)
              args = generate_args aliace, type
              expect = [].concat(type)[0] || 'string'
              if expect is 'number'
                args[0] = args[0].toString(36)
              else
                args[0] = Math.random()
              webp = new Webp filename
              err = new RegExp "^Expected #{expect}, got"
              (-> webp[name] args...).should.throw(err)

          if [].concat(type)[0] is 'number'
            it 'should accept stringified numbers', ->
              filename = Math.random().toString(36)
              args = generate_args aliace, type
              webp = (new Webp filename)[name] args.map(String)...
              write(webp, 'out.json').then (data) ->
                data.should.have.keys key, '_', '__', 'o'
                data._.should.containEql filename
                for arg in args[1...]
                  data._.should.containEql arg
                data[key].should.be.equal args[0]

          if Array.isArray type and type.length > 1
            it 'should throw arguments exceprions', ->
              filename = Math.random().toString(36)
              args = generate_args aliace, type
              args.pop()
              webp = new Webp filename
              err = 'Not enough arguments'
              (-> webp[name] args...).should.throw(err)

          if exclude
            it 'should handle exclusions', ->
              filename = Math.random().toString(36)
              webp = new Webp filename
              for method in [].concat exclude
                webp[method]()
              webp[name]()
              write(webp, 'out.json').then (data) ->
                data.should.have.keys key, '_', '__', 'o'
                data[key].should.be.ok

          it 'should have description', (done) ->
            filename = Math.random().toString(36)
            webp = new Webp filename
            webp[name].should.have.property 'description', description
            done()

    describe 'convention', ->

      it 'should send -preset first', ->
        filename = Math.random().toString(36)
        cmd = Math.random().toString(36)
        webp = new Webp filename
        webp.quality 123
        webp.preset cmd
        webp.size 456
        write(webp, 'out.json').then (data) ->
          data.preset.should.be.equal cmd
          data.__[0].should.be.equal filename
          data.__[1].should.be.equal '-preset'
          data.__[2].should.be.equal cmd

    after (done) ->
      child_process.spawn = spawn
      done()
