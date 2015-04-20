exports.mixin = (cls, proto) ->
  for name, method of proto
    cls::[name] = method
  return

exports.compile = (methods) ->
  proto = {}
  for name, params of methods then do (name, params) ->
    {key, type, description, exclude, aliases} = params
    key ||= name
    method = if type is 'boolean'
      (val) ->
        if val or arguments.length is 0
          if exclude then for k in [].concat exclude
            delete @_args[methods[k].key || k]
          @_args[key] = []
        else
          delete @_args[key]
        return @
    else
      type = [type || 'string'] unless Array.isArray type
      (args...) ->
        if args.length < type.length
          throw new Error 'Not enough arguments'
        vals = []
        for t in type
          val = args.shift()
          if (t is 'number') and (Number.isFinite nval = Number val)
            val = nval
          if typeof val isnt t
            throw new Error "Expected #{t}, got #{typeof val}"
          vals.push val
        @_args[key] = vals
        return @
    method.description = description
    for alias in [].concat name, (aliases || [])
      proto[alias] = method
  proto
