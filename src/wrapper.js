const { spawn } = require('child_process');
const { mixin } = require('./utils');

const defer = () => {
  const res = {};
  res.promise = new Promise((resolve, reject) => {
    Object.assign(res, { resolve, reject });
  });
  return res;
};

function Wrapper(source, bin) {
  this._args = { _: [] };
  this._opts = {};
  this.source = source;
  this.bin = bin || this.constructor.bin;
}

mixin(Wrapper, require('./args'));
mixin(Wrapper, require('./io'));

Wrapper.prototype.spawnOptions = function(options) {
  for (const key in options) {
    this._opts[key] = options[key];
  }
  return this;
};

Wrapper.prototype._spawn = function(args, stdin = false, stdout = false) {
  const { promise, resolve, reject } = defer();
  const stdio = [
    stdin ? 'pipe' : 'ignore',
    stdout ? 'pipe' : 'ignore',
    'pipe'
  ];
  let stderr = '';
  const proc = spawn(this.bin, args, { ...this._opts, stdio });
  const onError = (err) => {
    if (err.code !== 'OK' || err.errno !== 'OK') {
      reject(err);
    }
  };
  const onClose = (code, signal) => {
    if (code !== 0 || signal !== null) {
      const err = new Error(`Command failed: ${stderr}`);
      return reject(Object.assign(err, { code, signal }));
    } else {
      return resolve();
    }
  };
  const onErrData = (data) => {
    stderr += data;
  };
  proc.once('error', onError);
  proc.once('close', onClose);
  proc.stderr.on('data', onErrData);
  const res = {};
  res.promise = promise.finally(() => {
    proc.removeListener('error', onError);
    proc.removeListener('close', onClose);
    proc.stderr.removeListener('data', onErrData);
  });
  if (stdin) {
    res.stdin = proc.stdin;
  }
  if (stdout) {
    res.stdout = proc.stdout;
  }
  return res;
};

module.exports = Wrapper;
