"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getTruffleFixtureFunction = exports.hasMigrations = exports.hasTruffleFixture = exports.TRUFFLE_FIXTURE_NAME = void 0;
const fs_extra_1 = __importDefault(require("fs-extra"));
const errors_1 = require("hardhat/internal/core/errors");
const path_1 = __importDefault(require("path"));
exports.TRUFFLE_FIXTURE_NAME = "truffle-fixture";
async function hasTruffleFixture(paths) {
    try {
        require.resolve(path_1.default.join(paths.tests, exports.TRUFFLE_FIXTURE_NAME));
        return true;
    }
    catch {
        return false;
    }
}
exports.hasTruffleFixture = hasTruffleFixture;
async function hasMigrations(paths) {
    const migrationsDir = path_1.default.join(paths.root, "migrations");
    if (!(await fs_extra_1.default.pathExists(migrationsDir))) {
        return false;
    }
    const files = await fs_extra_1.default.readdir(migrationsDir);
    const jsFiles = files.filter((f) => f.toLowerCase().endsWith(".js"));
    return jsFiles.length > 1;
}
exports.hasMigrations = hasMigrations;
async function getTruffleFixtureFunction(paths) {
    const fixturePath = require.resolve(path_1.default.join(paths.tests, exports.TRUFFLE_FIXTURE_NAME));
    let fixture = require(fixturePath);
    if (fixture.default !== undefined) {
        fixture = fixture.default;
    }
    if (!(fixture instanceof Function)) {
        throw new errors_1.NomicLabsHardhatPluginError("@nomiclabs/hardhat-truffle5", `Truffle fixture file ${fixturePath} must return a function`);
    }
    return fixture;
}
exports.getTruffleFixtureFunction = getTruffleFixtureFunction;
//# sourceMappingURL=fixture.js.map