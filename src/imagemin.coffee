imagemin = require "imagemin"
path = require "path"

cache = {}

module.exports = (file, args) =>
  args = [args] unless Array.isArray(args[0])
  plugins = args.map (plugin) =>
    name = plugin[0]
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
    return plg(plugin[1])
  file.log "scrunching #{file.name} (imagemin)", 1
  unless file.buffer 
    await imagemin([file.name], path.dirname(file.target), plugins: plugins)
  else
    file.buffer = await imagemin.buffer file.buffer, plugins: plugins