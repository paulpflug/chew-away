fs = require "fs-extra"

module.exports = (file, args) =>
  await fs.copy(file.path, file.target)  unless file.buffer