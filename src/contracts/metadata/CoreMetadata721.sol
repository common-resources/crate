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

// ICoreMetadata is imported for passing to child contracts
import {CoreMetadata, ICoreMetadata} from "./CoreMetadata.sol";

import {ICoreMetadata721} from "./ICoreMetadata721.sol";

import {ERC721} from "solady/src/tokens/ERC721.sol";

import {IERC165} from "@openzeppelin/contracts/interfaces/IERC165.sol";
import {IERC4906} from "@openzeppelin/contracts/interfaces/IERC4906.sol";

/**
 * @title CoreMetadata721
 * @author 0xKrauser (Discord/Github/X: @0xKrauser, Email: krauser@co.xyz)
 * @notice CoreMetadata Advancement for metadata behavior specific of ERC721.
 * @dev ERC721 is imported at this stage as no further forks are expected to require inheriting from a different token
 * contract.
 * @custom:github https://github.com/common-resources/crate
 */
abstract contract CoreMetadata721 is CoreMetadata, ERC721, ICoreMetadata721 {
    function name() public view virtual override returns (string memory name_) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory symbol_) {
        return _symbol;
    }

    /// @inheritdoc ICoreMetadata721
    function tokenURI(uint256 tokenId_)
        public
        view
        virtual
        override(ICoreMetadata721, ERC721)
        returns (string memory tokenURI_)
    {
        return _tokenURI(tokenId_);
    }

    /**
     * @notice Sets the token URI for a specific token.
     * @param tokenId_ The ID of the token.
     * @param tokenURI_ The new token URI.
     */
    function _setTokenURI(uint256 tokenId_, string memory tokenURI_) internal virtual override {
        CoreMetadata._setTokenURI(tokenId_, tokenURI_);

        emit MetadataUpdate(tokenId_);
    }

    function _setBaseURI(string memory baseURI_, string memory fileExtension_, uint256 maxSupply_) internal virtual {
        CoreMetadata._setBaseURI(baseURI_, fileExtension_);

        emit BatchMetadataUpdate(0, maxSupply_);
    }

    function supportsInterface(bytes4 interfaceId_) public view virtual override returns (bool) {
        return interfaceId_ == 0x5b5e139f // ERC721Metadata
            || interfaceId_ == 0x49064906 // IERC4906
            || ERC721.supportsInterface(interfaceId_);
    }
}
