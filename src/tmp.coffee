path = require 'path'
os = require 'os'

_tmpDir = os.tmpdir || os.tmpDir || ->
  {platform, env} = process
  if platform is 'win32'
    windir = env.SystemRoot || env.windir || 'c:\\windows'
    env.TEMP || env.TMP || "#{windir}\\temp"
  else
    env.TMPDIR || env.TMP || env.TEMP || '/tmp'

tmpDir = _tmpDir()
prefix = 'node-webp-'

module.exports = (ext = 'tmp') ->
  base = Math.random().toString(36).slice(2,12)
  path.resolve tmpDir, "#{prefix}#{base}.#{ext}"
