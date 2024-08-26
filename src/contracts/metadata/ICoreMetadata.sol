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

/**
 * @title ICoreMetadata
 * @author 0xKrauser (Discord/Github/X: @0xKrauser, Email: krauser@co.xyz)
 * @notice Interface to integrate CoreMetadata and require missing external functions.
 * @custom:github https://github.com/common-resources/crate
 */
interface ICoreMetadata {
    /**
     * @dev Emitted when the contract metadata is updated.
     * @param uri_ The new contract metadata URI.
     */
    event ContractURIUpdated(string uri_);

    /**
     * @dev Emitted when the contract metadata is updated.
     * @param baseURI_ The new base metadata URI.
     * @param fileExtension_ The new file extension.
     */
    event BaseURIUpdate(string baseURI_, string fileExtension_);

    /**
     * @dev Emitted when a permanent URI is set for a specific token ID.
     *
     * @param uri_ The permanent URI value.
     * @param tokenId_ The token ID for which the permanent URI is set.
     */
    event PermanentURI(string uri_, uint256 indexed tokenId_);

    /**
     * @dev Emitted when a batch of tokens have their permanent URI set.
     * This event is emitted when a range of token IDs have their permanent URI set.
     *
     * @param fromTokenId_ The starting token ID of the range.
     * @param toTokenId_ The ending token ID of the range.
     * @custom:unique
     */
    event BatchPermanentURI(uint256 indexed fromTokenId_, uint256 indexed toTokenId_);

    /// @dev Cannot set tokenURIs or baseURI when metadata has been frozen.
    error URIPermanent();

    /**
     * @notice Returns the contract metadata URI for the collection.
     * @return contractURI_ a string representing the contract metadata URI or a stringified JSON object.
     */
    function contractURI() external view returns (string memory contractURI_);

    /**
     * @notice Returns the base URI for the collection tokenURIs.
     * @return baseURI a string representing the base URI.
     */
    function baseURI() external view returns (string memory);

    /**
     * @notice Sets the contract metadata URI.
     * @dev This URI is used to store contract-level metadata.
     * @param contractURI_ The new contract metadata URI.
     */
    function setContractURI(string memory contractURI_) external;

    /**
     * @notice Sets the base URI for the collection tokenURIs.
     * @param baseURI_ The new base URI.
     * @param fileExtension_ The file extension for the collection tokenURIs. e.g. ".json"
     */
    function setBaseURI(string memory baseURI_, string memory fileExtension_) external;

    /**
     * @notice Freezes the metadata for a specific token.
     * @param tokenId_ The ID of the token.
     */
    function freezeTokenURI(uint256 tokenId_) external;
}
