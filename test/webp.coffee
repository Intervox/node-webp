require('mocha-as-promised')()

child_process = require 'child_process'
path = require 'path'
fs = require 'fs'

PATH = process.env.PATH
bin = path.resolve __dirname, 'bin'
process.env.PATH = "#{bin}:#{PATH}"

Webp = require '../lib'

write = (webp, outname) ->
  webp.write(outname).then ->
    data = JSON.parse fs.readFileSync outname
    fs.unlinkSync outname
    data

describe 'Webp', ->

  describe 'write', ->

    it 'writes a file', ->
      filename = Math.random().toString(36)
      webp = new Webp filename
      write(webp, 'out.json').then (data) ->
        data._[0].should.be.equal filename
