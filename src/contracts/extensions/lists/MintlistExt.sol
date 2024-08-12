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

import {NotZero} from "../../ICore.sol";
import {IMintlistExt, MintList} from "./IMintlistExt.sol";

import {MerkleProofLib} from "solady/src/utils/MerkleProofLib.sol";

/**
 * @title MintlistExt
 * @author 0xKrauser (Discord/Github/X: @0xKrauser, Email: krauser@co.xyz)
 * @notice Core Extension for managing mintlists, handle limited offers and reserved whitelist supplies.
 * @custom:github https://github.com/common-resources/crate
 */
abstract contract MintlistExt is IMintlistExt {
    /// @dev Total supply of tokens reserved for the custom lists.
    uint32 internal _reservedSupply;

    /// @dev current count of custom mint lists
    uint8 public listIndex;

    /// @dev Mapping of listId to MintList data.
    mapping(uint8 listId_ => MintList list) public lists;

    /// @dev Mapping of listId to minted list supply.
    mapping(uint8 listId_ => uint32 supply) public listSupply;

    /// @dev Mapping of user to listId to already claimed amount.
    mapping(uint8 listId_ => mapping(address wallet_ => uint256 claimed)) internal _claimedList;

    function _validate(
        uint8 listId_,
        uint32 userSupply_,
        uint32 maxSupply_,
        uint32 unit_,
        uint32 start_,
        uint32 end_
    )
        internal
        view
    {
        if (listId_ > listIndex) revert ListUnknown();

        if (maxSupply_ == 0 || userSupply_ == 0 || unit_ == 0) revert NotZero();

        if (maxSupply_ < listSupply[listId_]) revert SupplyUnderflow();

        if (end_ != 0 && start_ > end_) revert ListTimestampEnd();
    }

    function getList(uint8 listId_) external view virtual returns (MintList memory) {
        return lists[listId_];
    }

    function listClaimedOf(uint8 listId_, address wallet_) external view returns (uint256) {
        return _claimedList[listId_][wallet_];
    }

    function _updateReserved(
        uint8 listId_,
        bool currentReserved_,
        bool reserved_,
        uint32 currentListMaxSupply_,
        uint32 listMaxSupply_,
        uint32 maxSupply_
    )
        internal
        virtual
    {
        unchecked {
            if (reserved_) {
                if (listMaxSupply_ > currentListMaxSupply_) {
                    _reservedSupply += listMaxSupply_ - currentListMaxSupply_;
                    if (_reservedSupply > maxSupply_) revert ReservedMaxSupply();
                } else {
                    _reservedSupply -= currentListMaxSupply_ - listMaxSupply_;
                }
            } else if (currentReserved_) {
                uint32 alreadyMinted = listSupply[listId_];
                _reservedSupply -= currentListMaxSupply_ - alreadyMinted;
            }
        }
    }

    function _setList(
        uint8 listId_,
        bytes32 root_,
        uint256 price_,
        uint32 userSupply_,
        uint32 maxSupply_,
        uint32 start_,
        uint32 end_,
        uint32 unit_,
        bool reserved_,
        bool paused_,
        uint32 contractMaxSupply_
    )
        internal
        virtual
    {
        _validate(listId_, userSupply_, maxSupply_, unit_, start_, end_);
        // If listId_ is 0, increment listCount and create new list
        // Note that since position 0 has this role, no list should be allocated in lists[0]
        uint8 id = listId_ == 0 ? ++listIndex : listId_;

        MintList storage list = lists[id];
        if (listId_ != 0 && list.userSupply == 0) revert ListDeleted();
        _updateReserved(listId_, list.reserved, reserved_, list.maxSupply, maxSupply_, contractMaxSupply_);

        list.root = root_;
        list.userSupply = userSupply_;
        list.maxSupply = maxSupply_;
        list.unit = unit_;
        list.start = start_;
        list.end = end_;
        list.price = price_;
        list.reserved = reserved_;
        list.paused = paused_;

        emit MintListUpdate(id, list);
    }

    function _pauseList(uint8 listId_, bool paused_) internal virtual {
        _requireListExists(listId_);

        MintList storage list = lists[listId_];

        if (list.userSupply == 0) revert ListDeleted();

        list.paused = paused_;
        emit MintListUpdate(listId_, list);
    }

    function _deleteList(uint8 listId_) internal virtual {
        _requireListExists(listId_);

        MintList storage list = lists[listId_];

        if (list.userSupply == 0) revert ListDeleted();

        _updateReserved(listId_, list.reserved, false, list.maxSupply, 0, 0);

        list.userSupply = 0;

        emit MintListDeleted(listId_);
    }

    function _requireListExists(uint8 listId_) internal view {
        if (listId_ == 0 || listId_ > listIndex) revert ListUnknown();
    }

    function _requireUnreservedSupply(uint256 amount_, uint32 totalSupply_, uint32 maxSupply_) internal view {
        if (amount_ > maxSupply_ - totalSupply_ - _reservedSupply) revert ReservedSupply();
    }

    function _canMintList(
        bytes32[] calldata proof_,
        uint8 listId_,
        uint32 amount_
    )
        internal
        returns (uint256 cost_, uint32 _amount_, bool reserved_)
    {
        MintList memory list = lists[listId_];
        if (list.paused) revert ListPaused();

        //@TODO maybe give the choice of basing the proof verification on the sender or the recipient?
        bytes32 leaf = keccak256(bytes.concat(keccak256(bytes.concat(abi.encode(msg.sender)))));
        if (!MerkleProofLib.verifyCalldata(proof_, list.root, leaf)) revert NotEligible();

        _amount_ = amount_ * list.unit;

        // if the list has been deleted userSupply will be 0 and this will revert
        unchecked {
            _claimedList[listId_][msg.sender] += _amount_;
            if (_claimedList[listId_][msg.sender] > list.userSupply) revert ListClaimSupply();

            listSupply[listId_] += _amount_;
            if (listSupply[listId_] > list.maxSupply) revert ListMaxSupply();
        }

        if ((list.start != 0 && block.timestamp < list.start) || (list.end != 0 && block.timestamp > list.end)) {
            revert ListTimeOutOfBounds();
        }

        // price is per unit so we multiply by the amount of units and not the amount of tokens
        cost_ = list.price * amount_;
        reserved_ = list.reserved;
    }
}
