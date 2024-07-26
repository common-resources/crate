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

pragma solidity ^0.8.26;

import {Asset as tAsset} from "../blacklist/Asset.sol";
import {IBlacklistExt} from "../blacklist/IBlacklistExt.sol";

import {EnumerableSetLib} from "solady/src/utils/EnumerableSetLib.sol";

/**
 * @title BlacklistExt
 * @author Zodomo (Discord/Github: Zodomo, X: @0xZodomo, Email: zodomo@proton.me)
 * @author 0xKrauser (Discord/Github/X: @0xKrauser, Email: krauser@co.xyz)
 * @notice Core Extension for managing a blacklist of assets and permission their owners.
 * @custom:github https://github.com/common-resources/crate
 */
abstract contract BlacklistExt is IBlacklistExt {
    using EnumerableSetLib for EnumerableSetLib.AddressSet;

    /// @dev Enumerable set of blacklisted asset addresses.
    EnumerableSetLib.AddressSet internal _blacklist;

    /// @inheritdoc IBlacklistExt
    function getBlacklist() external view virtual returns (address[] memory blacklist_) {
        return _blacklist.values();
    }

    // @TODO: shouldn't blacklisted also be enforced on transfer?

    /**
     * @notice Adds or removes assets to the blacklist.
     * @param assets_ The list of addresses to be blacklisted.
     * @param status_ The status to which they have been updated.
     */
    function _setBlacklist(address[] calldata assets_, bool status_) internal virtual {
        for (uint256 i; i < assets_.length; ++i) {
            if (status_) _blacklist.add(assets_[i]);
            else _blacklist.remove(assets_[i]);
        }
        emit BlacklistUpdate(assets_, status_);
    }

    /**
     * @dev Blacklist function to prevent mints to and from holders of prohibited assets,
     * applied both on minter and recipient
     * @param recipient_ The address of the recipient.
     */
    function _enforceBlacklist(address recipient_) internal virtual {
        address[] memory blacklist = _blacklist.values();
        uint256 count;
        for (uint256 i = 1; i < blacklist.length;) {
            unchecked {
                count += tAsset.wrap(blacklist[i]).balanceOf(msg.sender);
                count += tAsset.wrap(blacklist[i]).balanceOf(recipient_);
                if (count > 0) revert Blacklisted();
                ++i;
            }
        }
    }
}
