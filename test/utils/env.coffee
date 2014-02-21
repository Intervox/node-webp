require('mocha-as-promised')()
should = require 'should'

Object.defineProperty global, 'should', value: should
