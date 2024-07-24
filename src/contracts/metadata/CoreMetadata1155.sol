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

import {CoreMetadata} from "./CoreMetadata.sol";

import {ICoreMetadata1155} from "./ICoreMetadata1155.sol";

import {ERC1155} from "solady/src/tokens/ERC1155.sol";

/**
 * @title CoreMetadata1155
 * @author 0xKrauser (Discord/Github/X: @0xKrauser, Email: krauser@co.xyz)
 * @notice CoreMetadata Advancement for metadata behavior specific of ERC1155.
 * @dev ERC1155 is imported at this stage as no further forks are expected to require inheriting from a different token
 * contract.
 * @custom:github https://github.com/common-resources/crate
 */
abstract contract CoreMetadata1155 is CoreMetadata, ICoreMetadata1155 {
    function uri(uint256 tokenId_) public view virtual returns (string memory tokenURI_) {
        return _tokenURI(tokenId_);
    }
}
