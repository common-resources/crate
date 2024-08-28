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

import {NotZero} from "../../ICore.sol";
import {IRoyaltyExt} from "./IRoyaltyExt.sol";

import {ERC2981} from "solady/src/tokens/ERC2981.sol";

/**
 * @title RoyaltyExt
 * @author Zodomo (Discord/Github: Zodomo, X: @0xZodomo, Email: zodomo@proton.me)
 * @author 0xKrauser (Discord/Github/X: @0xKrauser, Email: krauser@co.xyz)
 * @notice Core Extension for signaling marketplaces the preferred royalties on a sale transaction.
 * @custom:github https://github.com/common-resources/crate
 */
abstract contract RoyaltyExt is IRoyaltyExt, ERC2981 {
    uint96 public defaultRoyalty;

    bool public royaltiesFrozen;

    function _requireRoyaltiesEnabled() internal view {
        // Revert if royalties are disabled
        (address receiver,) = royaltyInfo(0, 0);
        if (receiver == address(0)) revert DisabledRoyalties();
    }

    function _requireRoyaltiesUnfrozen() internal view {
        // Revert if royalties are frozen
        if (royaltiesFrozen) revert FrozenRoyalties();
    }

    function _setRoyalties(address recipient_, uint96 bps_) internal virtual {
        // Royalty recipient of nonexistent tokenId 0 is used as royalty status indicator, address(0) == disabled
        _setTokenRoyalty(0, recipient_, bps_);
        _setDefaultRoyalty(recipient_, bps_);
        defaultRoyalty = bps_;

        emit RoyaltiesUpdate(0, recipient_, bps_);
    }

    function _setTokenRoyalties(uint256 tokenId_, address recipient_, uint96 bps_) internal virtual {
        // Revert if resetting tokenId 0 as it is utilized for royalty enablement status
        if (tokenId_ == 0) revert NotZero();

        // Reset token royalty if fee is 0, else set it
        if (bps_ == 0) _resetTokenRoyalty(tokenId_);
        else _setTokenRoyalty(tokenId_, recipient_, bps_);

        emit RoyaltiesUpdate(tokenId_, recipient_, bps_);
    }

    function _freezeRoyalties() internal virtual {
        _requireRoyaltiesEnabled();
        _requireRoyaltiesUnfrozen();

        royaltiesFrozen = true;

        emit RoyaltiesFrozen();
    }

    function _disableRoyalties() internal virtual {
        _requireRoyaltiesEnabled();

        _deleteDefaultRoyalty();
        _resetTokenRoyalty(0);

        emit RoyaltiesDisabled();
    }

    function supportsInterface(bytes4 interfaceId_) public view virtual override returns (bool) {
        return ERC2981.supportsInterface(interfaceId_);
    }
}
