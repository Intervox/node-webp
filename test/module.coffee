{CWebp} = Webp = require '../src'

describe 'module', ->

  it 'should support legacy require API', ->
    Webp.should.be.a.Function
    Webp.should.be.equal CWebp
