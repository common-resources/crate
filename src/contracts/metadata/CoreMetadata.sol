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

import {ICoreMetadata} from "./ICoreMetadata.sol";

import {LibString} from "solady/src/utils/LibString.sol";

/**
 * @title CoreMetadata
 * @author 0xKrauser (Discord/Github/X: @0xKrauser, Email: krauser@co.xyz)
 * @notice Core Advancement laying out the basics of a contract integrating token uri / metadata features.
 * @custom:github https://github.com/common-resources/crate
 */
abstract contract CoreMetadata is ICoreMetadata {
    using LibString for uint256; // Used to convert uint256 tokenId to string for tokenURI()

    /**
     * @dev Name of the collection.
     * e.g. "Milady Maker"
     * @custom:immutable
     */
    string internal _name;

    /**
     * @dev Symbol of the collection.
     * e.g. "MILADY"
     * @custom:immutable
     */
    string internal _symbol;

    /**
     * @dev Base URI for the collection tokenURIs.
     * e.g. "https://miladymaker.net/", "ipfs://QmXyZ/", "ar://QmXyZ/"
     */
    string internal _baseURI;

    /// @dev Mapping of token IDs to their respective tokenURIs, optional override.
    mapping(uint256 tokenId_ => string uri) internal _tokenURIs;

    /**
     * @dev File extension for the collection tokenURIs.
     * e.g. ".json", ".jsonc", "" (empty)
     */
    string internal _fileExtension;

    /**
     * @dev Contract URI for the collection.
     * e.g. "ipfs://QmXyZ/contract.json", "ar://QmXyZ/contract.json", or a stringified JSON object.
     * @custom:documentation https://docs.opensea.io/docs/contract-level-metadata
     */
    string internal _contractURI;

    /// @dev indicates that the metadata for the entire collection is frozen and cannot be updated anymore
    bool public permanentURI;

    /// @dev Mapping of token IDs to their respective permanentURI state.
    mapping(uint256 tokenId_ => bool isPermanent) internal _permanentTokenURIs;

    /**
     * @notice Returns the contract metadata URI for the collection.
     * @return contractURI_ a string representing the contract metadata URI or a stringified JSON object.
     */
    function contractURI() external view virtual returns (string memory contractURI_) {
        return _contractURI;
    }

    /**
     * @inheritdoc ICoreMetadata
     */
    function baseURI() external view virtual returns (string memory) {
        return _baseURI;
    }

    function _tokenURI(uint256 tokenId_) internal view virtual returns (string memory) {
        string memory tokenURI = _tokenURIs[tokenId_];

        if (bytes(tokenURI).length > 0) {
            return tokenURI;
        }

        string memory newBaseURI = _baseURI;

        return bytes(newBaseURI).length > 0
            ? string(abi.encodePacked(newBaseURI, tokenId_.toString(), _fileExtension))
            : "";
    }

    /**
     * @notice Sets the contract metadata URI.
     * @dev This URI is used to store contract-level metadata.
     * @param contractURI_ The new contract metadata URI.
     */
    function _setContractURI(string memory contractURI_) internal virtual {
        _contractURI = contractURI_;
        emit ContractMetadataUpdate(contractURI_);
    }

    /**
     * @notice Sets the base URI for the collection tokenURIs.
     * @param baseURI_ The new base URI.
     * @param fileExtension_ The file extension for the collection tokenURIs. e.g. ".json"
     */
    function _setBaseURI(string memory baseURI_, string memory fileExtension_) internal virtual {
        if (permanentURI) revert URIPermanent();
        _baseURI = baseURI_;
        _fileExtension = fileExtension_;

        emit BaseURIUpdate(baseURI_, fileExtension_);
    }

    function _setTokenURI(uint256 tokenId_, string memory tokenURI_) internal virtual {
        if (permanentURI || _permanentTokenURIs[tokenId_]) revert URIPermanent();
        _tokenURIs[tokenId_] = tokenURI_;

        emit URI(tokenURI_, tokenId_);
    }

    /**
     * @notice Freezes the metadata for the entire collection.
     * @dev Once the metadata is frozen, it cannot be updated anymore.
     */
    function _freezeURI(uint256 maxSupply_) internal virtual {
        permanentURI = true;

        emit BatchPermanentURI(0, maxSupply_);
    }

    /**
     * @notice Freezes the metadata for a specific token.
     * @param tokenId_ The ID of the token.
     */
    function _freezeTokenURI(uint256 tokenId_) internal virtual {
        if (permanentURI) revert URIPermanent();

        _permanentTokenURIs[tokenId_] = true;

        string memory staticURI = _tokenURI(tokenId_);
        _tokenURIs[tokenId_] = staticURI;

        emit PermanentURI(staticURI, tokenId_);
    }
}
