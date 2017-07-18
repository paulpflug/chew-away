imagemin = require "imagemin"
path = require "path"

cache = {}

module.exports = (file, args) =>
  args = [args] unless Array.isArray(args[0])
  plugins = args.map (plugin) =>
    name = plugin.shift()
    unless (plg = cache[name])?
      try
        plg = require name
      catch
        try
          plg = require path.resolve(process.cwd(),"node_modules",name)
        catch
          try
            plg = require path.resolve(process.cwd(),"../node_modules",name)
          catch
            throw new Error "couldn't load #{name}"
      cache[name] = plg
    return plg(plugin.shift())
  console.log "chew-away: scrunching #{file.name} (imagemin)" if file.verbose
  unless file.buffer 
    await imagemin([file.name], path.dirname(file.target), plugins: plugins)
  else
    file.buffer = await imagemin.buffer file.buffer, plugins: plugins