const path = require('path');
const { CWebp, DWebp } = require('./webp');

const { version } = require('../package.json');

module.exports = Object.assign(CWebp, { CWebp, DWebp, version });
