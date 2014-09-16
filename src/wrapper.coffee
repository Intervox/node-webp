When = require 'when'
{spawn} = require 'child_process'

{mixin} = require './utils'


module.exports = class Wrapper
  constructor: (source, bin) ->
    @_args = {_: []}
    @_args.v = [] if @constructor.verbose
    @source = source
    @bin = bin || @constructor.bin

  _spawn: (args) ->
    {resolve, reject, promise} = When.defer()
    stderr = ''
    proc = spawn @bin, args
    proc.once 'error', reject
    proc.once 'close', onClose = (code, signal) ->
      if code isnt 0 or signal isnt null
        err = new Error "Command failed: #{stderr}"
        err.code = code
        err.signal = signal
        reject err
      else
        resolve()
    proc.stderr.on 'data', onErr = (data) ->
      stderr += data
    promise.ensure ->
      # Cleanup
      proc.removeListener 'error', reject
      proc.removeListener 'close', onClose
      proc.stderr.removeListener 'close', onErr


mixin Wrapper, require './args'
mixin Wrapper, require './io'
