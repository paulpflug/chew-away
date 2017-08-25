path = require "path"
glob = require "glob"
Promise = require "yaku"

module.exports.arrayize = (obj) => 
  if Array.isArray(obj)
    return obj
  else unless obj?
    return []
  else
    return [obj]

module.exports.isString = (str) => typeof str == "string" or str instanceof String

module.exports.patternToFiles = (o, cwd) => new Promise (resolve, reject) => 
  globObj = glob o.pattern, {cwd: cwd, stat: !o.overwrite, nodir: true}, (err, matches) =>
    return reject(err) if err?
    stats = globObj.statCache
    resolve matches.map (filename) =>
      filepath = path.resolve(cwd,filename)
      return name: filename, path: filepath, mtime: stats[filepath].mtimeMs

module.exports.filesToLookup = (arr) => arr.reduce ((acc, current) => acc[current.name] = current; return acc),{}

module.exports.prepareFile = (file, o, outpath) =>
  file.target = outpath
  file.verbose = o.verbose
  tmp = o.chew?[path.extname(file.name).slice(1)]
  if tmp?
    tmp = [tmp] unless Array.isArray(tmp)
    tmp = [tmp] unless Array.isArray(tmp[0])
    file.chew = tmp
  delete file.mtime

