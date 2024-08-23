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
abstract contract CoreMetadata1155 is ERC1155, CoreMetadata, ICoreMetadata1155 {
    function name() public view virtual returns (string memory name_) {
        return _name;
    }

    function symbol() public view virtual returns (string memory symbol_) {
        return _symbol;
    }

    function uri(uint256 tokenId_) public view virtual override returns (string memory tokenURI_) {
        return _tokenURI(tokenId_);
    }

    function setContractURI(string memory contractURI_) external virtual onlyOwner {
        CoreMetadata._setContractURI(contractURI_);
    }

    /**
     * @notice Sets the token URI for a specific token.
     * @param tokenId_ The ID of the token.
     * @param tokenURI_ The new token URI.
     */
    function setURI(uint256 tokenId_, string memory tokenURI_) external virtual onlyOwner {
        CoreMetadata._setTokenURI(tokenId_, tokenURI_);

        emit URI(tokenURI_, tokenId_);
        emit MetadataUpdate(tokenId_);
    }

    function setBaseURI(string memory baseURI_, string memory fileExtension_) external virtual onlyOwner {
        CoreMetadata._setBaseURI(baseURI_, fileExtension_);

        emit BatchMetadataUpdate(0, maxSupply);
    }

    function freezeURI() external virtual onlyOwner {
        CoreMetadata._freezeURI();
    }

    function freezeTokenURI(uint256 tokenId_) external virtual onlyOwner {
        CoreMetadata._freezeTokenURI(tokenId_);
    }

    function supportsInterface(bytes4 interfaceId_) public view virtual override returns (bool) {
        return interfaceId_ == 0x49064906 // IERC4906
            || ERC1155.supportsInterface(interfaceId_);
    }
}
