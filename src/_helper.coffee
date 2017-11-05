path = require "path"
glob = require "glob"
Promise = require "yaku"
isPlainObject = require "is-plain-object"

doubleArrayize = (obj) =>
  unless Array.isArray(obj)
    return [[obj]]
  else unless Array.isArray(obj[0])
    return [obj] 
  return obj
module.exports.arrayize = (obj) => 
  if Array.isArray(obj)
    return obj
  else unless obj?
    return []
  else
    return [obj]

module.exports.isString = (str) => typeof str == "string" or str instanceof String

module.exports.patternToFiles = (o, cwd, log) => new Promise (resolve, reject) => 
  globObj = glob o.pattern, {cwd: cwd, stat: !o.overwrite, nodir: true}, (err, matches) =>
    if o.verbose
      where = if o.base == cwd then "source" else "target"
      log "chew-away: pattern '#{o.pattern}' matched #{matches.length} files in #{where} directory" 
    return reject(err) if err?
    stats = globObj.statCache
    resolve matches.map (filename) =>
      filepath = path.resolve(cwd,filename)
      s = stats[filepath]
      return name: filename, path: filepath, mtime: s.mtimeMs, atime: s.atimeMs

module.exports.filesToLookup = (arr) => arr.reduce ((acc, current) => acc[current.path] = current; return acc),{}

module.exports.prepareFile = (file, o) =>
  outpath = path.resolve o.target, file.name
  file.verbose = o.verbose
  file.sync = o.sync
  ext = file.extIn = path.extname(file.name).slice(1)
  obj = o.chew?[ext]
  if obj?
    unless isPlainObject(obj)
      tmp = {}
      tmp[ext] = obj
      obj = tmp
    else
      obj = Object.assign {}, obj
    for k,v of obj
      out = outpath
      out = out.replace(ext, k) if ext != k
      obj[out] = doubleArrayize(v)
      delete obj[k]
    file.chew = obj

