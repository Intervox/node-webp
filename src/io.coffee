nodefn = require 'when/node/function'
When = require 'when'
path = require 'path'
fs = require 'fs'

{Buffer} = require 'buffer'
{Stream} = require 'stream'

tmpFilename = (ext = 'tmp') ->
  tmpDir = process.env.TMPDIR || '/tmp'
  base = Math.random().toString(36).slice(2,12)
  path.resolve tmpDir, "node-webp-#{base}.#{ext}"

proto =
  _createFileSource: ->
    return @_tmpFilename if @_tmpFilename
    filename = tmpFilename()
    promise = if Buffer.isBuffer @source
      nodefn.call fs.writeFile, filename, @source
    else if @source instanceof Stream
      deferred = When.defer()
      stream = fs.createWriteStream(filename)
        .once('error', deferred.reject)
        .once('close', deferred.resolve)
        .once('finish', deferred.resolve)
      @source.pipe stream
      deferred.promise
    else
      When.reject new Error 'Mailformed source'
    @_tmpFilename = promise.then -> filename

  _cleanup: (varname) ->
    return unless varname and promise = @[varname]
    delete @[varname]
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
      @_cleanup '_tmpFilename'
    nodefn.bindCallback promise, next

  _writeTmp: ->
    return @_tmpOutname if @_tmpOutname
    outname = tmpFilename 'webp'
    @_tmpOutname = @write(outname).then -> outname

  toBuffer: (next) ->
    promise = @_writeTmp().then (outname) ->
      nodefn.call fs.readFile, outname
    .tap =>
      @_cleanup '_tmpOutname'
    nodefn.bindCallback promise, next

  stream: (next) ->
    done = false
    cleanup = =>
      return if done
      done = true
      @_cleanup '_tmpOutname'
    promise = @_writeTmp().then (outname) ->
      fs.createReadStream(outname)
        .once('error', cleanup)
        .once('close', cleanup)
        .once('end', cleanup)
    nodefn.bindCallback promise, next

module.exports = (Webp) ->
  for name, method of proto
    Webp::[name] = method
