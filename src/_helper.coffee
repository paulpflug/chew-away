path = require "path"
glob = require "glob"
Promise = require "yaku"

module.exports.flatten = (arrs) =>
  target = []
  for arr in arrs 
    for obj in arr
      target.push obj
  return target

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

module.exports.chunkify = (a, n) =>
  return [a] if n < 2
  len = a.length
  out = []
  i = 0
  if len % n == 0
    size = Math.floor(len / n)
    while (i < len) 
      out.push(a.slice(i, i += size))
  else
    while (i < len) 
      size = Math.ceil((len - i) / n--)
      out.push(a.slice(i, i += size))
  return out

module.exports.shuffle = (array) =>
  counter = array.length
  while (0 < counter) 
    index = Math.floor(Math.random() * counter)
    counter--
    temp = array[counter]
    array[counter] = array[index]
    array[index] = temp
  return array
