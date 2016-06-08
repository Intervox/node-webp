rawBody = require 'raw-body'
When = require 'when'
fs = require 'fs'

# It should work for any version of when.js
nodefn = try
  require 'when/node'
catch
  require 'when/node/function'

{Buffer} = require 'buffer'
{Stream, PassThrough} = require 'stream'

streamToBuffer = nodefn.lift rawBody
PassThrough ||= require 'through'

tmpFilename = require './tmp'

bindCallback = (promise, next) ->
  if typeof next is 'function'
    nodefn.bindCallback promise, next
  else
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
      promise: When.reject new Error 'Mailformed source'

  write: (outname, next) ->
    promise = if outname
      (@_write @source, outname).promise
    else
      When.reject new Error 'outname in not specified'
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
        When.reject new Error 'Failed to pipe stdout'
    promise.then ->
      outstream.end()
    .otherwise (err) ->
      outstream.emit 'error', err
    outstream
