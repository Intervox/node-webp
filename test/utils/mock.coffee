path = require 'path'

{CWebp, DWebp} = require '../../src'

mock = (bin) ->
  base = path.resolve __dirname, '../bin/', bin


exports.CWebp = class CWebp_mocked extends CWebp
  @bin: mock 'cwebp'


exports.DWebp = class DWebp_mocked extends DWebp
  @bin: mock 'dwebp'

