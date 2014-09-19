data_base64 = require './data_base64'

module.exports = data = {}

for key, str of data_base64
  data[key] = new Buffer str, 'base64'
