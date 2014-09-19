When = require 'when'
{spawn} = require 'child_process'

{mixin} = require './utils'


module.exports = class Wrapper
  mixin this, require './args'
  mixin this, require './io'

  constructor: (source, bin) ->
    @_args = {_: []}
    @source = source
    @bin = bin || @constructor.bin

  _spawn: (args, stdin = false, stdout = false) ->
    {resolve, reject, promise} = When.defer()
    stderr = ''
    stdio = [
      if stdin  then 'pipe' else 'ignore'
      if stdout then 'pipe' else 'ignore'
      'pipe' # stderr
    ]
    proc = spawn @bin, args, {stdio}
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
    promise = promise.ensure ->
      # Cleanup
      proc.removeListener 'error', reject
      proc.removeListener 'close', onClose
      proc.stderr.removeListener 'close', onErr
    promise.stdin = proc.stdin if stdin
    promise.stdout = proc.stdout if stdout
    return promise
