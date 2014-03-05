When = require 'when'
{spawn} = require 'child_process'


module.exports = class Webp
  constructor: (source) ->
    unless @ instanceof Webp
      return new Webp source

    @_args = {_: []}
    @source = source

  _spawn: (args) ->
    {resolve, reject, promise} = When.defer()
    stderr = ''
    proc = spawn 'cwebp', args
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
    promise.tap ->
      # Cleanup
      proc.removeListener 'error', reject
      proc.removeListener 'close', onClose
      proc.stderr.removeListener 'close', onErr

require('./args')(Webp)
require('./io')(Webp)
