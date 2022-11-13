// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/DealClient.sol";

contract DealClientTest is Test {
    DealClient public client;

    function setUp() public {
        client = new DealClient();
    }
    // function testSetNumber(uint256 x) public {
    //     counter.setNumber(x);
    //     assertEq(counter.number(), x);
    // }
}
