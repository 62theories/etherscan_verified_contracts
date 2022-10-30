module.exports = function readDataFromJSONFile(filePath) {
    var fs = require('fs');
    var data = fs.readFileSync(filePath);
    return JSON.parse(data);
}