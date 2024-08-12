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

import {ERC20} from "solady/src/tokens/ERC20.sol";

contract MockERC20 is ERC20 {
    string internal _name;
    string internal _symbol;

    constructor() {
        _name = "MockERC20";
        _symbol = "MERC";
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
