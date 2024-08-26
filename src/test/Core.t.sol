/*
 * SPDX-License-Identifier: NOASSERTION
 *
 * SPDX-FileType: SOURCE
 *
 * SPDX-FileCopyrightText: 2024 Johannes Krauser III <krauser@co.xyz>, Zodomo <zodomo@proton.me>
 * 
 * SPDX-FileContributor: Johannes Krauser III <krauser@co.xyz> Attention <attentionenjoyer@gmail.com>
 */

pragma solidity 0.8.23;

import {Core} from "../contracts/Core.sol";
import {ICore, NotZero, TransferFailed} from "../contracts/ICore.sol";

import {MockERC20} from "./utils/MockERC20.sol";
import {MockERC721} from "./utils/MockERC721.sol";

import {Test} from "forge-std/src/Test.sol";
import {ERC721} from "solady/src/tokens/ERC721.sol";

import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {Ownable} from "solady/src/auth/Ownable.sol";

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
        // mockOne is an EOA
        mockOne = vm.addr(1);
        core = new CoreDeabstracted();

        token = new MockERC20();
        token.mint(address(this), 1 ether);

        nft = new MockERC721();
        nft.mint(address(this), 1);
    }

    function testPause() public {
        // only owner address(this) should be able to call this
        vm.prank(mockOne);
        vm.expectRevert(Ownable.Unauthorized.selector);
        core.pause();

        core.pause();
        assertTrue(core.paused());
    }

    function testUnpause() public {
        // only owner address(this) should be able to call this
        vm.prank(mockOne);
        vm.expectRevert(Ownable.Unauthorized.selector);
        core.unpause();

        core.pause();
        core.unpause();
        assertTrue(!core.paused());
    }

    function testSetPrice() public {
        // only owner address(this) should be able to call this
        vm.prank(mockOne);
        vm.expectRevert(Ownable.Unauthorized.selector);
        core.setPrice(1);

        core.setPrice(42);
        assertEq(core.price(), 42);
    }

    function testSetMintPeriod() public {
        // only owner address(this) should be able to call this
        vm.prank(mockOne);
        vm.expectRevert(Ownable.Unauthorized.selector);
        core.setMintPeriod(0, 0);

        // Set start to something other than 0
        vm.warp(1_641_070_800);
        uint32 ts = uint32(block.timestamp);
        vm.expectRevert(ICore.TimestampEnd.selector);
        core.setMintPeriod(ts, ts - 1);

        core.setMintPeriod(ts, ts + 1);
        assertEq(core.start(), ts);
        assertEq(core.end(), ts + 1);
    }

    function testSetClaimableUserSupply() public {
        // only owner address(this) should be able to call this
        vm.prank(mockOne);
        vm.expectRevert(Ownable.Unauthorized.selector);
        core.setClaimableUserSupply(0);

        vm.expectRevert(NotZero.selector);
        core.setClaimableUserSupply(0);

        core.setClaimableUserSupply(42);
        assertEq(core.userSupply(), 42);
    }

    function testSetUnit() public {
        // only owner address(this) should be able to call this
        vm.prank(mockOne);
        vm.expectRevert(Ownable.Unauthorized.selector);
        core.setUnit(0);

        vm.expectRevert(NotZero.selector);
        core.setUnit(0);

        core.setUnit(42);
        assertEq(core.unit(), 42);
    }

    function testDeposit() public {
        (bool success,) = address(core).call{value: 1 ether}("");
        assertTrue(success);
        // eth should be sent to owner
        assertEq(address(core).balance, 0);
    }

    function testWithdraw() public {
        vm.deal(address(core), 1 ether);

        vm.prank(mockOne);
        // Unauthorized
        vm.expectRevert(Ownable.Unauthorized.selector);
        core.withdraw(mockOne, 1 ether);

        core.withdraw(mockOne, 1.1 ether);
        assertEq(address(core).balance, 0);
    }

    function testSendERC20() public {
        token.transfer(address(core), 1 ether);
        assertEq(token.balanceOf(address(core)), 1 ether);
        assertEq(token.balanceOf(address(this)), 0);

        // only owner address(this) should be able to call this
        vm.prank(mockOne);
        vm.expectRevert(Ownable.Unauthorized.selector);
        core.rescueERC20(address(token), address(this));

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

        // only owner address(this) should be able to call this
        vm.prank(mockOne);
        vm.expectRevert(Ownable.Unauthorized.selector);
        core.rescueERC721(address(nft), mockOne, 1);

        vm.expectRevert();
        core.rescueERC721(address(nft), address(this), 1);

        core.rescueERC721(address(nft), mockOne, 1);
        assertEq(nft.ownerOf(1), mockOne);
        assertNotEq(nft.ownerOf(1), address(core));
    }

    receive() external payable {}
}
