{mock, unmock} = require './mock-spawn'
{CWebp, DWebp} = require '../../src'

run = (handler) ->
  describe 'cwebp', ->
    handler CWebp, 'cwebp'

  describe 'dwebp', ->
    handler DWebp, 'dwebp'


exports.run = (name, handler) ->
  describe name, ->
    run handler

exports.run_mocked = (name, handler) ->
  describe name, ->
    before mock
    run handler
    after unmock
