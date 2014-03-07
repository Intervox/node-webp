When = require 'when'
{spawn} = require 'child_process'


module.exports = class Webp
  @bin: 'cwebp'

  constructor: (source, bin) ->
    unless @ instanceof Webp
      return new Webp source, bin

    @_args = {_: []}
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
    promise.tap ->
      # Cleanup
      proc.removeListener 'error', reject
      proc.removeListener 'close', onClose
      proc.stderr.removeListener 'close', onErr

require('./args')(Webp)
require('./io')(Webp)
