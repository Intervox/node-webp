mockSpawn = require 'mock-spawn'
{spawn} = cp = require 'child_process'
minimist = require 'minimist'
rawBody = require 'raw-body'
fs = require 'fs'

mocked = false

read = (argv, stdin, next) ->
  source = argv._[0]
  if source is '-'
    rawBody stdin, {encoding: 'utf8'}, (err, data) ->
      argv.data = data unless err
      next()
    stdin.resume()
  else
    try argv.data = String fs.readFileSync source
    next()

write = (argv, stdout) ->
  filename = argv.o
  data = JSON.stringify argv
  if filename is '-'
    stdout.write new Buffer data
  else
    fs.writeFileSync filename, data

mySpawn = mockSpawn()

fail = (code, msg) ->
  mySpawn.simple code, null, "Error: #{msg}"

mySpawn.setStrategy (cmd, args, opts) ->
  if cmd in ['cwebp', 'dwebp']
    argv = minimist args
    argv.__opts = opts
    if argv._[0] is 'FAIL'
      fail 1, 'FAIL'
    else if argv.o
      (done) ->
        {stdin, stdout} = this
        read argv, stdin, ->
          write argv, stdout
          done 0
    else
      fail 1, 'No output file specified'
  else if /-mock/.test cmd
    mySpawn.simple 0, cmd

mySpawnPaused = (cmd, args, opts) ->
  proc = mySpawn cmd, args, opts
  proc.stdin.pause()
  return proc

cp.spawn = smartSpawn = (cmd, args, opts) ->
  fn = if mocked
    mySpawnPaused
  else if cp.spawn is smartSpawn
    spawn
  else
    cp.spawn
  fn.apply this, arguments

exports.mock = ->
  mocked = true

exports.unmock = ->
  mocked = false
