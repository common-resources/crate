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

import {ERC721} from "solady/src/tokens/ERC721.sol";

contract MockERC721 is ERC721 {
    string internal _name;
    string internal _symbol;

    constructor() {
        _name = "MockERC721";
        _symbol = "MERC";
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function mint(address to, uint256 id) public {
        _mint(to, id);
    }

    function tokenURI(uint256) public pure override returns (string memory) {
        return "https://mockerc721.com";
    }
}
