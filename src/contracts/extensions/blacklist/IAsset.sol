/*
 * SPDX-License-Identifier: NOASSERTION
 *
 * SPDX-FileType: SOURCE
 *
 * SPDX-FileCopyrightText: 2024 Johannes Krauser III <krauser@co.xyz>, Zodomo <zodomo@proton.me>
 * 
 * SPDX-FileContributor: Zodomo <zodomo@proton.me>
 */

pragma solidity ^0.8.26;

/**
 * @title IAsset
 * @author Zodomo (Discord/Github: Zodomo, X: @0xZodomo, Email: zodomo@proton.me)
 * @notice Minimal interface for token assets with a balance.
 * @custom:github https://github.com/common-resources/crate
 */
interface IAsset {
    function balanceOf(address holder) external returns (uint256);
}
