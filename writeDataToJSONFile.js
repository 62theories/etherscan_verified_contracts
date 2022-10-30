module.exports = function writeDataToJSONFile(data, fileName) {
    var fs = require('fs');
    fs.writeFileSync(fileName, JSON.stringify(data));
}