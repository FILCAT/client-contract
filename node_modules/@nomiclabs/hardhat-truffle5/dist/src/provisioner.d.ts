import { NetworkConfig } from "hardhat/types";
import { Linker, TruffleContract } from "./types";
export declare class LazyTruffleContractProvisioner {
    private readonly _networkConfig;
    private readonly _web3;
    private readonly _deploymentAddresses;
    constructor(web3: any, _networkConfig: NetworkConfig);
    provision(Contract: TruffleContract, linker: Linker): any;
    private _setDefaultValues;
    private _hookCloneCalls;
}
//# sourceMappingURL=provisioner.d.ts.map