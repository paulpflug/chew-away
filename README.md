# chew-away

chew away at your files

Features:
  - configuration-based
  - image processing powered by [imagemin](https://github.com/imagemin/imagemin) and [jimp](https://github.com/oliver-moran/jimp)
  - will skip files, when the source and the config file are older then the target
  - pattern matching powered by [glob](https://github.com/isaacs/node-glob)


### Install

```sh
npm install --save-dev chew-away
```

### Usage

```js
// chew-away.config.js
module.exports = {
  concurrency: 4,    // default: 4      #forks to use
  test: true,        // default: false  only print
  defaults: {
    target: "deploy",//                 output
    excess: "delete",// default: "keep" what do do with excess files
    verbose: 0,      // default: 1   verbose logging
    overwrite: false,// default: false  always overwrite
    // will overwrite source files if target files are newer
    // CAREFULL - you can lose data !!!
    sync: false,     // default: false
    chew: {
      jpg: {
        // you can define multiple output files
        jpg:[
          // see jimp for available methods
          ["jimp", [["resize", "AUTO", 400]]], 
          // make sure you have the corresponding plugin installed!
          ["imagemin", ["imagemin-guetzli", {quality: 87}]] 
        ],
        webp: ["imagemin", ["imagemin-webp", {quality: 87}]],
        "small.jpg":[
          ["jimp", [["resize", "AUTO", 200]]], 
          ["imagemin", ["imagemin-guetzli", {quality: 87}]] 
        ],
      },
      // or only one output
      png: ["imagemin", ["imagemin-zopfli", {quality: 87}]],
      txt: "copy"
    }
  },
  sources: [
    { 
      pattern: "resources/*" // uses glob
      // can contain any of the options from defaults above
    }
  ]
}
```
```sh
# call in terminal:
chew-away
```
```js
// or use a task in your package.json
...
  "scripts": {
    ...
    "deploy:chew-away": "chew-away"
    ...
  }
...
```
## License
Copyright (c) 2017 Paul Pflugradt
Licensed under the MIT license.
