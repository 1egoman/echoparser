// load a file to test
exports.loadFile = function(file) {
  console.log("... Loading "+file)
  return require("../dist/"+file);
}

