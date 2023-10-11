const { inherits } = require('util');
const { mixin, compile } = require('./utils');
const Wrapper = require('./wrapper');
const methods = require('../methods.json');

function CWebp(source, bin) {
  if (!(this instanceof CWebp)) {
    return new CWebp(source, bin);
  }
  Wrapper.call(this, source, bin);
  if (this.constructor.verbose) {
    this._args.v = [];
  }
}

inherits(CWebp, Wrapper);

mixin(CWebp, compile(methods.global));
mixin(CWebp, compile(methods.cwebp));

CWebp.bin = 'cwebp';
CWebp.verbose = false;

function DWebp(source, bin) {
  if (!(this instanceof DWebp)) {
    return new DWebp(source, bin);
  }
  Wrapper.call(this, source, bin);
}

inherits(DWebp, Wrapper);

mixin(DWebp, compile(methods.global));
mixin(DWebp, compile(methods.dwebp));

DWebp.bin = 'dwebp';

module.exports = { CWebp, DWebp };
