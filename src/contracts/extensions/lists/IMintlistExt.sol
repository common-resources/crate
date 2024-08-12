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
 * @dev Represents a custom mint configuration.
 *
 * This struct contains the following fields:
 * @param root The root hash of the merkle tree.
 * @param issued The number of tokens already issued.
 * @param claimed The number of tokens that can be claimed by a single address.
 * @param supply The total supply of tokens.
 * @param price The price of each token.
 */
struct MintList {
    bytes32 root;
    uint256 price;
    uint32 unit;
    uint32 userSupply;
    uint32 maxSupply;
    uint32 start;
    uint32 end;
    bool reserved;
    bool paused;
}

/**
 * @title IMintlistExt
 * @author 0xKrauser (Discord/Github/X: @0xKrauser, Email: krauser@co.xyz)
 * @notice Interface to integrate MintlistExt and require missing external functions.
 * @custom:github https://github.com/common-resources/crate
 */
interface IMintlistExt {
    /**
     * @dev Emitted when someone mints from a list.
     * @param minter_ The address of the minter.
     * @param listId_ The ID of the custom mint list.
     * @param amount_ The amount of tokens minted.
     */
    event ListMinted(address indexed minter_, uint8 indexed listId_, uint256 indexed amount_);

    /**
     * @dev Emitted when a custom mint list is disabled.
     * @param listId_ The ID of the custom mint list.
     * @param paused_ The paused status of the custom mint list.
     */
    event MintListStatus(uint8 indexed listId_, bool indexed paused_);

    /**
     * @dev Emitted when a custom mint list is deleted.
     * @param listId_ The ID of the custom mint list.
     * @custom:unique
     */
    event MintListDeleted(uint8 indexed listId_);

    /**
     * @dev Emitted when a custom mint list is configured.
     * @param listId_ The ID of the custom mint list.
     * @param _list The configuration of the list.
     */
    event MintListUpdate(uint8 indexed listId_, MintList _list);

    /// @dev List is deleted
    error ListDeleted();

    /// @dev List does not exist
    error ListUnknown();

    /// @dev Max supply is less than the current minted supply of the list
    error SupplyUnderflow();

    // @TODO
    error ReservedMaxSupply();

    /// @dev End timestamp needs to be either 0 (no end) or greater than start time
    error ListTimestampEnd();

    /// @dev List is paused
    error ListPaused();

    /// @dev Can not mint if the amount trespasses the supply reserved for the list(s)
    error ReservedSupply();

    /// @dev List max supply has been reached
    error ListMaxSupply();

    /// @dev msg.sender/recipient has already claimed the maximum allocation for a given MintList.
    error ListClaimSupply();

    /// @dev msg.sender/recipient is not eligible to claim any mint allocation for a given MintList.
    error NotEligible();

    /// @dev The minting process for this list has ended or not started yet.
    error ListTimeOutOfBounds();

    function listIndex() external view returns (uint8);

    function getList(uint8 listId_) external view returns (MintList memory);

    function listClaimedOf(uint8 listId_, address wallet_) external view returns (uint256 claimed_);

    function listSupply(uint8 listId_) external view returns (uint32);

    /**
     * @notice Configures a custom mint list with a merkle root, mintable amount, and price.
     * @dev If list already exists, adjusts the configuration to the new values.
     * @param listId_ The ID of the custom mint list.
     */
    function setList(
        uint256 price_,
        uint8 listId_,
        bytes32 root_,
        uint32 userSupply_,
        uint32 maxSupply_,
        uint32 start_,
        uint32 end_,
        uint32 unit_,
        bool reserved_,
        bool paused_
    )
        external;

    /**
     * @notice Pauses a custom mint list.
     * @param listId_ The ID of the custom mint list.
     */
    function pauseList(uint8 listId_) external;

    /**
     * @notice Unpauses a custom mint list.
     * @param listId_ The ID of the custom mint list.
     */
    function unpauseList(uint8 listId_) external;

    /**
     * @notice Deletes a custom mint list.
     * @param listId_ The ID of the custom mint list.
     */
    function deleteList(uint8 listId_) external;
}
