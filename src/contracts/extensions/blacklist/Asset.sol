/*
 * SPDX-License-Identifier: AGPL-3.0-only
 *
 * SPDX-FileType: SOURCE
 *
 * SPDX-FileCopyrightText: 2024 jtriley.eth <Jtriley15@gmail.com>
 * 
 * SPDX-FileContributor: jtriley.eth <Jtriley15@gmail.com>
 * SPDX-FileContributor: Modified by Johannes Krauser III <krauser@co.xyz>
 */

pragma solidity ^0.8.26;

/**
 * @title Asset
 * @author jtriley.eth (Github: jtriley-eth, Email: Jtriley15@gmail.com)
 * @notice Minimal "token-types"-like interface for token assets with a balance.
 * @custom:github https://github.com/common-resources/crate
 */

type Asset is address;

using {
    balanceOf,
    // -- operators
    eq as ==,
    neq as !=,
    gt as >,
    gte as >=,
    lt as <,
    lte as <=,
    add as +,
    sub as -,
    mul as *,
    div as /,
    mod as %,
    and as &,
    or as |,
    xor as ^,
    not as ~
} for Asset global;

// -------------------------------------------------------------------------------------------------
// Query Asset.balanceOf without allocating new memory.
//
// Procedures:
//      01. store balanceOf selector in memory
//      02. store owner in memory
//      03. staticcall balanceOf; cache as ok
//      04. check that the return value is 32 bytes; compose with ok
//      05. revert if ok is false
//      06. assign the return value to output
function balanceOf(Asset erc721, address owner) view returns (uint256 output) {
    assembly ("memory-safe") {
        mstore(0x00, 0x70a0823100000000000000000000000000000000000000000000000000000000)

        mstore(0x04, owner)

        let ok := staticcall(gas(), erc721, 0x00, 0x24, 0x00, 0x20)

        ok := and(ok, eq(returndatasize(), 0x20))

        if iszero(ok) { revert(0x00, 0x00) }

        output := mload(0x00)
    }
}

// -------------------------------------------------------------------------------------------------
// Returns `true` if the two Asset instances are equal, `false` otherwise.
function eq(Asset lhs, Asset rhs) pure returns (bool output) {
    assembly {
        output := eq(lhs, rhs)
    }
}

// -------------------------------------------------------------------------------------------------
// Returns `true` if the two Asset instances are not equal, `false` otherwise.
function neq(Asset lhs, Asset rhs) pure returns (bool output) {
    assembly {
        output := iszero(eq(lhs, rhs))
    }
}

// -------------------------------------------------------------------------------------------------
// Returns `true` if `lhs` is greater than `rhs`, `false` otherwise.
function gt(Asset lhs, Asset rhs) pure returns (bool output) {
    assembly {
        output := gt(lhs, rhs)
    }
}

// -------------------------------------------------------------------------------------------------
// Returns `true` if `lhs` is greater than or equal to `rhs`, `false` otherwise.
function gte(Asset lhs, Asset rhs) pure returns (bool output) {
    assembly {
        output := iszero(lt(lhs, rhs))
    }
}

// -------------------------------------------------------------------------------------------------
// Returns `true` if `lhs` is less than `rhs`, `false` otherwise.
function lt(Asset lhs, Asset rhs) pure returns (bool output) {
    assembly {
        output := lt(lhs, rhs)
    }
}

// -------------------------------------------------------------------------------------------------
// Returns `true` if `lhs` is less than or equal to `rhs`, `false` otherwise.
function lte(Asset lhs, Asset rhs) pure returns (bool output) {
    assembly {
        output := iszero(gt(lhs, rhs))
    }
}

// -------------------------------------------------------------------------------------------------
// Returns the sum of two Asset instances.
function add(Asset lhs, Asset rhs) pure returns (Asset output) {
    assembly {
        output := add(lhs, rhs)

        if gt(output, 0xffffffffffffffffffffffffffffffffffffffff) { revert(0x00, 0x00) }
    }
}

// -------------------------------------------------------------------------------------------------
// Returns the difference of two Asset instances.
function sub(Asset lhs, Asset rhs) pure returns (Asset output) {
    assembly {
        output := sub(lhs, rhs)

        if gt(output, 0xffffffffffffffffffffffffffffffffffffffff) { revert(0x00, 0x00) }
    }
}

// -------------------------------------------------------------------------------------------------
// Returns the product of two Asset instances.
function mul(Asset lhs, Asset rhs) pure returns (Asset output) {
    assembly {
        if lhs {
            output := and(mul(lhs, rhs), 0xffffffffffffffffffffffffffffffffffffffff)

            if iszero(eq(div(output, lhs), rhs)) { revert(0x00, 0x00) }
        }
    }
}

// -------------------------------------------------------------------------------------------------
// Returns the division of two Asset instances.
function div(Asset lhs, Asset rhs) pure returns (Asset output) {
    assembly {
        if iszero(rhs) { revert(0x00, 0x00) }
        output := div(lhs, rhs)
    }
}

// -------------------------------------------------------------------------------------------------
// Returns the modulus of two Asset instances.
function mod(Asset lhs, Asset rhs) pure returns (Asset output) {
    assembly {
        if iszero(rhs) { revert(0x00, 0x00) }

        output := mod(lhs, rhs)
    }
}

// -------------------------------------------------------------------------------------------------
// Returns the bitwise AND of two Asset instances.
function and(Asset lhs, Asset rhs) pure returns (Asset output) {
    assembly {
        output := and(lhs, rhs)
    }
}

// -------------------------------------------------------------------------------------------------
// Returns the bitwise OR of two Asset instances.
function or(Asset lhs, Asset rhs) pure returns (Asset output) {
    assembly {
        output := or(lhs, rhs)
    }
}

// -------------------------------------------------------------------------------------------------
// Returns the bitwise XOR of two Asset instances.
function xor(Asset lhs, Asset rhs) pure returns (Asset output) {
    assembly {
        output := xor(lhs, rhs)
    }
}

// -------------------------------------------------------------------------------------------------
// Returns the bitwise NOT of an Asset instance.
function not(Asset lhs) pure returns (Asset output) {
    assembly {
        output := and(not(lhs), 0xffffffffffffffffffffffffffffffffffffffff)
    }
}
