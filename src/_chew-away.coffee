path = require "path"
merge = require "merge-options"
Promise = require "yaku"
fs = require "fs-extra"
ora = require "ora"
{isString, arrayize, patternToFiles, filesToLookup, prepareFile} = require "./_helper"
defaults = require "./_defaults"
handleThat = require "handle-that"
chalk = require "chalk"

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
    
    deleted = {lookup: {}, worker: []}
    _log = []
    log = (i, text) => (_log[i] ?= []).push text
    print = => 
      for texts in _log
        for text in texts
          console.log text
        console.log ""
    work = await Promise.all config.sources.map (source, i) =>
      o = merge(defaults, config.defaults, source)
      input = await patternToFiles(o, o.base, log.bind(null, i))
      output = await patternToFiles(o, o.target, log.bind(null, i))
      outLookup = filesToLookup(output)
      notDeleteLookup = {}
      work = []
      for file in input
        prepareFile(file, o)
        if file.chew?
          for target, job of file.chew
            outName = path.basename(target)
            notDeleteLookup[outName] = true
            if o.overwrite or 
                not (outfile = outLookup[outName])? or 
                outfile.mtime < file.mtime or 
                (outfile.mtime < configTime and not o.sync)
              unless ~work.indexOf file
                log i, chalk.cyan "chew-away: scheduled #{file.name} for chewing" if o.verbose
                work.push file 
            else
              delete file.chew[target]
              if o.sync and job[0] == "copy" and outfile? and outfile.mtime > file.mtime
                outfile.verbose = o.verbose
                outfile.sync = o.sync
                c = outfile.chew = {}
                c[file.name] = job
                log i, "chew-away: scheduled #{outfile.path} for chewing backwards" if o.verbose
                work.push outfile
              else
                log i, chalk.green "chew-away: #{outfile.name} is up-to-date" if o.verbose
      if o.excess == "delete"
        for outfile in output
          if not notDeleteLookup[outfile.name] and not deleted.lookup[outfile.name]
            console.log "chew-away: #{outfile.path} is gone off" if o.verbose
            deleted.worker.push fs.remove(outfile.path)
            deleted.lookup[outfile.name] = true
      return work
    print()
    work = handleThat.flatten(work)
    if config.test
      console.log "chew-away: to chew:"
      work.forEach (file) =>
        
        for target, chew of file.chew
          console.log "#{file.name}: #{path.basename(target)}"
          str = "► #{chew[0]}"
          str += " (#{chew[1][0]})" if chew[1]?
          console.log str
        console.log ""
      console.log "chew-away: ======== "
      console.log "chew-away: exiting "
      return
    if (remaining = work.length) > 0
      console.log "chew-away: " + chalk.cyan "ready to chew away at #{remaining} files"
      console.log "chew-away: "+ chalk.magenta "#{deleted.worker.length} files are gone off (deleting)" if deleted.worker.length > 0
      spinner = ora("#{remaining} files remaining...").start()
      handleThat work,
        worker: path.resolve(__dirname, "_worker")
        flatten: false
        onText: (lines, remaining) => 
          spinner.stop()
          console.log lines.join("\n")
          spinner.start("#{remaining} files remaining...")
        onProgress: (remaining) => spinner.text = "#{remaining} files remaining..."
        onFinish: => spinner.succeed chalk.green "pleasantly finished - See you next time! :D"
    else
      console.log "chew-away: nothing to chew at :*("
  catch e
    console.error e
if process.argv[0] == "coffee"
  module.exports()