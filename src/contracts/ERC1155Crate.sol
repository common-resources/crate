/*
 * SPDX-License-Identifier: NOASSERTION
 *
 * SPDX-FileType: SOURCE
 *
 * SPDX-FileCopyrightText: 2024 Johannes Krauser III <krauser@co.xyz>, Zodomo <zodomo@proton.me>
 * 
 * SPDX-FileContributor: Johannes Krauser III <krauser@co.xyz>
 */
import {Core} from "./Core.sol";
import {CoreMetadata1155} from "./metadata/CoreMetadata1155.sol";

import {RoyaltyExt} from "./extensions/royalty/RoyaltyExt.sol";

import {Initializable} from "solady/src/utils/Initializable.sol";

import {NotZero} from "./ICore.sol";

pragma solidity 0.8.23;

/**
 * @title ERC1155Crate
 * @author 0xKrauser (Discord/Github/X: @0xKrauser, Email: krauser@co.xyz)
 * @notice ERC1155 template that contains launchpad friendly features to be inherited by other contracts
 * @custom:github https://github.com/common-resources/crate
 */
contract ERC1155Crate is CoreMetadata1155, RoyaltyExt {
    error InvalidTokenId(uint256 id_);
    error TokenSupplyPermanent();

    event TokenUpdate(uint256 indexed id_, uint256 maxSupply_, uint256 userSupply_);
    event PermanentTokenSupply(uint256 indexed id_);

    mapping(uint256 id => uint256 supply) public tokenSupply;
    mapping(uint256 id => uint256 maxSupply) public tokenMaxSupply;
    mapping(uint256 id => bool status) public frozen;

    mapping(uint256 id => mapping(address => uint256)) public _claimedByToken;
    mapping(uint256 id => uint256) public userTokenSupply;

    uint256 public tokenIndex;

    function _canMint(uint256 id_, uint256 amount_) internal view returns (uint32 tokenAmount_) {
        _requireNotPaused();
        if (id_ == 0 || id_ > tokenIndex) revert InvalidTokenId(id_);

        if (msg.value < (price * amount_)) revert InsufficientPayment();

        uint256 tokenAmount = amount_ * unit;

        if (tokenSupply[id_] + tokenAmount > tokenMaxSupply[id_]) revert MaxSupply();

        if (_claimedByToken[id_][msg.sender] + tokenAmount > userTokenSupply[id_]) revert ClaimSupply();

        if ((start != 0 && block.timestamp < start) || (end != 0 && block.timestamp > end)) revert TimeOutOfBounds();

        return uint32(tokenAmount);
    }

    constructor(string memory name_, string memory symbol_, uint16 royalty_, uint256 price_) {
        _pause();
        _claimed[address(0)] = 0;

        _initializeOwner(msg.sender);
        _setRoyalties(msg.sender, royalty_);
        _name = name_;
        _symbol = symbol_;

        price = price_;

        unit = 1;
        start = 0;
        end = 0;

        emit ContractCreated(name_, symbol_);
        emit PriceUpdate(price_);
    }

    // >>>>>>>>>>>> [ INTERNAL FUNCTIONS ] <<<<<<<<<<<<

    /**
     * @notice Internal mint function for mints that do not require list logic.
     * @dev Implements referral logic.
     * @param recipient_ The address of the recipient.
     * @param amount_ The amount_ of tokens to mint.
     * @param referral_ The address of the referrer.
     */
    function _handleMint(
        address recipient_,
        uint256 id_,
        uint256 amount_,
        address referral_
    )
        internal
        virtual
        nonReentrant
    {
        uint32 tokenAmount = _canMint(id_, amount_);

        // Process ERC721 mints
        _mintBatch(recipient_, id_, tokenAmount);
    }

    /**
     * @notice Internal mint function that supports batch minting.
     * @dev Implements blacklist logic.
     * @param recipient_ The address of the recipient.
     * @param amount_ The amount of tokens to mint.
     */
    function _mintBatch(address recipient_, uint256 id_, uint32 amount_) internal virtual {
        // Prevent bad inputs
        if (recipient_ == address(0) || amount_ == 0) revert NotZero();

        unchecked {
            _claimed[msg.sender] += amount_;
            _claimedByToken[id_][msg.sender] += amount_;
            super._mint(recipient_, id_, amount_, "");
            tokenSupply[id_] += amount_;
            _totalSupply += amount_;
        }
    }

    function mint(uint256 id_, uint256 amount_) external payable virtual onlyOwner {
        _handleMint(msg.sender, id_, amount_, address(0));
    }

    // >>>>>>>>>>>> [ Royalty ] <<<<<<<<<<<<

    function setRoyalties(address recipient_, uint96 bps_) external virtual onlyOwner {
        _requireRoyaltiesEnabled();
        _setRoyalties(recipient_, bps_);
    }

    function setTokenRoyalties(uint256 tokenId_, address recipient_, uint96 bps_) external virtual onlyOwner {
        _requireRoyaltiesEnabled();
        _setTokenRoyalties(tokenId_, recipient_, bps_);
    }

    function disableRoyalties() external virtual onlyOwner {
        _disableRoyalties();
    }

    // >>>>>>>>>>>> [ VIEW / METADATA FUNCTIONS ] <<<<<<<<<<<<

    function supportsInterface(bytes4 interfaceId_)
        public
        view
        virtual
        override(RoyaltyExt, CoreMetadata1155)
        returns (bool supported_)
    {
        return RoyaltyExt.supportsInterface(interfaceId_) || CoreMetadata1155.supportsInterface(interfaceId_);
    }

    function setSupply(uint32 maxSupply_) external virtual override onlyOwner {
        // Prevent bad inputs
    }

    function setToken(uint256 id_, uint256 maxSupply_, uint256 userSupply_) external virtual onlyOwner {
        if (id_ > tokenIndex) revert InvalidTokenId(id_);
        uint256 tokenId = id_;
        if (id_ == 0) tokenId = ++tokenIndex;

        if (maxSupply_ < tokenSupply[id_]) revert UnderSupply();
        if (id_ != 0 && frozen[id_]) revert TokenSupplyPermanent();

        tokenMaxSupply[tokenId] = maxSupply_;
        userTokenSupply[tokenId] = userSupply_;

        emit TokenUpdate(tokenId, maxSupply_, userSupply_);
    }

    function freezeToken(uint256 id_) external virtual onlyOwner {
        if (id_ == 0 || id_ > tokenIndex || frozen[id_]) revert InvalidTokenId(id_);
        frozen[id_] = true;
        tokenMaxSupply[id_] = tokenSupply[id_];
        userTokenSupply[id_] = 0;

        emit PermanentTokenSupply(id_);
    }
}
