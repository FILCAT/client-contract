import { HardhatRuntimeEnvironment, ProjectPathsConfig } from "hardhat/types";
export declare const TRUFFLE_FIXTURE_NAME = "truffle-fixture";
export declare function hasTruffleFixture(paths: ProjectPathsConfig): Promise<boolean>;
export declare function hasMigrations(paths: ProjectPathsConfig): Promise<boolean>;
export declare function getTruffleFixtureFunction(paths: ProjectPathsConfig): Promise<(env: HardhatRuntimeEnvironment) => Promise<void>>;
//# sourceMappingURL=fixture.d.ts.map