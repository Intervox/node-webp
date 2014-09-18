module.exports = (handler) ->
  {CWebp, DWebp} = Webp = require '../../src'

  describe 'CWebp', ->
    handler CWebp, 'cwebp'

  describe 'DWebp', ->
    handler DWebp, 'dwebp'
