/*
 * SPDX-License-Identifier: NOASSERTION
 *
 * SPDX-FileType: SOURCE
 *
 * SPDX-FileCopyrightText: 2024 Johannes Krauser III <krauser@co.xyz>, Zodomo <zodomo@proton.me>
 * 
 * SPDX-FileContributor: Johannes Krauser III <krauser@co.xyz>
 */

pragma solidity ^0.8.26;

import {Core} from "../contracts/Core.sol";

import {Test} from "forge-std/src/Test.sol";

contract CoreDeabstracted is Core {
    constructor() {
        _setOwner(msg.sender);
    }
}

contract CoreTest is Test {
    CoreDeabstracted core;

    function setUp() public {
        core = new CoreDeabstracted();
    }

    function testDeposit() public {
        (bool success,) = address(core).call{value: 1 ether}("");
        assertTrue(success);
    }

    receive() external payable {}
}
