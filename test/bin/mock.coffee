fs = require 'fs'
minimist = require 'minimist'
rawBody = require 'raw-body'

module.exports = (argv) ->
  argv = minimist argv.slice(2)

  if argv._[0] is 'FAIL'
    throw new Error 'FAIL'
  else if filename = argv.o
    next = ->
      data = JSON.stringify argv
      fs.writeFileSync filename, data
      process.exit()
    source = argv._[0]
    if source is '-'
      rawBody process.stdin, {encoding: 'utf8'}, (err, data) ->
        argv.data = data unless err
        next()
    else
      try argv.data = String fs.readFileSync source
      next()
  else
    throw new Error 'No output file specified'
