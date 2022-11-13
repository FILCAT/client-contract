// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {StdStorage} from "../lib/forge-std/src/Components.sol";

uint constant AUTHORIZE_MESSAGE_METHOD_NUM = 3;

contract DealClient {
    mapping(bytes => bool) public cidSet;
    mapping(bytes => uint) public cidSizes;
    mapping(bytes => mapping(address => bool)) public cidProviders;

    bytes public fallback_calldata;
    address owner; // XXX does this break when sender is a filecoin address, i.e. are FC addresses allowed inside of address type?

    constructor(bytes32 name_) {
        owner = msg.sender;
    }

    function addData(bytes memory cidraw, uint size) public {
       //if (msg.sender != owner) return;
       cidSet[cidraw] = true;
       cidSizes[cidraw] = size;
    }

    function policyOK(bytes cidraw, address provider) internal view returns (bool) {
        alreadyStoring = cidProviders[cidraw][provider];
        return !alreadyStoring;
    }

    function authorizeData(bytes cidraw, address provider, uint size) public {
        // if (msg.sender != f05) return;
        if (!cidSet[cidraw]) return;
        if (cidSizes[cidraw != size]) return;
        if (!policyOK(cidraw, provider)) return;

        cidProviders[cidraw][provider] = true;
    }

    function readMethodNum() private view returns (uint method) {
        // HACK HACK HACK: we'll sub out difficulty opcode after compiling with the FVM extension
        assembly {
            method := difficulty()
        }
    }

    function handle_filecoin_method(uint codec, uint method, bytes params) {
        // dispatch methods
        if (method == AUTHENTICATE_MESSAGE_METHOD_NUM) {
            deal_proposal_cbor_bytes = specific_authenticate_message_params_parse(params);
            (rawcid, provider, size) = specific_deal_proposal_cbor_parse(deal_proposal_cbor_bytes);
            authorizeData(cidraw, provider, size);
        }
    }

    fallback (bytes calldata input) external payable returns (bytes memory _output) {
        uint method = readMethodNum();
        fallback_calldata = input;

        // XXX parse out raw filecoin byte params from calldata
        handle_filecoin_method(0, method, input);
    }


}
