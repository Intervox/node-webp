methods = require './methods'

proto =
  command: (args...) ->
    @_args._.push args...
    return @

  _arg: (key, vals...) ->
    @_args[key] = vals
    return @

  args: ->
    args = []
    if preset = @_args.preset
      args.push '-preset', preset...
    for key, vals of @_args
      continue if key in ['_', 'preset']
      args.push "-#{key}", vals...
    args.concat @_args._

module.exports = (Webp) ->
  for name, method of proto
    Webp::[name] = method

  for name, params of methods then do (name, params) ->
    {key, type, description, exclude, aliases} = params
    key ||= name
    method = if type is 'boolean'
      (val) ->
        if val or arguments.length is 0
          if exclude
            delete @_args[k] for k in exclude
          @_args[key] = []
        else
          delete @_args[key]
        return @
    else
      type = [type || 'string'] unless Array.isArray type
      (args...) ->
        if args.lelgth < type.length
          throw new Error 'Not enough arguments'
        vals = []
        for t in type
          val = args.shift()
          if typeof val isnt t
            throw new Error "Expected #{t}, got #{typeof val}"
          vals.push val
        @_args[key] = vals
        return @
    method.description = description
    for alias in [].concat name, (aliases || [])
      Webp::[alias] = method
  return

