const path = require('path');
const fs = require('fs');
const { CWebp, DWebp } = require('./webp');

const pkg = path.resolve(__dirname, '../package.json');
const { version } = JSON.parse(fs.readFileSync(pkg, 'utf8'));

module.exports = Object.assign(CWebp, { CWebp, DWebp, version });
