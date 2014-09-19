module.exports = (handler) ->
  {CWebp, DWebp} = require './mock'

  describe 'CWebp', ->
    handler CWebp, 'cwebp'

  describe 'DWebp', ->
    handler DWebp, 'dwebp'
