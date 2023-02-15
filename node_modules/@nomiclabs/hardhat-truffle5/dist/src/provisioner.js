"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.LazyTruffleContractProvisioner = void 0;
const errors_1 = require("hardhat/internal/core/errors");
const constants_1 = require("./constants");
class LazyTruffleContractProvisioner {
    constructor(web3, _networkConfig) {
        this._networkConfig = _networkConfig;
        this._deploymentAddresses = {};
        this._web3 = web3;
    }
    provision(Contract, linker) {
        Contract.setProvider(this._web3.currentProvider);
        this._setDefaultValues(Contract);
        const originalLink = Contract.link;
        const alreadyLinkedLibs = {};
        let linkingByInstance = false;
        Contract.link = (...args) => {
            // This is a simple way to detect if it is being called with a contract as first argument.
            if (args[0].constructor.name === "TruffleContract") {
                const libName = args[0].constructor.contractName;
                if (alreadyLinkedLibs[libName]) {
                    throw new errors_1.NomicLabsHardhatPluginError("@nomiclabs/hardhat-truffle5", `Contract ${Contract.contractName} has already been linked to ${libName}.`);
                }
                linkingByInstance = true;
                const ret = linker.link(Contract, args[0]);
                alreadyLinkedLibs[libName] = true;
                linkingByInstance = false;
                return ret;
            }
            if (!linkingByInstance) {
                if (typeof args[0] === "string") {
                    throw new errors_1.NomicLabsHardhatPluginError("@nomiclabs/hardhat-truffle5", `Linking contracts by name is not supported by Hardhat. Please use ${Contract.contractName}.link(libraryInstance) instead.`);
                }
                throw new errors_1.NomicLabsHardhatPluginError("@nomiclabs/hardhat-truffle5", `Linking contracts with a map of addresses is not supported by Hardhat. Please use ${Contract.contractName}.link(libraryInstance) instead.`);
            }
            originalLink.apply(Contract, args);
        };
        Contract.deployed = async () => {
            const address = this._deploymentAddresses[Contract.contractName];
            if (address === undefined) {
                throw new errors_1.NomicLabsHardhatPluginError("@nomiclabs/hardhat-truffle5", `Trying to get deployed instance of ${Contract.contractName}, but none was set.`);
            }
            return Contract.at(address);
        };
        Contract.setAsDeployed = (instance) => {
            if (instance === undefined) {
                delete this._deploymentAddresses[Contract.contractName];
            }
            else {
                this._deploymentAddresses[Contract.contractName] = instance.address;
            }
        };
        this._hookCloneCalls(Contract, linker);
        return Contract;
    }
    _setDefaultValues(Contract) {
        const defaults = {};
        let hasDefaults = false;
        if (typeof this._networkConfig.gas === "number") {
            defaults.gas = this._networkConfig.gas;
            hasDefaults = true;
        }
        if (typeof this._networkConfig.gasPrice === "number") {
            defaults.gasPrice = this._networkConfig.gasPrice;
            hasDefaults = true;
        }
        if (hasDefaults) {
            Contract.defaults(defaults);
        }
        Contract.gasMultiplier =
            this._networkConfig.gasMultiplier !== undefined
                ? this._networkConfig.gasMultiplier
                : constants_1.DEFAULT_GAS_MULTIPLIER;
    }
    _hookCloneCalls(Contract, linker) {
        const originalClone = Contract.clone;
        Contract.clone = (...args) => {
            const cloned = originalClone.apply(Contract, args);
            return this.provision(cloned, linker);
        };
    }
}
exports.LazyTruffleContractProvisioner = LazyTruffleContractProvisioner;
//# sourceMappingURL=provisioner.js.map