path = require 'path'
fs = require 'fs'

{CWebp, DWebp} = require './webp'

pkg = path.resolve __dirname, '../package.json'
{version} = JSON.parse fs.readFileSync pkg, 'utf8'

module.exports = exports = CWebp

exports.CWebp = CWebp
exports.DWebp = DWebp
exports.version = version
