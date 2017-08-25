path = require "path"
merge = require "merge-options"
Promise = require "yaku"
fs = require "fs-extra"
ora = require "ora"
{isString, arrayize, patternToFiles, filesToLookup, prepareFile} = require "./_helper"
defaults = require "./_defaults"
handleThat = require "handle-that"

configTime = 0

module.exports = (config) =>
  try
    unless config?
      files = await fs.readdir(process.cwd())
      for ext in ["js","coffee"]
        if ~files.indexOf(tmp = "chew-away.config.#{ext}")
          config = tmp
          break
      throw new Error "no chew-away.config found" unless config 
    
    if isString(config)
      if path.extname(config) == ".coffee"
        try
          require "coffeescript/register"
        catch
          try
            require "coffee-script/register"
      config = require (configPath = path.resolve(config))
      stats = await fs.stat configPath
      configTime = stats.mtimeMs
    deletes = []
    work = await Promise.all config.sources.map (obj) =>
      o = merge(defaults, config.defaults, obj)
      input = await patternToFiles(o, o.base)
      output = await patternToFiles(o, o.target)
      outLookup = filesToLookup(output)
      work = []
      for file in input
        if o.overwrite or 
            not (outfile = outLookup[file.name])? or 
            outfile.mtime < file.mtime or 
            (outfile.mtime < configTime and not o.sync)
          prepareFile(file, o, outfile?.path or path.resolve(o.target,file.name))
          if file.chew?
            console.log "chew-away: scheduled #{file.path} for chewing" if o.verbose
            work.push file
          else if o.verbose
            console.log "chew-away: found #{file.path}, but no chewing specified"
        else if o.sync and outfile? and outfile.mtime > file.mtime
          prepareFile(outfile, o, file.path)
          if outfile.chew?
            console.log "chew-away: scheduled #{outfile.path} for chewing backwards" if o.verbose
            work.push outfile
          else if o.verbose
            console.log "chew-away: found #{outfile.path}, but no chewing specified"
      if o.excess == "delete"
        inpLookup = filesToLookup(input)
        for outfile in output
          unless inpLookup[outfile.name]?
            console.log "chew-away: #{outfile.path} is gone off" if o.verbose
            deletes.push fs.remove(outfile.path)
      return work
    work = handleThat.flatten(work)
    if config.test
      console.log "chew-away: to chew:"
      work.forEach (file) =>
        console.log "#{file.name}: #{file.target}"
        file.chew.forEach (chew) =>
          str = "► #{chew[0]}"
          str += " (#{chew[1][0]})" if chew[1]?
          console.log str
        console.log ""
      console.log "chew-away: ======== "
      console.log "chew-away: exiting "
      return
    if (remaining = work.length) > 0
      console.log "chew-away: ready to chew away at #{remaining} files"
      console.log "chew-away: #{deletes.length} files are gone off (deleting)" if deletes.length > 0
      spinner = ora("#{remaining} files remaining...").start()
      handleThat work,
        worker: path.resolve(__dirname, "_worker")
        flatten: false
        onText: (lines) => 
          spinner.stop()
          console.log lines.join("\n")
          spinner.start("#{remaining} files remaining...")
        onProgress: (count) => spinner.text = "#{remaining = count} files remaining..."
        onFinish: => spinner.succeed "pleasantly finished - See you next time! :D"
    else
      console.log "chew-away: nothing to chew at :*("
  catch e
    console.error e
if process.argv[0] == "coffee"
  module.exports()