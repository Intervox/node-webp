nodefn = require 'when/node/function'
When = require 'when'
path = require 'path'
fs = require 'fs'

{Buffer} = require 'buffer'
{Stream} = require 'stream'

tmpFilename = ->
  tmpDir = process.env.TMPDIR || '/tmp'
  base = Math.random().toString(36).slice(2,12)
  path.resolve tmpDir, "node-webp-#{base}.tmp"

proto =
  _createFileSource: ->
    return @_tmpFilename if @_tmpFilename
    filename = tmpFilename()
    promise = if Buffer.isBuffer @source
      nodefn.call fs.writeFile, filename, @source
    else if @source instanceof Stream
      deferred = When.defer()
      stream = fs.createWriteStream filename
      @source.pipe stream
      stream.on 'error', deferred.reject
      stream.on 'finish', deferred.resolve
      deferred.promise
    else
      When.reject new Error 'Mailformed source'
    @_tmpFilename = promise.then -> filename

  _cleanup: ->
    return unless promise = @_tmpFilename
    delete @_tmpFilename
    When(promise).then (filename) ->
      nodefn.call fs.unlink filename if filename
    .otherwise ->

  _fileSource: ->
    if typeof @source is 'string'
      @source
    else
      @_createFileSource()

  write: (outname, next) ->
    promise = When(@_fileSource()).then (filename) =>
      if outname
        args = [].concat filename, @args(), '-o', outname
        @_spawn args
      else
        throw new Error 'outname in not specified'
    .tap =>
      @_cleanup()
    nodefn.bindCallback promise, next

  toBuffer: (next) ->
    return @

  stream: (next) ->
    return @

module.exports = (Webp) ->
  for name, method of proto
    Webp::[name] = method
