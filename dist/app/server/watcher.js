"use strict";
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (Object.hasOwnProperty.call(mod, k)) result[k] = mod[k];
    result["default"] = mod;
    return result;
};
Object.defineProperty(exports, "__esModule", { value: true });
var watch = require('node-watch');
var fileGatherer = __importStar(require("../util/file-gatherer"));
function run(elmWorker) {
    var pack = require(process.cwd() + '/elm-package.json');
    watch(pack['source-directories'], { recursive: true }, function (evt, name) {
        var change = { event: evt, file: name };
        if (fileGatherer.includedInFileSet(name)) {
            elmWorker.ports.fileWatch.send(change);
        }
    });
}
exports.default = { run: run };
