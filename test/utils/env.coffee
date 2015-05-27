should = require 'should'
{run, run_mocked} = require './run'

process.env.NODE_ENV = 'test'

defineGlobal = (key, value) ->
  Object.defineProperty global, key, {value}

defineGlobal 'should', should
defineGlobal 'run_tests', run
defineGlobal 'run_mocked', run_mocked
