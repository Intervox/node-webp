const streamToBuffer = require('raw-body');
const { Buffer } = require('buffer');
const { Stream, PassThrough } = require('stream');

const bindCallback = (promise, next) => {
  if (typeof next === 'function') {
    promise.then(
      (result) => process.nextTick(next, null, result),
      (err) => process.nextTick(next, err)
    );
  }
  return promise;
};

module.exports = {
  _write(source, outname = '-') {
    const stdin = typeof source !== 'string';
    const stdout = outname === '-';
    const args = [
      ...this.args(),
      '-o', outname,
      '--', (stdin ? '-' : source)
    ];
    if (!stdin) {
      return this._spawn(args, stdin, stdout);
    } else if (Buffer.isBuffer(source)) {
      const res = this._spawn(args, stdin, stdout);
      res.stdin.end(source);
      return res;
    } else if (source instanceof Stream) {
      const res = this._spawn(args, stdin, stdout);
      source.pipe(res.stdin);
      return res;
    } else {
      return {
        promise: Promise.reject(new Error('Mailformed source'))
      };
    }
  },
  write(outname, next) {
    const promise = outname
      ? (this._write(this.source, outname)).promise
      : Promise.reject(new Error('outname in not specified'));
    return bindCallback(promise, next);
  },
  toBuffer(next) {
    return bindCallback(streamToBuffer(this.stream()), next);
  },
  stream() {
    const outstream = new PassThrough();
    const { promise, stdout } = this._write(this.source, '-');
    if (stdout) {
      stdout.pipe(outstream, { end: false });
    }
    promise
      .then(() => outstream.end())
      .catch((err) => outstream.destroy(err));
    return outstream;
  }
};
