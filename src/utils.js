exports.mixin = (cls, proto) => {
  for (const name in proto) {
    cls.prototype[name] = proto[name];
  }
};

exports.compile = (methods) => {
  const proto = {};
  for (const name in methods) {
    const { key = name, type, description, exclude, aliases } = methods[name];
    const typeArray = Array.isArray(type) ? type : [type || 'string'];

    const method = type === 'boolean' ? function(val) {
      if (val || arguments.length === 0) {
        if (exclude) {
          [].concat(exclude).forEach((k) => {
            delete this._args[methods[k].key || k];
          });
        }
        this._args[key] = [];
      } else {
        delete this._args[key];
      }
      return this;
    } : function(...args) {
      if (args.length < typeArray.length) {
        throw new Error('Not enough arguments');
      }
      const vals = [];
      typeArray.forEach((t) => {
        let val = args.shift();
        if (t === 'number') {
          const nval = Number(val);
          if (Number.isFinite(nval)) {
            val = nval;
          }
        }
        if (typeof val !== t) {
          throw new Error(`Expected ${t}, got ${typeof val}`);
        }
        vals.push(val);
      });
      this._args[key] = vals;
      return this;
    };
    proto[name] = Object.assign(method, { description });
    (aliases || []).forEach((alias) => {
      proto[alias] = proto[name];
    });
  }
  return proto;
};
