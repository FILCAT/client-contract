"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    Object.defineProperty(o, k2, { enumerable: true, get: function() { return m[k]; } });
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getSolidityFiles = void 0;
const path_1 = require("path");
async function getSolidityFiles(directory) {
    try {
        const { getAllFilesMatching } = await Promise.resolve().then(() => __importStar(require("hardhat/internal/util/fs-utils")));
        if (getAllFilesMatching === undefined) {
            // we don't want to catch errors from this function
            // eslint-disable-next-line @typescript-eslint/return-await
            return getSolidityFilesUsingGlob(directory);
        }
        return await getAllFilesMatching(directory, (f) => f.endsWith(".sol"));
    }
    catch (e) {
        if (e.code === "MODULE_NOT_FOUND") {
            return getSolidityFilesUsingGlob(directory);
        }
        throw e;
    }
}
exports.getSolidityFiles = getSolidityFiles;
async function getSolidityFilesUsingGlob(directory) {
    const { glob } = await Promise.resolve().then(() => __importStar(require("hardhat/internal/util/glob")));
    return glob((0, path_1.join)(directory, "**", "*.sol"));
}
//# sourceMappingURL=glob.js.map