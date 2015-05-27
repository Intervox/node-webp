run_tests 'main', (Webp) ->

  it 'should support filenames', ->
    webp = new Webp '-filename'
    webp.toBuffer().then ->
      throw new Error 'Should not be fulfilled'
    , (err) ->
      err.should.be.Error
      err.message.should.match /cannot open input file/i
      err.message.should.match /'-filename'/
