jimp = require("jimp")

module.exports = (file, args) =>
  args = [args] unless Array.isArray(args[0])
  args = args.map (cmd) => cmd.map (prop) => if jimp[prop] then jimp[prop] else prop
  chain = args.reduce ((current, cmd) => 
    current.then ((cmd, img) =>  
      console.log "chew-away: chewing on #{file.name} (jimp-#{cmd[0]})" if file.verbose
      img[cmd.shift()].apply(img,cmd)
      ).bind null, cmd
    return current
  ), jimp.read file.path
  file.buffer = await chain.then (img) => new Promise (resolve, reject) => img.getBuffer jimp.AUTO, (err, buffer) ->
    return reject(err) if err?
    resolve buffer

  