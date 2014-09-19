run = (handler, {CWebp, DWebp}) ->
  describe 'cwebp', ->
    handler CWebp, 'cwebp'

  describe 'dwebp', ->
    handler DWebp, 'dwebp'

exports.run = (handler) ->
  run handler, require '../../src'

exports.run_mocked = (handler) ->
  run handler, require './mock'
