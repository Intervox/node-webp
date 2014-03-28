should = require 'should'

Object.defineProperty global, 'should', value: should

{spawn} = child_process = require 'child_process'

spawn_watched = (cmd, args, opts) ->
  if child_process.spawn is spawn_watched
    spawn.apply @, arguments
  else
    child_process.spawn.apply @, arguments

child_process.spawn = spawn_watched
