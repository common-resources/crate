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
 * @title IReferralExt
 * @author 0xKrauser (Discord/Github/X: @0xKrauser, Email: krauser@co.xyz)
 * @notice Interface to integrate ReferralExt and require missing external functions.
 * @custom:github https://github.com/common-resources/crate
 */
interface IReferralExt {
    /**
     * @dev Emitted when the referral fee is updated.
     * @param referralFee_ The new referral fee.
     */
    event ReferralFeeUpdate(uint16 indexed referralFee_);

    /**
     * @dev Emitted when a referral fee is paid.
     * @param referral_ The address of the referrer.
     * @param value_ The value of the referral fee.
     */
    //@TODO * @param _referred The address of the referred account.
    //@TODO * @param _amount The amount of tokens minted.
    event Referral(address indexed referral_, uint256 indexed value_);

    /// @dev Self-referral to either msg.sender or recipient is not allowed.
    error SelfReferral();

    /// @dev The referral fee is above the maximum value.
    error MaxReferral();

    /**
     * @notice Sets the referral fee for minting.
     * @dev The referral fee is a percentage of the mint value that is paid to the referrer.
     * @param bps_ The new referral fee, must be < (_DENOMINATOR_BPS - allocation).
     */
    function setReferralFee(uint16 bps_) external;
}
