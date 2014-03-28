When = require 'when'
path = require 'path'
fs = require 'fs'

# It should work for any version of when.js
nodefn = try
  require 'when/node'
catch
  require 'when/node/function'

{Buffer} = require 'buffer'
{Stream} = require 'stream'

tmpFilename = (ext = 'tmp') ->
  tmpDir = process.env.TMPDIR || '/tmp'
  base = Math.random().toString(36).slice(2,12)
  path.resolve tmpDir, "node-webp-#{base}.#{ext}"

bindCallback = (promise, next) ->
  if typeof next is 'function'
    nodefn.bindCallback promise, next
  else
    promise

proto =
  _createFileSource: ->
    return @_tmpFilename if @_tmpFilename
    filename = tmpFilename()
    done = if Buffer.isBuffer @source
      nodefn.call fs.writeFile, filename, @source
    else if @source instanceof Stream
      {resolve, reject, promise} = When.defer()
      deferred = When.defer()
      stream = fs.createWriteStream(filename)
        .once('error', reject)
        .once('close', resolve)
        .once('finish', resolve)
      @source.pipe stream
      promise.ensure ->
        # Cleanup
        stream.removeListener 'error', reject
        stream.removeListener 'close', resolve
        stream.removeListener 'finish', resolve
    else
      When.reject new Error 'Mailformed source'
    @_tmpFilename = done.then -> filename

  _cleanup: (varname) ->
    return unless varname and promise = @[varname]
    delete @[varname]
    When(promise).then (filename) ->
      nodefn.call fs.unlink, filename if filename
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
    .ensure =>
      @_cleanup '_tmpFilename'
    bindCallback promise, next

  _writeTmp: ->
    return @_tmpOutname if @_tmpOutname
    outname = tmpFilename 'webp'
    @_tmpOutname = @write(outname).then -> outname

  toBuffer: (next) ->
    promise = @_writeTmp().then (outname) ->
      nodefn.call fs.readFile, outname
    .ensure =>
      @_cleanup '_tmpOutname'
    bindCallback promise, next

  stream: (next) ->
    _cleanup = @_cleanup.bind @, '_tmpOutname'
    cleanup = ->
      return if cleanup.done
      cleanup.done = true
      @removeListener 'error', cleanup
      @removeListener 'close', cleanup
      @removeListener 'end', cleanup
      _cleanup()
    promise = @_writeTmp().then (outname) ->
      fs.createReadStream(outname)
        .once('error', cleanup)
        .once('close', cleanup)
        .once('end', cleanup)
    bindCallback promise, next

module.exports = (Webp) ->
  for name, method of proto
    Webp::[name] = method
