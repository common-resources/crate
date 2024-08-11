/*
 * SPDX-License-Identifier: NOASSERTION
 *
 * SPDX-FileType: SOURCE
 *
 * SPDX-FileCopyrightText: 2024 Johannes Krauser III <krauser@co.xyz>, Zodomo <zodomo@proton.me>
 * 
 * SPDX-FileContributor: Zodomo <zodomo@proton.me> Attention <attentionenjoyer@gmail.com>
 */

pragma solidity ^0.8.26;

import {Core} from "../contracts/Core.sol";
import {ICore, TransferFailed, NotZero} from "../contracts/ICore.sol";
import {ICoreMetadata} from "../contracts/metadata/ICoreMetadata.sol";
import {ICoreMetadata721} from "../contracts/metadata/ICoreMetadata721.sol";
import {IRoyaltyExt} from "../contracts/extensions/royalty/IRoyaltyExt.sol";
import {IReferralExt} from "../contracts/extensions/referral/IReferralExt.sol";
import {ERC721Crate} from "../contracts/ERC721Crate.sol";
import {MockERC20} from "./utils/MockERC20.sol";
import {MockERC721} from "./utils/MockERC721.sol";

import {Test} from "forge-std/src/Test.sol";
import {console} from "forge-std/src/console.sol";
import {LibString} from "solady/src/utils/LibString.sol";
import {LibClone} from "solady/src/utils/LibClone.sol";
import {ERC2981} from "solady/src/tokens/ERC2981.sol";
import {FixedPointMathLib} from "solady/src/utils/FixedPointMathLib.sol";

import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import {ERC721} from "solady/src/tokens/ERC721.sol";
import {Ownable} from "solady/src/auth/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";

contract ERC721CrateTest is Test, ERC721Holder {
    using LibString for uint256;

    ERC721Crate public masterCopy;
    ERC721Crate public template;
    ERC721Crate public manualInit;
    MockERC20 public testToken;
    MockERC721 public testNFT;

    function _bytesToAddress(bytes32 fuzzedBytes) internal pure returns (address) {
        return address(uint160(uint256(keccak256(abi.encode(fuzzedBytes)))));
    }

    function setUp() public {
        masterCopy = new ERC721Crate();
        template = ERC721Crate(payable(LibClone.cloneDeterministic(address(masterCopy), bytes32(0x0))));
        manualInit = ERC721Crate(payable(LibClone.cloneDeterministic(address(masterCopy), bytes32(uint256(0x1)))));
        template.initialize(
            "ERC721Crate Test",
            "ERC721Crate",
            100,
            500,
            address(this),
            0.01 ether
        );

        template.setBaseURI("https://miya.wtf/api/", "");
        template.setContractURI("https://miya.wtf/contract.json");

        vm.deal(address(this), 1000 ether);
        testToken = new MockERC20();
        testToken.mint(address(this), 100 ether);
        testNFT = new MockERC721();
        testNFT.mint(address(this), 1);
        testNFT.mint(address(this), 2);
        testNFT.mint(address(this), 3);
    }

    function testInitialize(
        string memory name,
        string memory symbol,
        string memory baseURI,
        string memory contractURI,
        uint32 maxSupply,
        uint16 royalty,
        bytes32 ownerSalt,
        uint256 price
    ) public {
        vm.assume(bytes(name).length > 0 && bytes(symbol).length > 0 &&
            bytes(baseURI).length > 0 && bytes(contractURI).length > 0);

        address owner = _bytesToAddress(ownerSalt);

        if (royalty > 1000) {
            vm.expectRevert(IRoyaltyExt.MaxRoyalties.selector);
            manualInit.initialize(name, symbol, maxSupply, royalty, owner, price);
            return;
        } else if (owner == address(0)) {
            vm.expectRevert(ERC2981.RoyaltyReceiverIsZeroAddress.selector);
            manualInit.initialize(name, symbol, maxSupply, royalty, owner, price);
            return;
        }
        manualInit.initialize(name, symbol, maxSupply, royalty, owner, price);
        
        vm.startPrank(owner);
        manualInit.setBaseURI(baseURI, "");
        manualInit.setContractURI(contractURI);
        vm.stopPrank();

        assertEq(abi.encode(name), abi.encode(manualInit.name()), "name error");
        assertEq(abi.encode(symbol), abi.encode(manualInit.symbol()), "symbol error");
        assertEq(abi.encode(baseURI), abi.encode(manualInit.baseURI()), "baseURI error");
        assertEq(abi.encode(contractURI), abi.encode(manualInit.contractURI()), "contractURI error");
        assertEq(maxSupply, manualInit.maxSupply(), "maxSupply error");
        (, uint256 _royalty) = manualInit.royaltyInfo(0, 1 ether);
        assertEq(royalty, (_royalty * 10000) / 1 ether, "royalty error");
        assertEq(owner, manualInit.owner(), "owner error");
    }

    function testSupportsInterface(bytes4 interfaceId) public view {
        if (
            interfaceId == 0x2a55205a || // ERC2981
            interfaceId == 0x80ac58cd || // ERC721
            interfaceId == 0x5b5e139f || // ERC721
            interfaceId == 0x01ffc9a7 // ERC165
        ) assertEq(template.supportsInterface(interfaceId), true, "supportsInterface error");
        else assertEq(template.supportsInterface(interfaceId), false, "supportsInterface error");
    }

    function testTokenURI() public {
        template.unpause();
        template.mint{value: 0.01 ether}(address(this), 1);
        assertEq(
            keccak256(abi.encodePacked(template.tokenURI(1))),
            keccak256(
                    abi.encodePacked(string.concat("https://miya.wtf/api/", uint256(template.totalSupply()).toString()))
            )
        );
    }

    function testTokenURIRevertNotMinted() public {
        vm.expectRevert(ERC721.TokenDoesNotExist.selector);
        template.tokenURI(1);
    }

    function testSetPrice(uint80 _price) public {
        vm.assume(_price >= 10 gwei);
        vm.assume(_price <= 1 ether);
        template.setPrice(_price);
        assertEq(template.price(), _price);
    }

    function testSetReferralFee(uint16 referralFee, uint16 invalidFee) public {
        referralFee = uint16(bound(referralFee, 1, 10000));
        invalidFee = uint16(bound(invalidFee, 10001, type(uint16).max));

        template.setReferralFee(referralFee);

        assertEq(template.referralFee(), referralFee, "referralFee error");

        vm.expectRevert(IReferralExt.MaxReferral.selector);
        template.setReferralFee(invalidFee);
    }

    function testSetBaseURI(string memory baseURI) public {
        vm.assume(bytes(baseURI).length > 0);

        template.setBaseURI(baseURI, "");

        assertEq(template.baseURI(), baseURI, "baseURI error");

        template.freezeURI();
        vm.expectRevert(ICoreMetadata.URIPermanent.selector);
        template.setBaseURI(baseURI, "");
    }

    function testSetBaseURIRevertURILocked() public {
        template.freezeURI();
        vm.expectRevert(ICoreMetadata.URIPermanent.selector);
        template.setBaseURI("ipfs://miyahash/", "");
    }

    function testSetContractURI(string memory contractURI) public {
        vm.assume(bytes(contractURI).length > 0);

        template.setContractURI(contractURI);

        assertEq(template.contractURI(), contractURI, "contractURI error");
    }

    function testLockURI() public {
        template.freezeURI();
        assertTrue(template.permanentURI());
    }

    function testTransferOwnership(bytes32 newOwnerSalt) public {
        vm.assume(newOwnerSalt != bytes32(""));
        address _newOwner = _bytesToAddress(newOwnerSalt);
        template.transferOwnership(_newOwner);
        assertEq(template.owner(), _newOwner, "ownership transfer error");
    }

    function testMint(bytes32 callerSalt, bytes32 recipientSalt, uint256 amount) public {
        vm.assume(callerSalt != bytes32(""));
        vm.assume(recipientSalt != bytes32(""));
        vm.assume(callerSalt != recipientSalt);
        address caller = _bytesToAddress(callerSalt);
        address recipient = _bytesToAddress(recipientSalt);
        amount = bound(amount, 0, 100);

        uint256 price = template.price();

        template.unpause();

        vm.prank(caller);
        if (amount == 0) {
            vm.deal(caller, price);
            template.mint{value: price}(recipient, 1);
            assertEq(template.balanceOf(recipient), 1, "balanceOf error");
            assertEq(template.totalSupply(), 1, "totalSupply error");
            assertEq(template.claimedOf(caller), 1, "claimedOf error");
            assertEq(address(template).balance, price, "template balance error");
        } else {
            vm.deal(caller, amount * price);
            template.mint{value: price * amount}(recipient, amount);
            assertEq(template.balanceOf(recipient), amount, "balanceOf error");
            assertEq(template.totalSupply(), amount, "totalSupply error");
            assertEq(template.claimedOf(caller), amount, "claimedOf error");
            assertEq(address(template).balance, price * amount, "template balance error");
        }
    }

    function testMintWithReferral(
        bytes32 callerSalt,
        bytes32 referrerSalt,
        bytes32 recipientSalt,
        uint16 referralFee,
        uint256 amount
    ) public {
        vm.assume(callerSalt != referrerSalt && callerSalt != recipientSalt && referrerSalt != recipientSalt);
        vm.assume(callerSalt != bytes32(""));
        vm.assume(referrerSalt != bytes32(""));
        vm.assume(recipientSalt != bytes32(""));
        address caller = _bytesToAddress(callerSalt);
        address referrer = _bytesToAddress(referrerSalt);
        address recipient = _bytesToAddress(recipientSalt);

        uint256 price = template.price();
        referralFee = uint16(bound(referralFee, 1, 8000));
        amount = bound(amount, 1, 100);
        vm.deal(caller, amount * price);

        template.setReferralFee(referralFee);
        template.unpause();
        
        uint256 refFee = FixedPointMathLib.mulDivUp(referralFee * amount, price, 10000);
        vm.prank(caller);
        template.mint{value: price * amount}(recipient, amount, referrer);
        assertEq(template.balanceOf(recipient), amount, "balanceOf error");
        assertEq(template.totalSupply(), amount, "totalSupply error");
        assertEq(template.claimedOf(caller), amount, "claimedOf error");
        assertEq(address(referrer).balance, refFee, "referrer balance error");
        assertEq(address(template).balance, (price * amount) - refFee, "template balance error");
    }

    function testMintRevertMintCapReached() public {
        template.unpause();
        template.mint{value: 0.01 ether * 100}(100);
        vm.expectRevert(ICore.MaxSupply.selector);
        template.mint{value: 0.01 ether}();
    }

    function testMintRevertMintCapExceeded() public {
        template.unpause();
        vm.expectRevert(ICore.MaxSupply.selector);
        template.mint{value: 0.01 ether * 101}(address(this), 101);
    }

    function testSetSupply(uint256 amount) public {
        vm.assume(amount > 0 && amount <= template.maxSupply());

        template.unpause();
        template.mint{value: amount*template.price()}(amount);

        uint32 maxSupply = template.maxSupply();
        uint32 totalSupply = uint32(template.totalSupply());

        template.setSupply(uint32(amount));
        vm.expectRevert(ICore.UnderSupply.selector);
        template.setSupply(totalSupply - 1);
        vm.expectRevert(ICore.MaxSupply.selector);
        template.setSupply(maxSupply + 1);
    }

    function testRescueERC20() public {
        testToken.transfer(address(template), 1 ether);
        template.rescueERC20(address(testToken), address(42));
        assertGe(testToken.balanceOf(address(42)), 1 ether);
    }

    function testRescueERC721() public {
        testNFT.transferFrom(address(this), address(template), 1);
        template.rescueERC721(address(testNFT), address(42), 1);
        assertEq(testNFT.ownerOf(1), address(42));
    }

    function testWithdrawFunds(bytes32 callerSalt, bytes32 recipientSalt, uint256 amount) public {
        vm.assume(callerSalt != recipientSalt);
        vm.assume(callerSalt != bytes32(""));
        vm.assume(recipientSalt != bytes32(""));
        amount = bound(amount, 1, 100);

        address caller = _bytesToAddress(callerSalt);
        address recipient = _bytesToAddress(recipientSalt);
        uint256 price = template.price();
        vm.deal(caller, price * amount);

        template.unpause();

        vm.prank(caller);
        template.mint{value: price * amount}(recipient, amount);

        vm.expectRevert(NotZero.selector);
        template.withdraw(address(0), type(uint256).max);

        vm.prank(recipient);
        vm.expectRevert(Ownable.Unauthorized.selector);
        template.withdraw(caller, type(uint256).max);

        template.withdraw(recipient, price);
        assertEq(address(recipient).balance, price, "partial recipient balance error");
        template.withdraw(recipient, type(uint256).max);
        assertEq(address(recipient).balance, price * amount, "full recipient balance error");
    }

    function testWithdrawFundsRevertUnauthorized(bytes32 recipientSalt) public {
        vm.assume(recipientSalt != bytes32(""));
        
        address recipient = _bytesToAddress(recipientSalt);
        uint256 price = template.price();
        template.unpause();
        template.mint{value: price}(recipient, 1);

        vm.startPrank(recipient);
        vm.expectRevert(Ownable.Unauthorized.selector);
        template.withdraw(recipient, price);
    }

    function testSetRoyalties(bytes32 recipientSalt, uint96 royaltyFee, uint96 invalidFee) public {
        vm.assume(recipientSalt != bytes32(""));
        royaltyFee = uint96(bound(royaltyFee, 0, 1000));
        invalidFee = uint96(bound(invalidFee, 1001, type(uint96).max));
        address recipient = _bytesToAddress(recipientSalt);

        template.setRoyalties(recipient, royaltyFee);

        (, uint256 royalty) = template.royaltyInfo(1, 1 ether);
        assertEq(royaltyFee, (royalty * 10000) / 1 ether, "royalty error");

        vm.expectRevert(IRoyaltyExt.MaxRoyalties.selector);
        template.setRoyalties(recipient, invalidFee);

        template.disableRoyalties();
        vm.expectRevert(IRoyaltyExt.DisabledRoyalties.selector);
        template.setRoyalties(recipient, royaltyFee);
    }

    function testSetTokenRoyalties(uint256 tokenId, bytes32 recipientSalt, uint96 royaltyFee, uint96 invalidFee) public {
        tokenId = bound(tokenId, 1, type(uint40).max);
        vm.assume(recipientSalt != bytes32(""));
        royaltyFee = uint96(bound(royaltyFee, 1, 1000));
        invalidFee = uint96(bound(invalidFee, 1001, type(uint96).max));

        address recipient = _bytesToAddress(recipientSalt);
        template.setTokenRoyalties(tokenId, recipient, royaltyFee);

        (, uint256 royalty) = template.royaltyInfo(tokenId, 1 ether);
        assertEq(royaltyFee, (royalty * 10000) / 1 ether, "royalty error");

        vm.expectRevert(IRoyaltyExt.MaxRoyalties.selector);
        template.setTokenRoyalties(tokenId, recipient, invalidFee);
        vm.expectRevert(IRoyaltyExt.MaxRoyalties.selector);
        template.setTokenRoyalties(0, recipient, invalidFee);

        template.disableRoyalties();
        vm.expectRevert(IRoyaltyExt.DisabledRoyalties.selector);
        template.setTokenRoyalties(tokenId, recipient, royaltyFee);
    }

    function testDisableRoyalties(uint256 tokenId) public {
        tokenId = bound(tokenId, 0, type(uint40).max);
        template.disableRoyalties();
        (address recipient, uint256 royalty) = manualInit.royaltyInfo(tokenId, 1 ether);
        assertEq(recipient, address(0), "royalty recipient error");
        assertEq(royalty, 0, "royalty fee error");
    }

    function testSetBlacklist(address[] memory blacklist) public {
        vm.assume(blacklist.length > 0);
        address guardValue = address(0xfbb67fda52d4bfb8bf);

        // check that generated list doesn't contain the solady's EnumerableSet guard value
        for(uint idx; idx<blacklist.length;idx++) {
            if(blacklist[idx] == guardValue) {
                blacklist[idx] = address(0x1);
            }
        }

        // check that stored list is empty at the start
        address[] memory storedBlacklist = template.getBlacklist();
        for(uint idx; idx<storedBlacklist.length;idx++) {
            assertEq(storedBlacklist[idx], address(0));
        }
        
        // Since order in AddressSet is not guaranteed delete all contents and see if it's empty
        template.setBlacklist(blacklist, true);
        storedBlacklist = template.getBlacklist();

        // check that at least one value is different from address(0)
        bool diffZero = false;
        for(uint idx; idx<storedBlacklist.length;idx++) {
            if(storedBlacklist[idx] != address(0)) {
                diffZero = true;
                break;
            }
        }
        assertTrue(diffZero);

        template.setBlacklist(blacklist, false);

        // check that stored list is empty at the end
        storedBlacklist = template.getBlacklist();
        for(uint idx; idx<storedBlacklist.length;idx++) {
            assertEq(storedBlacklist[idx], address(0));
        }
    }

    function testProcessPayment() public {
        template.unpause();
        (bool success, ) = payable(address(template)).call{value: 1 ether}("");
        assertTrue(success);
        assertGt(template.balanceOf(address(this)), 0);
    }

}