# Client Contracts
![Screen Shot 2022-11-16 at 11 10 33 AM](https://user-images.githubusercontent.com/5515260/202233423-691bca60-06b7-41d1-a808-e182119778ec.png)![Screen Shot 2022-11-16 at 11 22 28 AM](https://user-images.githubusercontent.com/5515260/202236079-cbb4d257-5abf-458f-b18f-775ceca29170.png)
![Screen Shot 2022-11-16 at 11 18 57 AM](https://user-images.githubusercontent.com/5515260/202235551-09c82221-0e5f-4e3c-aa36-fd2fbe170f20.png)

**A workshop for programming the filecoin deal market and making FVM Data DAOs**

This repo contains 
1. [A solidity contract template](https://github.com/lotus-web3/client-contract/blob/main/src/DealClient.sol#L15) that stores data with the filecoin builtin deal market
2. [A tiny mock market](https://github.com/lotus-web3/client-contract/blob/main/src/DealClient.sol#L7) contract for prototyping against a realistic filecoin market
3. [Low level solidity CBOR parsing functions](https://github.com/lotus-web3/client-contract/blob/main/src/CBORParse.sol#L129) of general use reading filecoin native data
4. A home for the contracts you invent on top of these 

### Install

To build and test you will need to install [foundry](https://github.com/foundry-rs/foundry/blob/master/README.md) which depends on `cargo`.  After installing foundry simple run

```sh
make build
```

to compile the contracts.

### Use

See [this demo](https://www.youtube.com/watch?v=2Cpahhb0IW0) for example operation of the mvp contract

### Build

If you build an extension to this MVP contract this repo hopes to be a good home for it.  Follow the [contribution guidelines](https://github.com/lotus-web3/client-contract/blob/main/CONTRIBUTING.md) to add your extended contracts back here where they can be shared with other developers.


## Core Idea

With [FIP 44](https://github.com/filecoin-project/FIPs/blob/master/FIPS/fip-0044.md) landing in nv17 the builtin storage market actor can delegate authorization of a deal proposal to an arbitrary fvm contract.  This allows any filecoin contract to act as a client of the storage market.  This hook is enough to get a long way towards supporting data DAOs and other programmable storage projects.  While we expect more powerful builtin actors APIs to exist in the near future which will further expand the set of supported functionalities, the builtin market interface has the advantage of existing today.

![PublishStorageDeals](https://user-images.githubusercontent.com/5515260/202312700-d47d90a0-245d-4a90-afc4-f2a3a0c3960e.png)


### Client Contract modular breakdown

The client contract consists of three conceptual building blocks
1. A way to add cids to its authorized set.  MVP relies on [contract creator setting directly](https://github.com/lotus-web3/client-contract/blob/main/src/DealClient.sol#L30)
2. An authorization policy. MVP enforces [one provider per cid](https://github.com/lotus-web3/client-contract/blob/main/src/DealClient.sol#L36)
3. A mechanism of rewarding storage of cids on its wishlist. MVP doesn't have a place for this in its code and relies on the filecoin builtin market for payments.

### Example variants in terms of building blocks
* A simple data DAO can be implemented with a client that adds cids through a voting mechanism
* Perpetual storage contracts can by implemented with clients that funds deals with defi mechanisms and recycle cids from expiring deals into their authorization sets
* Trustless third party data funding can be implemented with 1) public ability to authorize cids for the client 2) a funding mechanism that associates payments with particular cids and 3) an authorization policy that only allows deals that are fully funded to pass authorization


### How it works with Storage Providers and actual transfer of data

Contract clients can work with an offchain party synchronizing with the chain and pushing deal data to miners. Alternatively contract clients could work with a pull based model where the contract provides an incentive and a location to pull from and the storage provider initiates everyting.  Deals wity contract cliehts are similar to current deal making protocols.  However there are key differences. In particular deal proposals can't be cryptographically signed by a contract. So none of the exact software needed for SPs to complete contract client deals is written yet.  The lotus team is actively prototyping modifications to data transfer and deal making software to allow for miner initiated deals with client contracts.

## Some Extension Ideas

If you are looking for ideas the following is a non-exhaustive list of things you could try to build on top of the basic client contract in this repo.  If you build any of these you are welcome to [contribute them back to the repo](https://github.com/lotus-web3/client-contract/blob/main/CONTRIBUTING.md).


### Easy
1. Add to the client contract a policy that only authorizes particular payment amounts.  This requires reading the storage_price_per_epoch field of the deal proposal, and maybe the deal duration.  It will require changing CBOR parsing logic.
2. Include a hint about how to get the data so that the provider can read contract state and then fetch from this location directly.  This could be an ipfs hash, http address, physical mailing address to send a letter etc.  This is probably just an additional mapping from raw cid to data locator in the client's state
3. Add a data replication factor so that the client will only authorize a bounded number of deals for each cid

### Medium
1. "Simple Perpetual Storage" -- Start with a contract with a bounded replication factor.  Parse the deal duration from the proposal and track the earliest the deal will expire in client state.  At this date allow the contract to clean up state and track a reduction in replication factor allowing a new deal to track this cid.
2. "Quality controlled providers" -- Determine the provider's power by querying the builtin power actor and only accept deals from proviers with a high enough power. This is a very simple sybil resistence measure since the storage provider needs to stake pledge and store files before it can claim deals.
3. "Freeze feature" -- the cid list is added to and authorization is turned off.  When the list of authorized cids is frozen then the contract can be funded as a whole by a funding party and authorizations turned on.  This has some interesting data auditing applications -- the whole set of data tracked by a contract could be audited before providing funding (either in FIL or a FIL+ style data cap token)
4. "CID Charity" -- see "Trustless third party data funding" above.  The end state is a client which uses donated funds to incentivize storage of data.
3. "Integrate with builtin market APIs" -- there are many ideas some easier some harder.  By polling the builtin market state you can make the deal client aware of deal state changes beyond the original authorization hook.  For example you can see if a deal has been terminated early and correclty track replication factor without waiting for original expiration time, and you could determine if the deal has actually been activated by a sector and perform some event in response, such as giving the miner an additional payment or minting a specialized DAO token to that miner.


### Hard

1. "Client Data Insurance" -- integrate the deal client with a data insurance mechanism that pays out in the case a provider terminates their data
2. "Market Market" -- make the client a proper market matching bids and asks directly on chain.  Note that this is a pathological use of the builtin storage market, at this point we should definitely be using a different interface and dropping the builtin storage market altogether.
3. "Data Swap" make a trading market where one provider agrees to store cid A if another provider agrees to store cid B.  This could be a useful primitive to handle cases when providers have mismatchd value and access of their data.  You could also extend this into a research project by including verifiable function computation as another commodity to trade on the market.


### Needs Research

Pin IPFS hash directly -- there is a nuance with the filecoin deal cids in relation to the cids of their underlying data. Deal cids are the merkle root of a particular serialization and specially padded chunk of data.  So if you want to add an arbitrary IPFS dag the raw cid will in general be different than the cid tracked by filecoin.  An active area of research is developing a protocol / cryptographic proving techniques for estabilishing some provable link between these two cids so that a client can prove with some confidence that a proposal deal cid matches with the client's desired deal cid.  Some [good ideas are proposed here](https://www.notion.so/pl-strflt/Proposal-Non-interactive-Proof-of-Wrong-Merkle-Tree-Translation-9736f54e911241ce8bfb23b9cee29709).


## Coming up

This repo hopes to track many community-crafted variants of the basic mvp deal client contract.  In addition to this the lotus team is actively pursuing the following complementary lines of work

1. This contract should *just work* against the filecoin builtin actors api but if there are any subtle integration issues when moving from mocked builtin actors api to true builtin actors api these will be worked out ~ next week
2. No code changes required here, but once wallaby runs a true builtin actors api we will be testing out filecoin native payment models for the client contract: both adding the contract as a FIL+ client and adding FIL payments to the market.
3. The storage provider deal making and data transfer model will need to change to support deal proposals with non signing contracts.  We're looking into prototyping and designing supportive changes in the relevant code bases (lotus-miner, boost) and protocols (deal proposal protocol, ask protocol).
4. Assuming this experimental model proves itself out we are going to pursue basic fil-infra use of this new data storage mechanism.  We're interested in building tools for storing blockchain data generally and filecoin state and message data archives in particular.
