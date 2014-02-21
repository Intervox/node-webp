When = require 'when'
nodefn = require 'when/node/function'
{spawn} = require 'child_process'


module.exports = class Webp
  constructor: (source) ->
    unless @ instanceof Webp
      return new Webp source

    @_args = []
    @source = source

  command: (args...) ->
    @_args.push args...

  _spawn: (args) ->
    {resolve, reject, promise} = When.defer()
    proc = spawn 'cwebp', args
    proc.on 'error', reject
    proc.on 'close', (code, signal) ->
      if code isnt 0
        reject new Error "Failed with code #{code}"
      else if signal isnt null
        reject new Error "Terminated with #{signal}"
      else
        resolve()
    promise

  write: (outname, next) ->
    args = [].concat @source, @_args, '-o', outname
    promise = @_spawn args
    nodefn.bindCallback promise, next
