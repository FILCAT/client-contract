## Client Contract
![Screen Shot 2022-11-16 at 11 10 33 AM](https://user-images.githubusercontent.com/5515260/202233423-691bca60-06b7-41d1-a808-e182119778ec.png)



**This repo contains a solidity contract template for a fevm smart contract client to the filecoin builtin deal market**

### Install

To build and test you will need to install [foundry](https://github.com/foundry-rs/foundry/blob/master/README.md) which depends on `cargo`.  After installing foundry simple run

```sh
make build
```

to compile the contracts.

### Use

TODO: Link to a video demo

### Build

If you build an extension to this MVP contract this repo hopes to be a good home for it.  Follow the contribution guidelines to add your extended contracts back here where they can be shared with other developers.


## Extensions


## Coming up

This repo hopes to track many community-crafted variants of the basic mvp deal client contract.  In addition to this the lotus team is actively pursuing the following complementary lines of work

1. This contract should *just work* against the filecoin builtin actors api but if there are any subtle integration issues when moving from mocked builtin actors api to true builtin actors api these will be worked out ~ next week
2. No code changes required here, but once wallaby runs a true builtin actors api we will be testing out filecoin native payment models for the client contract: both adding the contract as a FIL+ client and adding FIL payments to the market.
3. The storage provider deal making and data transfer model will need to change to support deal proposals with non signing contracts.  We're looking into prototyping and designing supportive changes in the relevant code bases (lotus-miner, boost) and protocols (deal proposal protocol, ask protocol).
4. Assuming this experimental model proves itself out we are going to pursue basic fil-infra use of this new data storage mechanism.  We're interested in building tools for storing blockchain data generally and filecoin state and message data archives in particular.
