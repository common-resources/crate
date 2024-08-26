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

import {IERC721Lockable} from "erc721-lockable/contracts/IERC721Lockable.sol";

/**
 * @title ILockableExt
 * @author 0xKrauser (Discord/Github/X: @0xKrauser, Email: krauser@co.xyz)
 * @notice Interface to integrate LockableExt and require missing external functions.
 * @custom:github https://github.com/common-resources/crate
 */
interface ILockableExt is IERC721Lockable {
    error AlreadyLocked();

    error NotLocker();

    function transferFrom(address from_, address to_, uint256 tokenId_) external;

    function safeTransferFrom(address from_, address to_, uint256 tokenId_) external;
}
