fs = require 'fs'

exports.read = read = (outname) ->
  data = JSON.parse fs.readFileSync outname
  fs.unlinkSync outname
  data

exports.write = write = (webp, outname) ->
  webp.write(outname).then -> read outname
