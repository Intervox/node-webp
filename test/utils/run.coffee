module.exports = (handler) ->
  {CWebp, DWebp} = Webp = require '../../src'

  describe 'CWebp as module root', ->
    handler Webp, 'cwebp'

  describe 'CWebp', ->
    handler CWebp, 'cwebp'

  describe 'DWebp', ->
    handler DWebp, 'dwebp'
