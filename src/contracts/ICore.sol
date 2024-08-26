/*
 * SPDX-License-Identifier: NOASSERTION
 *
 * SPDX-FileType: SOURCE
 *
 * SPDX-FileCopyrightText: 2024 Johannes Krauser III <krauser@co.xyz>, Zodomo <zodomo@proton.me>
 * 
 * SPDX-FileContributor: Zodomo <zodomo@proton.me>
 * SPDX-FileContributor: Johannes Krauser III <krauser@co.xyz>
 */

pragma solidity 0.8.23;

/// @dev Input alue is zero, not allowed
error NotZero();

/// @dev Transfer of ether to an address failed.
error TransferFailed();

/**
 * @title ICore
 * @author 0xKrauser (Discord/Github/X: @0xKrauser, Email: krauser@co.xyz)
 * @notice Interface to integrate Core and require missing external functions.
 * @custom:github https://github.com/common-resources/crate
 */
interface ICore {
    // >>>>>>>>>>>> [ ERRORS ] <<<<<<<<<<<<

    /// @dev End timestamp needs to be either 0 (no end) or greater than start time
    error TimestampEnd();

    /// @dev Cannot mint with a msg.value lower than the price for one token.
    error InsufficientPayment();

    /// @dev The minting process for this list has ended or not started yet.
    error TimeOutOfBounds();

    /// @dev maxSupply has been reached.
    error MaxSupply();

    /// @dev msg.sender/recipient has already claimed the maximum allocation.
    error ClaimSupply();

    /// @dev After at least one mint, the maxSupply cannot be increased.
    error CannotIncreaseMaxSupplyAfterMint();

    /// @dev Cannot set maxSupply to a value lower than the current supply.
    error UnderSupply();

    // >>>>>>>>>>>> [ EVENTS ] <<<<<<<<<<<<

    /**
     * @dev Emitted when a new nft contract is created.
     * @param name_ The name of the nft contract.
     * @param symbol_ The symbol of the nft contract.
     * @custom:unique
     */
    event ContractCreated(string name_, string symbol_);

    /**
     * @dev Emitted when the price is updated.
     * @param price_ The new price.
     */
    event PriceUpdate(uint256 price_);

    /**
     * @dev Emitted when the supply is updated.
     * @param supply_ The new supply.
     */
    event SupplyUpdate(uint256 supply_);

    /**
     * @notice Emitted when the minting range is updated.
     * @param start_ The new start timestamp of the public mint.
     * @param end_ The new end timestamp of the public mint.
     */
    event MintPeriodUpdate(uint256 start_, uint256 end_);

    /**
     * @dev Emitted when the maximum claimable tokens per user are updated.
     * @param claimable_ The new amount of tokens available per address.
     */
    event UserClaimableUpdate(uint256 claimable_);

    /**
     * @dev Emitted when the default unit amount of tokens minted is updated.
     * @param unit_ The new amount of tokens you mint for every 1 you pay.
     */
    event UnitUpdate(uint256 unit_);

    /**
     * @dev Emitted when the contract owner withdraws funds.
     *
     * @param to_ The address to which the funds are withdrawn.
     * @param amount_ The amount of funds withdrawn.
     */
    event Withdraw(address indexed to_, uint256 amount_);

    /**
     * @notice Emitted when a new mint is executed.
     * @dev Needed in order to keep track of the claimed supply.
     * @param minter_ The address of the minter.
     * @param amount_ The amount of tokens minted.
     */
    event Minted(address indexed minter_, uint256 amount_);
}
