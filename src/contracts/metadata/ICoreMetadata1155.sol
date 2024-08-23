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
 * @title ICoreMetadata1155
 * @author 0xKrauser (Discord/Github/X: @0xKrauser, Email: krauser@co.xyz)
 * @notice Interface to integrate CoreMetadata1155 and require missing external functions.
 * @custom:github https://github.com/common-resources/crate
 */
interface ICoreMetadata1155 {
    /// @dev This event emits when the metadata of a token is updated.
    /// So that the third-party platforms such as NFT market could
    /// timely update the images and related attributes of the NFT.
    event MetadataUpdate(uint256 tokenId_);

    /// @dev This event emits when the metadata of a range of tokens is updated.
    /// So that the third-party platforms such as NFT market could
    /// timely update the images and related attributes of the NFTs.
    event BatchMetadataUpdate(uint256 fromTokenId_, uint256 toTokenId_);

    /**
     * @dev Sets `tokenURI` as the tokenURI of `tokenId`.
     * @param tokenId_ The token id to set the URI for.
     * @param tokenURI_ The URI to assign.
     */
    function setURI(uint256 tokenId_, string calldata tokenURI_) external;
}
