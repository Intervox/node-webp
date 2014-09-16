{mixin, compile} = require './utils'
Wrapper = require './wrapper'
methods = require './methods'


module.exports = class Webp extends Wrapper
  @bin: 'cwebp'
  @verbose: false

  constructor: (source, bin) ->
    unless @ instanceof Webp
      return new Webp source, bin
    super


mixin Webp, compile methods
