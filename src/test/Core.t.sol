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

import {MockERC20} from "./utils/MockERC20.sol";
import {Test} from "forge-std/src/Test.sol";

contract CoreDeabstracted is Core {
    constructor() {
        _setOwner(msg.sender);
    }
}

contract CoreTest is Test {
    CoreDeabstracted core;
    MockERC20 token;

    function setUp() public {
        core = new CoreDeabstracted();
        token = new MockERC20();
        token.mint(address(this), 1 ether);
    }

    function testDeposit() public {
        (bool success,) = address(core).call{value: 1 ether}("");
        assertTrue(success);
    }

    function testSendERC20() public {
        token.transfer(address(core), 1 ether);
        assertEq(token.balanceOf(address(core)), 1 ether);
        assertEq(token.balanceOf(address(this)), 0);

        core.rescueERC20(address(token), address(this));
        assertEq(token.balanceOf(address(core)), 0);
        assertEq(token.balanceOf(address(this)), 1 ether);
    }

    receive() external payable {}
}
