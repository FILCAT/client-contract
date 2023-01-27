// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {specific_authenticate_message_params_parse, specific_deal_proposal_cbor_parse} from "./CBORParse.sol";

contract DealClient {

    uint64 constant public AUTHORIZE_MESSAGE_METHOD_NUM = 2643134072; 
    uint64 constant public DATACAP_RECEIVER_HOOK_METHOD_NUM = 3726118371;

    mapping(bytes => bool) public cidSet;
    //mapping(bytes => uint) public cidSizes;
    mapping(bytes => mapping(bytes => bool)) public cidProviders;
    event ReceivedDataCap(string received);

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function addCID(bytes calldata pieceCID, uint size) public {
       require(msg.sender == owner);
       cidSet[pieceCID] = true;
       //cidSizes[pieceCID] = size;
    }

    function policyOK(bytes calldata pieceCID, bytes calldata provider) internal view returns (bool) {
        bool alreadyStoring = cidProviders[pieceCID][provider];
        return !alreadyStoring;
    }

    function authorizeData(bytes calldata pieceCID, bytes calldata provider, uint size) public {
        // if (msg.sender != f05) return;
        require(cidSet[pieceCID], "cid must be added before authorizing");
        require(cidSizes[pieceCID] == size, "data size must match expected");
        require(policyOK(pieceCID, provider), "deal failed policy check: has provider already claimed this cid?");

        cidProviders[pieceCID][provider] = true;
    }

    function handle_filecoin_method(uint64 method, uint64, bytes calldata params) public {
        // dispatch methods
        if (method == AUTHORIZE_MESSAGE_METHOD_NUM) {
            bytes calldata deal_proposal_cbor_bytes = specific_authenticate_message_params_parse(params);
            (bytes calldata pieceCID, bytes calldata provider, uint size) = specific_deal_proposal_cbor_parse(deal_proposal_cbor_bytes);
            authorizeData(pieceCID, provider, size);
        } else if (method == DATACAP_RECEIVER_HOOK_METHOD_NUM) {
             emit ReceivedDataCap("DataCap Received!");
        } else {
             revert("the filecoin method that was called is not handled");
        }
    }
}
