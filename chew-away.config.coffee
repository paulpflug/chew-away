resize = (width, plugin) => [
  ["jimp", [["resize","AUTO",width]]]
  ["imagemin",["imagemin-#{plugin}",{quality: 87}]]
] 
module.exports =
  concurrency: 4
  test: false
  defaults:
    verbose: true
    base: "test/from"
    target: "test/to"
    excess: "delete"
    chew:
      jpg:
        jpg: resize 400, "guetzli"
        webp: resize 400, "webp"
        "small.jpg": resize 200, "guetzli"
        "small.webp": resize 200, "webp"
      txt: "copy"
  sources: [
    { pattern: "*.+(jpg|webp)" }
    { pattern: "*.txt", sync: true}
  ]