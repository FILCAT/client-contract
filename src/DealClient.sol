// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {StdStorage} from "../lib/forge-std/src/Components.sol";
import {specific_authenticate_message_params_parse, specific_deal_proposal_cbor_parse} from "./CBORParse.sol";



contract DealClient {

    uint constant AUTHORIZE_MESSAGE_METHOD_NUM = 2643134072; 

    mapping(bytes => bool) public cidSet;
    mapping(bytes => uint) public cidSizes;
    mapping(bytes => mapping(bytes => bool)) public cidProviders;

    bytes public fallback_calldata;
    address public owner;

    constructor(bytes32 name_) {
        owner = msg.sender;
    }

    function addData(bytes calldata cidraw, uint size) public {
       require(msg.sender == owner);
       cidSet[cidraw] = true;
       cidSizes[cidraw] = size;
    }

    function policyOK(bytes calldata cidraw, bytes calldata provider) internal view returns (bool) {
        bool alreadyStoring = cidProviders[cidraw][provider];
        return !alreadyStoring;
    }

    function authorizeData(bytes calldata cidraw, bytes calldata provider, uint size) public {
        // if (msg.sender != f05) return;
        if (!cidSet[cidraw]) return;
        if (cidSizes[cidraw] != size) return;
        if (!policyOK(cidraw, provider)) return;

        cidProviders[cidraw][provider] = true;
    }

    function readMethodNum() private view returns (uint method) {
        // HACK HACK HACK: we'll sub out difficulty opcode after compiling with the FVM extension
        assembly {
            method := difficulty()
        }
    }

    function handle_filecoin_method(uint codec, uint method, bytes calldata params) public {
        // dispatch methods
        if (method == AUTHORIZE_MESSAGE_METHOD_NUM) {
            bytes calldata deal_proposal_cbor_bytes = specific_authenticate_message_params_parse(params);
            (bytes calldata cidraw, bytes calldata provider, uint size) = specific_deal_proposal_cbor_parse(deal_proposal_cbor_bytes);
            authorizeData(cidraw, provider, size);
        } else {
            revert("the filecoin method that was called is not handled");
        }
    }

    fallback (bytes calldata input) external payable returns (bytes memory _output) {
        uint method = readMethodNum();
        fallback_calldata = input;

        // XXX parse out raw filecoin byte params from calldata
        handle_filecoin_method(0, method, input);
    }


}


// TODO
// 1. Assume fallback stuff goes away soon and just test out handle_filecoin_method
//   a. test auth of non checked in data fails
//   b. test checking in of data, owner address and address type / filecoin address will be a concern
//   c. test auth of checked in data succeeds.  Use getter public methods to check all data structures look like they are supposed to
//      (we can do this part in a test pretty easily as well)    
//   d. check handle_filecoin_method authorization matches some offchain account I own just like owner address more filecoin address and address type problems

// 2. Wallaby reset test full flow:
//    a. make lotus-miner to get a provider on chain
//    b. hand craft a PSD method and make a deal with contract
//    c. try with failures in duplicate provider, size, data not checked in

// 3. Verified client -- same as above but now for datacap
//    a. add contract to verified registry -- need help with wallaby verified root key (can do this one asap, need to do some network infra stuff)
//    b. run hand crafted PSD and check that allocation is created in verifreg

// 4. Post DealProtocolHack 
//   a. test activation
//   b. test payments and see that they happen
//   c. test verified deal and see that QAP is added for verified client contract



/*
    Other work items
        Do DealProtocolHack -- most difficult
        
        List out extensions so far

        ## Small
        a policy that only authorizes bounded payments
        include http location / ipfs hash for fetching raw data
        miner replication factor 
        
        ## Medium
        Miner power used as a proxy for reputation
        Freeze feature -- setup cid list, freeze, then secure funding for static auditable contracts 
    
        ## Large
        DAO voting for adding cids
        DeFi protocols for contract funding model
        Miner reputation oracles used for policy

        ## Unsolved / Research
        Proof of merkle translation to post ipfs hashes to the contract 

*/