cache = {}
fs = require "fs-extra"
path = require "path"
gradient = require("tinygradient")('#74ebd5', '#74ecd5')
chalk = require "chalk"

process = (file, target, job) =>
  clone = Object.assign {target:target}, file
  for piece in job
    method = piece[0]
    try
      await (cache[method] ?= require("./#{method}"))(clone, piece[1])
    catch e
      console.error chalk.red("Error processing: #{file.name}:")
      console.error e
  if clone.buffer
    await fs.outputFile(clone.target, clone.buffer)
    file.log "#{path.basename(clone.target)} spat out"
colors = null
module.exports = (files, nr, length) => Promise.all files.map (file, i) =>
  length = 2 if length < 2
  colors ?= gradient.hsv(length, 'long')
  current = nr+i
  worker =  chalk.hex(colors[current].toHex())("file #{current+1}")
  file.log = (text, level = 0) => 
    if file.verbose > level
      console.log "chew-away: #{worker}: #{text}" 
  file.log "#{file.name} sucked in" 
  subWorkers = []
  boundProcess = process.bind(null, file)
  for target, job of file.chew
    subWorkers.push boundProcess(target, job)
      
  return Promise.all(subWorkers).then => 
    if subWorkers.length > 1
      file.log "all #{subWorkers.length} pieces spat out"