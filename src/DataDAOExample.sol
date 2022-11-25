// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.13;

import {StdStorage} from "../lib/forge-std/src/Components.sol";
import {specific_authenticate_message_params_parse, specific_deal_proposal_cbor_parse} from "./CBORParse.sol";

// import "https://github.com/foundry-rs/forge-std/blob/5bafa16b4a6aa67c503d96294be846a22a6f6efb/src/StdStorage.sol";
// import "https://github.com/lotus-web3/client-contract/blob/main/src/CBORParse.sol";


contract MockMarket {

    DataDAO client;

    constructor(address _client) {
        client = DataDAO(_client);
    }

    function publish_deal(bytes calldata raw_auth_params, uint256 proposalID) public {
        // calls standard filecoin receiver on message authentication api method number
        client.handle_filecoin_method(0, 2643134072, raw_auth_params, proposalID);
    }

}

contract DataDAO {

    uint64 constant public AUTHORIZE_MESSAGE_METHOD_NUM = 2643134072; 

    mapping(bytes => bool) public cidSet;
    mapping(bytes => uint) public cidSizes;
    mapping(bytes => mapping(bytes => bool)) public cidProviders;

    uint256 public proposalCount;

    struct Proposal {
        uint256 proposalID;
        address storageProvider;
        bytes cidraw;
        uint size;
        uint256 upVoteCount;
        uint256 downVoteCount;
        uint256 proposedAt;
        uint256 proposalExpireAt;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(address => mapping(uint256 => bool)) public hasVotedForProposal;

    function getSP(uint256 proposalID) view internal returns(address) {
        return proposals[proposalID].storageProvider;
    }

    function isCallerSP(uint256 proposalID) view internal returns(bool) {
       return getSP(proposalID) == msg.sender;
    }

    function isVotingOn(uint256 proposalID) view internal returns(bool) {
       return proposals[proposalID].proposalExpireAt > block.timestamp;
    }

    function createAddCIDProposal(bytes calldata cidraw, uint size) public {
        proposalCount = proposalCount + 1;
        Proposal memory proposal = Proposal(proposalCount, msg.sender, cidraw, size, 0, 0, block.timestamp, block.timestamp + 5 minutes);
        proposals[proposalCount] = proposal;
        cidSet[cidraw] = true;
        cidSizes[cidraw] = size;
    }

    function upvoteCIDProposal(uint256 proposalID) public {
        require(!isCallerSP(proposalID), "Storage Provider cannot vote his own proposal");
        require(!hasVotedForProposal[msg.sender][proposalID], "Already Voted");
        require(isVotingOn(proposalID), "Voting Period Finished");
        proposals[proposalID].upVoteCount = proposals[proposalID].upVoteCount + 1;
        hasVotedForProposal[msg.sender][proposalID] = true;
    }

    function downvoteCIDProposal(uint256 proposalID) public {
        require(!isCallerSP(proposalID), "Storage Provider cannot vote his own proposal");
        require(!hasVotedForProposal[msg.sender][proposalID], "Already Voted");
        require(isVotingOn(proposalID), "Voting Period Finished");
        proposals[proposalID].downVoteCount = proposals[proposalID].downVoteCount + 1;
        hasVotedForProposal[msg.sender][proposalID] = true;
    }
     
    function policyOK(uint256 proposalID) internal view returns (bool) {
        //require(proposals[proposalID].proposalExpireAt > block.timestamp, "Voting in On");
        return proposals[proposalID].upVoteCount > proposals[proposalID].downVoteCount;
    }

    function authorizeData(uint256 proposalID, bytes calldata cidraw, bytes calldata provider, uint size) public {
        require(cidSet[cidraw], "CID must be added before authorizing");
        require(cidSizes[cidraw] == size, "Data size must match expected");
        require(policyOK(proposalID), "Deal failed policy check: Was the CID proposal Passed?");
        cidProviders[cidraw][provider] = true;
    }

    function handle_filecoin_method(uint64, uint64 method, bytes calldata params, uint256 proposalID) public {
        // dispatch methods
        if (method == AUTHORIZE_MESSAGE_METHOD_NUM) {
            bytes calldata deal_proposal_cbor_bytes = specific_authenticate_message_params_parse(params);
            (bytes calldata cidraw, bytes calldata provider, uint size) = specific_deal_proposal_cbor_parse(deal_proposal_cbor_bytes);
            cidraw = bytes(bytes(cidraw));
            authorizeData(proposalID, cidraw, provider, size);
        } else {
            revert("The Filecoin method that was called is not handled");
        }
    }

}