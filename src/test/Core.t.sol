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
import {MockERC721} from "./utils/MockERC721.sol";

import {Test} from "forge-std/src/Test.sol";
import {ERC721} from "solady/src/tokens/ERC721.sol";

contract CoreDeabstracted is Core {
    constructor() {
        _setOwner(msg.sender);
    }
}

contract CoreTest is Test {
    CoreDeabstracted core;
    MockERC20 token;
    MockERC721 nft;

    address mockOne;

    function setUp() public {
        mockOne = vm.addr(1);
        core = new CoreDeabstracted();

        token = new MockERC20();
        token.mint(address(this), 1 ether);

        nft = new MockERC721();
        nft.mint(address(this), 1);
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

    function testSendERC721() public {
        vm.expectRevert(ERC721.TransferToNonERC721ReceiverImplementer.selector);
        nft.safeTransferFrom(address(this), address(core), 1);

        nft.transferFrom(address(this), address(core), 1);
        assertEq(nft.ownerOf(1), address(core));
        assertNotEq(nft.ownerOf(1), address(this));

        vm.expectRevert();
        core.rescueERC721(address(nft), address(this), 1);

        core.rescueERC721(address(nft), mockOne, 1);
        assertEq(nft.ownerOf(1), mockOne);
        assertNotEq(nft.ownerOf(1), address(core));
    }

    receive() external payable {}
}
