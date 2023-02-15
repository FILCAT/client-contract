import { Artifacts } from "hardhat/types";
import { LazyTruffleContractProvisioner } from "./provisioner";
import { TruffleContract, TruffleContractInstance } from "./types";
export declare class TruffleEnvironmentArtifacts {
    private readonly _provisioner;
    private readonly _artifacts;
    constructor(_provisioner: LazyTruffleContractProvisioner, _artifacts: Artifacts);
    require(contractPath: string): any;
    contractNeedsLinking(Contract: TruffleContract): any;
    contractWasLinked(Contract: TruffleContract): boolean;
    /**
     * This functions links a contract with one or multiple libraries.
     *
     * We have this method here because our artifacts format is slightly different
     * than Truffle's and doesn't include deployment information.
     *
     * This method also makes TruffleContract work with solc 0.5.x bytecode and
     * link symbols.
     */
    link(destination: TruffleContract, ...libraries: TruffleContractInstance[]): void;
    private _getContractNameFromPath;
    private _getTruffleContract;
}
//# sourceMappingURL=artifacts.d.ts.map