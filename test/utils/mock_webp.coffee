fs = require 'fs'
minimist = require 'minimist'

module.exports = (argv) ->
  argv = minimist argv.slice(2)

  if argv._[0] is 'FAIL'
    throw new Error 'FAIL'
  else if filename = argv.o
    try argv.data = String fs.readFileSync argv._[0]
    data = JSON.stringify argv
    fs.writeFileSync filename, data
    process.exit()
  else
    throw new Error 'No output file specified'
