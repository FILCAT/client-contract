// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;


import { MarketAPI } from "@zondax/filecoin-solidity/contracts/v0.8/MarketAPI.sol";
import { CommonTypes } from "@zondax/filecoin-solidity/contracts/v0.8/types/CommonTypes.sol";
import { MarketTypes } from "@zondax/filecoin-solidity/contracts/v0.8/types/MarketTypes.sol";
import { AccountTypes } from "@zondax/filecoin-solidity/contracts/v0.8/types/AccountTypes.sol";
import { BigInt } from "@zondax/filecoin-solidity/contracts/v0.8/cbor/BigIntCbor.sol";
import { AccountCBOR } from "@zondax/filecoin-solidity/contracts/v0.8/cbor/AccountCbor.sol";
import { MarketCBOR } from "@zondax/filecoin-solidity/contracts/v0.8/cbor/MarketCbor.sol";
import { BytesCBOR } from "@zondax/filecoin-solidity/contracts/v0.8/cbor/BytesCbor.sol";
import { BigNumbers, BigNumber } from "https://github.com/Zondax/filecoin-solidity/blob/master/contracts/v0.8/external/BigNumbers.sol";

import "hardhat/console.sol";


contract MockMarket {
    function publish_deal(bytes memory raw_auth_params, address callee) public {
        // calls standard filecoin receiver on message authentication api method number
        (bool success, ) = callee.call(abi.encodeWithSignature("handle_filecoin_method(uint64,uint64,bytes)", 0, 2643134072, raw_auth_params));
        require(success, "client contract failed to authorize deal publish");
    }
}

struct ProposalIdSet {
    bytes32 proposalId;
    bool valid;
}

struct ProviderSet {
    bytes provider;
    bool valid;
}


contract DealClient {

    using AccountCBOR for *;
    using MarketCBOR for *;

    uint64 constant public AUTHENTICATE_MESSAGE_METHOD_NUM = 2643134072;
    uint64 constant public DATACAP_RECEIVER_HOOK_METHOD_NUM = 3726118371;
    uint64 constant public MARKET_NOTIFY_DEAL_METHOD_NUM = 4186741094;

    mapping(bytes32 => bytes) public dealProposals; // dealID -> dealProposalBytes
    mapping(bytes => ProposalIdSet) public pieceToProposal; // commP -> dealProposalID
    mapping(bytes => ProviderSet) public pieceProviders; // commP -> provider
    mapping(bytes => uint64) public pieceDeals; // commP -> deal ID

    event ReceivedDataCap(string received);
    event DealProposalCreate(bytes32 indexed id, uint64 size, bool indexed verified, BigInt price);

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    // FOR DEMO PURPOSES
    function simpleDealProposal(bytes memory pieceCid, uint64 pieceSize) public {
        MarketTypes.DealProposal memory deal;
        deal.piece_cid = pieceCid;
        deal.piece_size = pieceSize;

        bytes memory serDeal = deal.serializeDealProposal();
        makeDealProposal(serDeal);

    }

    function makeDealProposal(bytes memory deal) public {
        // TODO: evaluate permissioning here
        require(msg.sender == owner);
        console.log("start of make deal proposal");

        // creates a unique ID for the deal proposal -- there are many ways to do this
        bytes32 _id = keccak256(abi.encodePacked(block.timestamp, msg.sender));
        dealProposals[_id] = deal;

        MarketTypes.DealProposal memory proposal = deal.deserializeDealProposal();
        pieceToProposal[proposal.piece_cid] = ProposalIdSet(_id, true);

        // writes the proposal metadata to the event log
        emit DealProposalCreate(_id, proposal.piece_size, proposal.verified_deal, proposal.storage_price_per_epoch);
    }


    function getDealProposal(bytes32 proposalId) view public returns (bytes memory) {
        return dealProposals[proposalId];
    }


    function authenticateMessage(bytes memory params) view internal {

        AccountTypes.AuthenticateMessageParams memory amp = params.deserializeAuthenticateMessageParams();
        MarketTypes.DealProposal memory proposal = amp.message.deserializeDealProposal();

        require(pieceToProposal[proposal.piece_cid].valid, "piece cid must be added before authorizing");
        require(!pieceProviders[proposal.piece_cid].valid, "deal failed policy check: provider already claimed this cid");
    }

    function dealNotify(bytes memory params) internal {

        MarketTypes.MarketDealNotifyParams memory mdnp = params.deserializeMarketDealNotifyParams();
        MarketTypes.DealProposal memory proposal = mdnp.dealProposal.deserializeDealProposal();

        require(pieceToProposal[proposal.piece_cid].valid, "piece cid must be added before authorizing");
        require(!pieceProviders[proposal.piece_cid].valid, "deal failed policy check: provider already claimed this cid");

        pieceProviders[proposal.piece_cid] = ProviderSet(proposal.provider, true);
        pieceDeals[proposal.piece_cid] = mdnp.dealId;

    }

    // client - filecoin address byte format
    function addBalance(bytes memory client, uint256 value) public {

        require(msg.sender == owner);

        // TODO:: remove first arg
        // change to ethAddr -> actorId and use that in the below API

        MarketAPI.addBalance(client, value);
    }

    // Below 2 funcs need to go to filecoin.sol
    function uintToBigInt(uint256 value) internal view returns(BigInt memory) {
        BigNumber memory bigNumVal = BigNumbers.init(value, false);
        BigInt memory bigIntVal = BigInt(bigNumVal.val, bigNumVal.neg);
        return bigIntVal;
    }

    function bigIntToUint(BigInt memory bigInt) internal view returns (uint256) {
        BigNumber memory bigNumUint = BigNumbers.init(bigInt.val, bigInt.neg);
        uint256 bigNumExtractedUint = uint256(bytes32(bigNumUint.val));
        return bigNumExtractedUint;
    }


    function withdrawBalance(bytes memory client, uint256 value) public returns(uint) {
        // TODO:: remove first arg
        // change to ethAddr -> actorId and use that in the below API

        require(msg.sender == owner);

        MarketTypes.WithdrawBalanceParams memory params = MarketTypes.WithdrawBalanceParams(client, uintToBigInt(value));
        MarketTypes.WithdrawBalanceReturn memory ret = MarketAPI.withdrawBalance(params);

        return bigIntToUint(ret.amount_withdrawn);
    }

    function receiveDataCap(bytes memory params) internal {
        emit ReceivedDataCap("DataCap Received!");
        // Add get datacap balance api and store datacap amount
    }

    function handle_filecoin_method(uint64 method, uint64, bytes memory params) public {
        // dispatch methods
        if (method == AUTHENTICATE_MESSAGE_METHOD_NUM) {
            authenticateMessage(params);
        } else if (method == MARKET_NOTIFY_DEAL_METHOD_NUM) {
            dealNotify(params);
        }
        else if (method == DATACAP_RECEIVER_HOOK_METHOD_NUM) {
            receiveDataCap(params);
        } else {
            revert("the filecoin method that was called is not handled");
        }
    }
}
