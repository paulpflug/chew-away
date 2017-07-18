module.exports =
  concurrency: 4
  defaults:
    base: "test/from"
    target: "test/to"
    excess: "delete"
    chew:
      jpg: [
        ["jimp", [["resize","AUTO",400]]]
        ["imagemin", ["imagemin-guetzli",{quality: 87}]]
      ]
      txt: "copy"
  sources: [
    { pattern: "*" }
  ]