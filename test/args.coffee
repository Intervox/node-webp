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
              console.log data
              should(data._[0]).be.equal filename
              if type is 'boolean'
                should(data[key]).be.equal true
              else
                should(data[key]).be.equal args[0]
                for arg in args[1...]
                  should(data._).containEql arg
              should(data.__).containEql "-#{key}"

    after (done) ->
      context.spawn = spawn
      done()
