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

require('./args')(Webp)
require('./io')(Webp)
