// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Counter {
    uint256 public number;
    uint256 public fallback_set;
    bytes public fallback_calldata;

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public {
        number++;
    }

    fallback (bytes calldata input) external payable returns (bytes memory _output) {
        uint method = readMethodNum();
        fallback_set = method;
        fallback_calldata = input;
    }

    function readMethodNum() private view returns (uint method) {
        // HACK HACK HACK: we'll sub out difficulty opcode after compiling with the FVM extension
        assembly {
            method := difficulty()
        }
    }
}
