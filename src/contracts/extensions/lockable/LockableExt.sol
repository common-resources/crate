/*
 * SPDX-License-Identifier: NOASSERTION
 *
 * SPDX-FileType: SOURCE
 *
 * SPDX-FileCopyrightText: 2024 Johannes Krauser III <krauser@co.xyz>, Zodomo <zodomo@proton.me>
 * 
 * SPDX-FileContributor: Johannes Krauser III <krauser@co.xyz>
 */

pragma solidity 0.8.23;

import {ILockableExt} from "./ILockableExt.sol";

/**
 * @title LockableExt
 * @author 0xKrauser (Discord/Github/X: @0xKrauser, Email: krauser@co.xyz)
 * @notice Core Extension for managing locks (e.g. staking, freezing) and emitting the appropriate events.
 * @custom:github https://github.com/common-resources/crate
 */
abstract contract LockableExt is ILockableExt {
    mapping(uint256 tokenId_ => address locker_) public locked;

    function _lock(uint256 id_) internal virtual {
        if (locked[id_] != address(0)) revert AlreadyLocked();
        locked[id_] = msg.sender;
    }

    function _unlock(uint256 id_) internal virtual {
        if (locked[id_] != msg.sender) revert NotLocker();
        delete locked[id_];
    }
}
