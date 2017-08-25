fs = require "fs-extra"
cache = {}

module.exports = (files) => Promise.all files.map (file) =>
  console.log "chew-away: #{file.name} sucked in" if file.verbose
  for chewew in file.chew
    method = chewew.shift()
    await (cache[method] ?= require("./#{method}"))(file, chewew.shift())
  await fs.outputFile(file.target, file.buffer) if file.buffer
  console.log "chew-away: #{file.name} spat out" if file.verbose