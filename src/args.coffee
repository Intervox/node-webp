module.exports =
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
      continue if key in ['_', '-', 'preset']
      args.push "-#{key}", vals...
    args.concat @_args._
