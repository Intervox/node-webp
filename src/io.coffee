streamToBuffer = require 'raw-body'

{Buffer} = require 'buffer'
{Stream, PassThrough} = require 'stream'

bindCallback = (promise, next) ->
  if typeof next is 'function'
    promise.then (result) ->
      process.nextTick next, null, result
    , (err) ->
      process.nextTick next, err
  promise

module.exports =
  _write: (source, outname) ->
    outname ||= '-'
    stdin = (typeof source isnt 'string')
    stdout = outname is '-'
    args = [].concat @args(), [
      '-o', outname
      '--', (if stdin then '-' else source)
    ]
    unless stdin
      @_spawn args, stdin, stdout
    else if Buffer.isBuffer source
      res = @_spawn args, stdin, stdout
      res.stdin.end source
      res
    else if source instanceof Stream
      res = @_spawn args, stdin, stdout
      source.pipe res.stdin
      res
    else
      promise: Promise.reject new Error 'Mailformed source'

  write: (outname, next) ->
    promise = if outname
      (@_write @source, outname).promise
    else
      Promise.reject new Error 'outname in not specified'
    bindCallback promise, next

  toBuffer: (next) ->
    bindCallback (streamToBuffer @stream()), next

  stream: ->
    outstream = new PassThrough()
    res = @_write @source, '-'
    promise = if res.stdout
      res.stdout.pipe outstream, end: false
      res.promise
    else
      res.promise.then ->
        Promise.reject new Error 'Failed to pipe stdout'
    promise.then ->
      outstream.end()
    .catch (err) ->
      outstream.emit 'error', err
    outstream
