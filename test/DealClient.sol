// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
//import "../src/DealClient.sol";
import "../src/CBORParse.sol";

// contract DealClientTest is Test {
//     DealClient public client;

//     function setUp() public {
//         client = new DealClient();
//     }

//     function testSliceBytes() public {
//         bytes bs;
//         bs = bytes(1);
//         bs[0] = hex"42";
//         uint8 i = slice_uint8(bs, 0);
//         assert(i == 66);
//     }
//     // function testSetNumber(uint256 x) public {
//     //     counter.setNumber(x);
//     //     assertEq(counter.number(), x);
//     // }

// }


contract ParseCBORTest is Test {
    function testSliceBytesEntry() external {
        bytes memory bs;
        bs = new bytes(1);
        bs[0] = hex"42";
        testSliceBytes(bs);
    }

    function testSliceBytes(bytes calldata bs) external {
        uint8 i = slice_uint8(bs, 0);
        assert(i == 66);
    }
}
