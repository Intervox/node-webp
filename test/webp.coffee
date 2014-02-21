require('mocha-as-promised')()

child_process = require 'child_process'
path = require 'path'
fs = require 'fs'

PATH = process.env.PATH
bin = path.resolve __dirname, 'bin'
process.env.PATH = "#{bin}:#{PATH}"

Webp = require '../lib'

read = (outname) ->
  data = JSON.parse fs.readFileSync outname
  fs.unlinkSync outname
  data

write = (webp, outname) ->
  webp.write(outname).then -> read outname

describe 'Webp', ->

  describe 'write', ->

    it 'should report an external error', ->
      webp = new Webp 'FAIL'
      write(webp, 'out.json').then (data) ->
        throw new Error 'Should not be fulfilled'
      , (err) ->
        err.should.be.Error

    it 'should report an internal error', ->
      webp = new Webp 'filename'
      write(webp, undefined).then (data) ->
        throw new Error 'Should not be fulfilled'
      , (err) ->
        err.should.be.Error

    it 'should send command', ->
      filename = Math.random().toString(36)
      cmd = Math.random().toString(36)
      webp = (new Webp filename).command cmd
      write(webp, 'out.json').then (data) ->
        data._[0].should.be.equal filename
        data._[1].should.be.equal cmd

    it 'should trigger callback on error', (done) ->
      webp = new Webp 'filename'
      webp.write undefined, (err) ->
        err.should.be.Error
        done()
      return

    it 'should trigger callback on success', (done) ->
      filename = Math.random().toString(36)
      webp = new Webp filename
      webp.write 'out.json', (err) ->
        data = read 'out.json'
        data._[0].should.be.equal filename
        done()
      return
