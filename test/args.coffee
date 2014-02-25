{EventEmitter} = require 'events'
minimist = require 'minimist'

context = {}

{spawn} = child_process = require 'child_process'
context.spawn = spawn
child_process.spawn = (cmf, args, opts) ->
  context.spawn.apply @, arguments

Webp = require '../lib'
methods = require '../lib/methods'

write = (webp, outname) ->
  webp.write(outname).then -> context.argv

mock_spawn = (cmd, args) ->
  res = new EventEmitter
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
      context.spawn = mock_spawn
      done()

    for name, params of methods then do (name, params) ->
      {key, type, exclude, aliases} = params
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
                args[0] = String args[0]
              else
                args[0] = Math.random()
              webp = new Webp filename
              err = new RegExp "^Expected #{expect}, got"
              (-> webp[name] args...).should.throw(err)

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
                Object.keys(data).should.have.length 4
                data.should.have.keys key, '_', '__', 'o'
                data[key].should.be.ok


    after (done) ->
      context.spawn = spawn
      done()
