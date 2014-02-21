path = require 'path'
fs = require 'fs'

Webp = require './webp'

pkg = path.join __dirname, '../package.json'
{version} = JSON.parse fs.readFileSync pkg, 'utf8'

module.exports = exports = Webp

exports.version = version
