{mixin, compile} = require './utils'
Wrapper = require './wrapper'
methods = require '../methods'


exports.CWebp = class CWebp extends Wrapper
  mixin this, compile methods.global
  mixin this, compile methods.cwebp

  @bin: 'cwebp'
  @verbose: false

  constructor: (source, bin) ->
    unless @ instanceof CWebp
      return new CWebp source, bin

    super

    if @constructor.verbose
      @_args.v = []


exports.DWebp = class DWebp extends Wrapper
  mixin this, compile methods.global
  mixin this, compile methods.dwebp

  @bin: 'dwebp'

  constructor: (source, bin) ->
    unless @ instanceof DWebp
      return new DWebp source, bin

    super
