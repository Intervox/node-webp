fs = require 'fs'
minimist = require 'minimist'
rawBody = require 'raw-body'

read = (argv, next) ->
  source = argv._[0]
  if source is '-'
    rawBody process.stdin, {encoding: 'utf8'}, (err, data) ->
      argv.data = data unless err
      next()
  else
    try argv.data = String fs.readFileSync source
    next()

write = (argv) ->
  filename = argv.o
  data = JSON.stringify argv
  if filename is '-'
    process.stdout.write data
  else
    fs.writeFileSync filename, data

module.exports = (argv) ->
  argv = minimist argv.slice(2)

  if argv._[0] is 'FAIL'
    throw new Error 'FAIL'
  else if argv.o
    read argv, -> write argv
  else
    throw new Error 'No output file specified'
