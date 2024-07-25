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

/**
 * @title ICoreMetadata721
 * @author 0xKrauser (Discord/Github/X: @0xKrauser, Email: krauser@co.xyz)
 * @notice Interface to integrate CoreMetadata721 and require missing external functions.
 * @custom:github https://github.com/common-resources/crate
 */
interface ICoreMetadata721 {
    /// @dev This event emits when the metadata of a token is updated.
    /// So that the third-party platforms such as NFT market could
    /// timely update the images and related attributes of the NFT.
    event MetadataUpdate(uint256 tokenId_);

    /// @dev This event emits when the metadata of a range of tokens is updated.
    /// So that the third-party platforms such as NFT market could
    /// timely update the images and related attributes of the NFTs.
    event BatchMetadataUpdate(uint256 fromTokenId_, uint256 toTokenId_);

    /**
     * @notice Returns the URI for the given token ID.
     * @dev if the token has a non-empty, manually set URI, it will be returned as is,
     * otherwise it will return the concatenation of the baseURI, the token ID and, optionally,  the file extension.
     * @param tokenId_ the ID of the token to query.
     * @return tokenURI_ a string representing the token URI.
     */
    function tokenURI(uint256 tokenId_) external view returns (string memory tokenURI_);
}
