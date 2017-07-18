fs = require "fs-extra"
cache = {}

chew = (files) => Promise.all files.map (file) =>
  console.log "chew-away: #{file.name} sucked in" if file.verbose
  for chewew in file.chew
    method = chewew.shift()
    await (cache[method] ?= require("./#{method}"))(file, chewew.shift())
  await fs.outputFile(file.target, file.buffer) if file.buffer
  console.log "chew-away: #{file.name} spat out" if file.verbose

process.on "message", (files) =>
  return process.send(0) unless files
  try
    await chew files
  catch e
    console.error e
  process.send(files.length)
process.send(0)