module.exports = {
  command(...args) {
    this._args._.push(...args);
    return this;
  },
  _arg(key, ...vals) {
    this._args[key] = vals;
    return this;
  },
  args() {
    const args = [];
    if (this._args.preset) {
      args.push('-preset', ...this._args.preset);
    }
    for (const key in this._args) {
      if (key === '_' || key === '-' || key === 'preset') {
        continue;
      }
      args.push(`-${key}`, ...this._args[key]);
    }
    return args.concat(this._args._);
  }
};
