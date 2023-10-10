{spawn} = require 'child_process'

{mixin} = require './utils'

defer = () ->
  res = {}
  res.promise = new Promise (resolve, reject) ->
    res.resolve = resolve
    res.reject = reject
  res

module.exports = class Wrapper
  mixin this, require './args'
  mixin this, require './io'

  constructor: (source, bin) ->
    @_args = {_: []}
    @_opts = {}
    @source = source
    @bin = bin || @constructor.bin

  spawnOptions: (options) ->
    for key, value of options
      @_opts[key] = value
    return @

  _spawn: (args, stdin = false, stdout = false) ->
    {resolve, reject, promise} = defer()
    stderr = ''
    @_opts.stdio = [
      if stdin  then 'pipe' else 'ignore'
      if stdout then 'pipe' else 'ignore'
      'pipe' # stderr
    ]
    proc = spawn @bin, args, @_opts
    proc.once 'error', onError = (err) ->
      reject err unless err.code is 'OK' is err.errno
    proc.once 'close', onClose = (code, signal) ->
      if code isnt 0 or signal isnt null
        err = new Error "Command failed: #{stderr}"
        err.code = code
        err.signal = signal
        reject err
      else
        resolve()
    proc.stderr.on 'data', onErrData = (data) ->
      stderr += data
    promise = promise.finally ->
      # Cleanup
      proc.removeListener 'error', onError
      proc.removeListener 'close', onClose
      proc.stderr.removeListener 'data', onErrData
    res = {promise}
    res.stdin = proc.stdin if stdin
    res.stdout = proc.stdout if stdout
    return res
