{mock, unmock} = require './mock-spawn'
{CWebp, DWebp} = require '../../src'

run = (handler, helpers) ->
  describe 'cwebp', ->
    handler CWebp, helpers, 'cwebp'

  describe 'dwebp', ->
    handler DWebp, helpers, 'dwebp'


exports.run = (name, handler) ->
  describe name, ->
    run handler, {}

exports.run_mocked = (name, handler) ->
  describe name, ->
    before mock
    run handler, require './io'
    after unmock
