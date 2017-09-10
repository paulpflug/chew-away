fs = require "fs-extra"

module.exports = (file, args) =>
  unless file.buffer
    await fs.copy(file.path, file.target) 
    if file.sync
      await Promise.all [file.path, file.target].map (filename) => 
        fs.utimes filename, file.atime/1000, file.mtime/1000