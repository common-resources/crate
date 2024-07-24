# Report


## Gas Optimizations


| |Issue|Instances|
|-|:-|:-:|
| [GAS-1](#GAS-1) | Use ERC721A instead ERC721 | 1 |
| [GAS-2](#GAS-2) | `a = a + b` is more gas effective than `a += b` for state variables (excluding arrays and mappings) | 7 |
| [GAS-3](#GAS-3) | Using bools for storage incurs overhead | 2 |
| [GAS-4](#GAS-4) | Cache array length outside of loop | 2 |
| [GAS-5](#GAS-5) | For Operations that will not overflow, you could use unchecked | 75 |
| [GAS-6](#GAS-6) | Avoid contract existence checks by using low level calls | 3 |
| [GAS-7](#GAS-7) | Functions guaranteed to revert when called by normal users can be marked `payable` | 23 |
| [GAS-8](#GAS-8) | `++i` costs less gas compared to `i++` or `i += 1` (same for `--i` vs `i--` or `i -= 1`) | 1 |
| [GAS-9](#GAS-9) | `uint256` to `bool` `mapping`: Utilizing Bitmaps to dramatically save on Gas | 1 |
| [GAS-10](#GAS-10) | Increments/decrements can be unchecked in for-loops | 1 |
| [GAS-11](#GAS-11) | Use != 0 instead of > 0 for unsigned integer comparison | 4 |
### <a name="GAS-1"></a>[GAS-1] Use ERC721A instead ERC721
ERC721A standard, ERC721A is an improvement standard for ERC721 tokens. It was proposed by the Azuki team and used for developing their NFT collection. Compared with ERC721, ERC721A is a more gas-efficient standard to mint a lot of of NFTs simultaneously. It allows developers to mint multiple NFTs at the same gas price. This has been a great improvement due to Ethereum's sky-rocketing gas fee.

    Reference: https://nextrope.com/erc721-vs-erc721a-2/

*Instances (1)*:
```solidity
File: Core.sol

16: import {IERC721} from "@openzeppelin/contracts/interfaces/IERC721.sol";

```

### <a name="GAS-2"></a>[GAS-2] `a = a + b` is more gas effective than `a += b` for state variables (excluding arrays and mappings)
This saves **16 gas per instance.**

*Instances (7)*:
```solidity
File: ERC721Core.sol

155:             _claimed[msg.sender] += tokenAmount;

182:             _totalSupply += amount_;

```

```solidity
File: extensions/blacklist/BlacklistExt.sol

60:                 count += IAsset(blacklist[i]).balanceOf(msg.sender);

61:                 count += IAsset(blacklist[i]).balanceOf(recipient_);

```

```solidity
File: extensions/lists/MintlistExt.sol

98:                     _reservedSupply += listMaxSupply_ - currentListMaxSupply_;

198:             _claimedList[listId_][msg.sender] += _amount_;

201:             listSupply[listId_] += _amount_;

```

### <a name="GAS-3"></a>[GAS-3] Using bools for storage incurs overhead
Use uint256(1) and uint256(2) for true/false to avoid a Gwarmaccess (100 gas), and to avoid Gsset (20000 gas) when changing from ‘false’ to ‘true’, after having been ‘true’ in the past. See [source](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/58f635312aa21f947cae5f8578638a85aa2519f5/contracts/security/ReentrancyGuard.sol#L23-L27).

*Instances (2)*:
```solidity
File: metadata/CoreMetadata.sol

53:     bool public permanentURI;

56:     mapping(uint256 tokenId_ => bool isPermanent) internal _permanentTokenURIs;

```

### <a name="GAS-4"></a>[GAS-4] Cache array length outside of loop
If not cached, the solidity compiler will always read the length of the array during each iteration. That is, if it is a storage array, this is an extra sload operation (100 additional extra gas for each iteration except for the first) and if it is a memory array, this is an extra mload operation (3 additional gas for each iteration except for the first).

*Instances (2)*:
```solidity
File: extensions/blacklist/BlacklistExt.sol

43:         for (uint256 i; i < assets_.length; ++i) {

58:         for (uint256 i = 1; i < blacklist.length;) {

```

### <a name="GAS-5"></a>[GAS-5] For Operations that will not overflow, you could use unchecked

*Instances (75)*:
```solidity
File: Core.sol

9: import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";

10: import {Ownable} from "solady/src/auth/Ownable.sol";

11: import {ReentrancyGuard} from "solady/src/utils/ReentrancyGuard.sol";

13: import {ICore, NotZero, TransferFailed} from "./ICore.sol";

15: import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

16: import {IERC721} from "@openzeppelin/contracts/interfaces/IERC721.sol";

52:         if (msg.value < (price * amount_)) revert InsufficientPayment();

54:         uint256 tokenAmount = amount_ * unit;

56:         if (_totalSupply + tokenAmount > maxSupply) revert MaxSupply();

57:         if (_claimed[msg.sender] + tokenAmount > userSupply) revert ClaimSupply();

92:         if (start == 0 && start != start_) _unpause(); // Open minting if it wasn't already

```

```solidity
File: ERC721Core.sol

11: import {Core} from "./Core.sol";

12: import {BlacklistExt} from "./extensions/blacklist/BlacklistExt.sol";

13: import {MintList, MintlistExt} from "./extensions/lists/MintlistExt.sol";

14: import {LockableExt} from "./extensions/lockable/LockableExt.sol";

16: import {ReferralExt} from "./extensions/referral/ReferralExt.sol";

17: import {RoyaltyExt} from "./extensions/royalty/RoyaltyExt.sol";

18: import {CoreMetadata721, ICoreMetadata} from "./metadata/CoreMetadata721.sol";

20: import {NotZero} from "./ICore.sol";

22: import {Initializable} from "solady/src/utils/Initializable.sol";

24: import {FixedPointMathLib as FPML} from "solady/src/utils/FixedPointMathLib.sol";

85:         string memory name_, // Collection name ("Milady")

86:         string memory symbol_, // Collection symbol ("MIL")

87:         uint32 maxSupply_, // Max supply (~1.099T max)

88:         uint16 royalty_, // Percentage in basis points (420 == 4.20%)

89:         address owner_, // Collection contract owner

90:         uint256 price_ // Price (~1.2M ETH max)

155:             _claimed[msg.sender] += tokenAmount;

179:                 super._mint(recipient_, ++supply);

180:                 ++i;

182:             _totalSupply += amount_;

209:         if (_totalSupply + tokenAmount > maxSupply) revert MaxSupply();

285:         if (maxSupply_ < _totalSupply + _reservedSupply) revert UnderSupply();

377:             mint(msg.sender, (msg.value / price));

```

```solidity
File: extensions/blacklist/BlacklistExt.sol

13: import {IAsset} from "../blacklist/IAsset.sol";

14: import {IBlacklistExt} from "../blacklist/IBlacklistExt.sol";

16: import {EnumerableSetLib} from "solady/src/utils/EnumerableSetLib.sol";

43:         for (uint256 i; i < assets_.length; ++i) {

60:                 count += IAsset(blacklist[i]).balanceOf(msg.sender);

61:                 count += IAsset(blacklist[i]).balanceOf(recipient_);

63:                 ++i;

```

```solidity
File: extensions/lists/MintlistExt.sol

9: import {NotZero} from "../../ICore.sol";

10: import {IMintlistExt, MintList} from "./IMintlistExt.sol";

12: import {MerkleProofLib} from "solady/src/utils/MerkleProofLib.sol";

98:                     _reservedSupply += listMaxSupply_ - currentListMaxSupply_;

101:                     _reservedSupply -= currentListMaxSupply_ - listMaxSupply_;

105:                 _reservedSupply -= currentListMaxSupply_ - alreadyMinted;

127:         uint8 id = listId_ == 0 ? listIndex++ : listId_; // If listId_ is 0, increment listCount and create new list

176:         if (amount_ > maxSupply_ - totalSupply_ - _reservedSupply) revert ReservedSupply();

194:         _amount_ = amount_ * list.unit;

198:             _claimedList[listId_][msg.sender] += _amount_;

201:             listSupply[listId_] += _amount_;

210:         cost_ = list.price * amount_;

```

```solidity
File: extensions/lockable/ILockableExt.sol

9: import {IERC721Lockable} from "erc721-lockable/contracts/IERC721Lockable.sol";

```

```solidity
File: extensions/lockable/LockableExt.sol

9: import {ILockableExt} from "./ILockableExt.sol";

```

```solidity
File: extensions/referral/ReferralExt.sol

9: import {TransferFailed} from "../../ICore.sol";

10: import {IReferralExt} from "./IReferralExt.sol";

12: import {FixedPointMathLib as FPML} from "solady/src/utils/FixedPointMathLib.sol";

```

```solidity
File: extensions/royalty/IRoyaltyExt.sol

9: import {IERC165} from "@openzeppelin/contracts/interfaces/IERC165.sol";

```

```solidity
File: extensions/royalty/RoyaltyExt.sol

9: import {NotZero} from "../../ICore.sol";

10: import {IERC165, IRoyaltyExt} from "./IRoyaltyExt.sol";

12: import {ERC2981} from "solady/src/tokens/ERC2981.sol";

```

```solidity
File: metadata/CoreMetadata.sol

9: import {ICoreMetadata} from "./ICoreMetadata.sol";

11: import {LibString} from "solady/src/utils/LibString.sol";

14:     using LibString for uint256; // Used to convert uint256 tokenId to string for tokenURI()

```

```solidity
File: metadata/CoreMetadata1155.sol

9: import {CoreMetadata} from "./CoreMetadata.sol";

11: import {ICoreMetadata1155} from "./ICoreMetadata1155.sol";

13: import {ERC1155} from "solady/src/tokens/ERC1155.sol";

```

```solidity
File: metadata/CoreMetadata721.sol

10: import {CoreMetadata, ICoreMetadata} from "./CoreMetadata.sol";

12: import {ICoreMetadata721} from "./ICoreMetadata721.sol";

14: import {ERC721} from "solady/src/tokens/ERC721.sol";

16: import {IERC165} from "@openzeppelin/contracts/interfaces/IERC165.sol";

17: import {IERC4906} from "@openzeppelin/contracts/interfaces/IERC4906.sol";

57:         return interfaceId_ == 0x5b5e139f // ERC721Metadata

58:             || interfaceId_ == 0x49064906 // IERC4906

```

### <a name="GAS-6"></a>[GAS-6] Avoid contract existence checks by using low level calls
Prior to 0.8.10 the compiler inserted extra code, including `EXTCODESIZE` (**100 gas**), to check for contract existence for external function calls. In more recent solidity versions, the compiler will not insert these checks if the external call has a return value. Similar behavior can be achieved in earlier versions by using low-level calls, since low level calls never check for contract existence

*Instances (3)*:
```solidity
File: Core.sol

169:         uint256 balance = IERC20(token_).balanceOf(address(this));

```

```solidity
File: extensions/blacklist/BlacklistExt.sol

60:                 count += IAsset(blacklist[i]).balanceOf(msg.sender);

61:                 count += IAsset(blacklist[i]).balanceOf(recipient_);

```

### <a name="GAS-7"></a>[GAS-7] Functions guaranteed to revert when called by normal users can be marked `payable`
If a function modifier such as `onlyOwner` is used, the function will revert if a normal user tries to pay the function. Marking the function as `payable` will lower the gas cost for legitimate callers because the compiler will not include checks for whether a payment was provided.

*Instances (23)*:
```solidity
File: Core.sol

73:     function pause() external onlyOwner {

77:     function unpause() external onlyOwner {

85:     function setPrice(uint256 price_) external virtual onlyOwner {

90:     function setMintPeriod(uint32 start_, uint32 end_) external onlyOwner {

99:     function setClaimableUserSupply(uint32 claimable_) external virtual onlyOwner {

105:     function setUnit(uint24 unit_) external virtual onlyOwner {

117:     function setSupply(uint32 maxSupply_) external virtual onlyOwner {

168:     function rescueERC20(address token_, address recipient_) public virtual onlyOwner {

183:     function rescueERC721(address token_, address recipient_, uint256 tokenId_) public virtual onlyOwner {

```

```solidity
File: ERC721Core.sol

284:     function setSupply(uint32 maxSupply_) external virtual override onlyOwner {

291:     function setContractURI(string memory contractURI_) external virtual onlyOwner {

295:     function setBaseURI(string memory baseURI_, string memory fileExtension_) external virtual onlyOwner {

299:     function setTokenURI(uint256 tokenId_, string memory tokenURI_) external virtual onlyOwner {

303:     function freezeURI() external virtual onlyOwner {

307:     function freezeTokenURI(uint256 tokenId_) external virtual onlyOwner {

332:     function pauseList(uint8 listId_) external virtual onlyOwner {

336:     function unpauseList(uint8 listId_) external virtual onlyOwner {

340:     function deleteList(uint8 listId_) external virtual onlyOwner {

346:     function setRoyalties(address recipient_, uint96 bps_) external virtual onlyOwner {

351:     function setTokenRoyalties(uint256 tokenId_, address recipient_, uint96 bps_) external virtual onlyOwner {

356:     function disableRoyalties() external virtual onlyOwner {

362:     function setBlacklist(address[] calldata assets_, bool status_) external virtual onlyOwner {

368:     function setReferralFee(uint16 bps_) external virtual onlyOwner {

```

### <a name="GAS-8"></a>[GAS-8] `++i` costs less gas compared to `i++` or `i += 1` (same for `--i` vs `i--` or `i -= 1`)
Pre-increments and pre-decrements are cheaper.

For a `uint256 i` variable, the following is true with the Optimizer enabled at 10k:

**Increment:**

- `i += 1` is the most expensive form
- `i++` costs 6 gas less than `i += 1`
- `++i` costs 5 gas less than `i++` (11 gas less than `i += 1`)

**Decrement:**

- `i -= 1` is the most expensive form
- `i--` costs 11 gas less than `i -= 1`
- `--i` costs 5 gas less than `i--` (16 gas less than `i -= 1`)

Note that post-increments (or post-decrements) return the old value before incrementing or decrementing, hence the name *post-increment*:

```solidity
uint i = 1;  
uint j = 2;
require(j == i++, "This will be false as i is incremented after the comparison");
```
  
However, pre-increments (or pre-decrements) return the new value:
  
```solidity
uint i = 1;  
uint j = 2;
require(j == ++i, "This will be true as i is incremented before the comparison");
```

In the pre-increment case, the compiler has to create a temporary variable (when used) for returning `1` instead of `2`.

Consider using pre-increments and pre-decrements where they are relevant (meaning: not where post-increments/decrements logic are relevant).

*Saves 5 gas per instance*

*Instances (1)*:
```solidity
File: extensions/lists/MintlistExt.sol

127:         uint8 id = listId_ == 0 ? listIndex++ : listId_; // If listId_ is 0, increment listCount and create new list

```

### <a name="GAS-9"></a>[GAS-9] `uint256` to `bool` `mapping`: Utilizing Bitmaps to dramatically save on Gas
https://soliditydeveloper.com/bitmaps

https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/structs/BitMaps.sol

- [BitMaps.sol#L5-L16](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/structs/BitMaps.sol#L5-L16):

```solidity
/**
 * @dev Library for managing uint256 to bool mapping in a compact and efficient way, provided the keys are sequential.
 * Largely inspired by Uniswap's https://github.com/Uniswap/merkle-distributor/blob/master/contracts/MerkleDistributor.sol[merkle-distributor].
 *
 * BitMaps pack 256 booleans across each bit of a single 256-bit slot of `uint256` type.
 * Hence booleans corresponding to 256 _sequential_ indices would only consume a single slot,
 * unlike the regular `bool` which would consume an entire slot for a single value.
 *
 * This results in gas savings in two ways:
 *
 * - Setting a zero value to non-zero only once every 256 times
 * - Accessing the same warm slot for every 256 _sequential_ indices
 */
```

*Instances (1)*:
```solidity
File: metadata/CoreMetadata.sol

56:     mapping(uint256 tokenId_ => bool isPermanent) internal _permanentTokenURIs;

```

### <a name="GAS-10"></a>[GAS-10] Increments/decrements can be unchecked in for-loops
In Solidity 0.8+, there's a default overflow check on unsigned integers. It's possible to uncheck this in for-loops and save some gas at each iteration, but at the cost of some code readability, as this uncheck cannot be made inline.

[ethereum/solidity#10695](https://github.com/ethereum/solidity/issues/10695)

The change would be:

```diff
- for (uint256 i; i < numIterations; i++) {
+ for (uint256 i; i < numIterations;) {
 // ...  
+   unchecked { ++i; }
}  
```

These save around **25 gas saved** per instance.

The same can be applied with decrements (which should use `break` when `i == 0`).

The risk of overflow is non-existent for `uint256`.

*Instances (1)*:
```solidity
File: extensions/blacklist/BlacklistExt.sol

43:         for (uint256 i; i < assets_.length; ++i) {

```

### <a name="GAS-11"></a>[GAS-11] Use != 0 instead of > 0 for unsigned integer comparison

*Instances (4)*:
```solidity
File: extensions/blacklist/BlacklistExt.sol

62:                 if (count > 0) revert Blacklisted();

```

```solidity
File: extensions/referral/ReferralExt.sol

25:         if (msg.value > 0 && referral_ != address(0)) {

```

```solidity
File: metadata/CoreMetadata.sol

76:         if (bytes(tokenURI).length > 0) {

82:         return bytes(newBaseURI).length > 0

```


## Non Critical Issues


| |Issue|Instances|
|-|:-|:-:|
| [NC-1](#NC-1) | Use `string.concat()` or `bytes.concat()` instead of `abi.encodePacked` | 1 |
| [NC-2](#NC-2) | Control structures do not follow the Solidity Style Guide | 52 |
| [NC-3](#NC-3) | Consider disabling `renounceOwnership()` | 1 |
| [NC-4](#NC-4) | Functions should not be longer than 50 lines | 81 |
| [NC-5](#NC-5) | Use a `modifier` instead of a `require/if` statement for a special `msg.sender` actor | 6 |
| [NC-6](#NC-6) | Owner can renounce while system is paused | 4 |
| [NC-7](#NC-7) | Take advantage of Custom Error's return value property | 47 |
| [NC-8](#NC-8) | Avoid the use of sensitive terms | 26 |
| [NC-9](#NC-9) | Use Underscores for Number Literals (add an underscore every 3 digits) | 1 |
| [NC-10](#NC-10) | Constants should be defined rather than using magic numbers | 1 |
### <a name="NC-1"></a>[NC-1] Use `string.concat()` or `bytes.concat()` instead of `abi.encodePacked`
Solidity version 0.8.4 introduces `bytes.concat()` (vs `abi.encodePacked(<bytes>,<bytes>)`)

Solidity version 0.8.12 introduces `string.concat()` (vs `abi.encodePacked(<str>,<str>), which catches concatenation errors (in the event of a `bytes` data mixed in the concatenation)`)

*Instances (1)*:
```solidity
File: metadata/CoreMetadata.sol

83:             ? string(abi.encodePacked(newBaseURI, tokenId_.toString(), _fileExtension))

```

### <a name="NC-2"></a>[NC-2] Control structures do not follow the Solidity Style Guide
See the [control structures](https://docs.soliditylang.org/en/latest/style-guide.html#control-structures) section of the Solidity Style Guide

*Instances (52)*:
```solidity
File: Core.sol

52:         if (msg.value < (price * amount_)) revert InsufficientPayment();

56:         if (_totalSupply + tokenAmount > maxSupply) revert MaxSupply();

57:         if (_claimed[msg.sender] + tokenAmount > userSupply) revert ClaimSupply();

59:         if ((start != 0 && block.timestamp < start) || (end != 0 && block.timestamp > end)) revert TimeOutOfBounds();

91:         if (end_ != 0 && start_ > end_) revert TimestampEnd();

92:         if (start == 0 && start != start_) _unpause(); // Open minting if it wasn't already

100:         if (claimable_ == 0) revert NotZero();

106:         if (unit_ == 0) revert NotZero();

118:         if (maxSupply_ < _totalSupply) revert UnderSupply();

123:         if (maxSupply_ > maxSupply && _totalSupply != 0) revert MaxSupply();

130:         if (recipient_ == address(0)) revert NotZero();

137:         if (!forfeit && contractOwner != msg.sender) revert Unauthorized();

141:         if (amount_ > balance || forfeit) amount_ = balance;

145:         if (!success) revert TransferFailed();

189:         if (msg.sender == address(0) || msg.value == 0) revert NotZero();

191:         if (!success) revert TransferFailed();

```

```solidity
File: ERC721Core.sol

126:         if (_exists(tokenId_)) return _tokenURI(tokenId_);

171:         if (recipient_ == address(0) || amount_ == 0) revert NotZero();

207:         if (msg.value < cost) revert InsufficientPayment();

209:         if (_totalSupply + tokenAmount > maxSupply) revert MaxSupply();

211:         if (!reserved) _requireUnreservedSupply(tokenAmount, _totalSupply, maxSupply);

285:         if (maxSupply_ < _totalSupply + _reservedSupply) revert UnderSupply();

```

```solidity
File: extensions/blacklist/BlacklistExt.sol

44:             if (status_) _blacklist.add(assets_[i]);

62:                 if (count > 0) revert Blacklisted();

```

```solidity
File: extensions/lists/MintlistExt.sol

41:         if (listId_ > listIndex) revert ListUnknown();

43:         if (maxSupply_ == 0 || userSupply_ == 0 || unit_ == 0) revert NotZero();

45:         if (maxSupply_ < listSupply[listId_]) revert SupplyUnderflow();

47:         if (end_ != 0 && start_ < end_) revert ListTimestampEnd();

99:                     if (_reservedSupply > maxSupply_) revert ReservedMaxSupply();

127:         uint8 id = listId_ == 0 ? listIndex++ : listId_; // If listId_ is 0, increment listCount and create new list

130:         if (listId_ != 0 && list.userSupply == 0) revert ListDeleted();

151:         if (list.userSupply == 0) revert ListDeleted();

162:         if (list.userSupply == 0) revert ListDeleted();

172:         if (listId_ == 0 || listId_ > listIndex) revert ListUnknown();

176:         if (amount_ > maxSupply_ - totalSupply_ - _reservedSupply) revert ReservedSupply();

188:         if (list.paused) revert ListPaused();

192:         if (!MerkleProofLib.verifyCalldata(proof_, list.root, leaf)) revert NotEligible();

199:             if (_claimedList[listId_][msg.sender] > list.userSupply) revert ListClaimSupply();

202:             if (listSupply[listId_] > list.maxSupply) revert ListMaxSupply();

```

```solidity
File: extensions/lockable/LockableExt.sol

15:         if (locked[id_] != address(0)) revert AlreadyLocked();

20:         if (locked[id_] != msg.sender) revert NotLocker();

```

```solidity
File: extensions/referral/ReferralExt.sol

26:             if (referral_ == msg.sender || referral_ == recipient_) revert SelfReferral();

36:             if (!success) revert TransferFailed();

43:         if (bps_ > _DENOMINATOR_BPS) revert MaxReferral();

```

```solidity
File: extensions/royalty/RoyaltyExt.sol

22:         if (receiver == address(0)) revert DisabledRoyalties();

26:         if (bps_ > _MAX_ROYALTY_BPS) revert MaxRoyalties();

36:         if (bps_ > _MAX_ROYALTY_BPS) revert MaxRoyalties();

39:         if (tokenId_ == 0) revert NotZero();

42:         if (bps_ == 0) _resetTokenRoyalty(tokenId_);

```

```solidity
File: metadata/CoreMetadata.sol

103:         if (permanentURI) revert URIPermanent();

111:         if (permanentURI || _permanentTokenURIs[tokenId_]) revert URIPermanent();

132:         if (permanentURI) revert URIPermanent();

```

### <a name="NC-3"></a>[NC-3] Consider disabling `renounceOwnership()`
If the plan for your project does not include eventually giving up all ownership control, consider overwriting OpenZeppelin's `Ownable`'s `renounceOwnership()` function in order to disable it.

*Instances (1)*:
```solidity
File: Core.sol

18: abstract contract Core is ICore, Ownable, Pausable, ReentrancyGuard {

```

### <a name="NC-4"></a>[NC-4] Functions should not be longer than 50 lines
Overly complex code can make understanding functionality more difficult, try to further modularize your code to ensure readability 

*Instances (81)*:
```solidity
File: Core.sol

49:     function _canMint(uint256 amount_) internal view virtual returns (uint32 tokenAmount_) {

65:     function totalSupply() external view returns (uint256) {

69:     function claimedOf(address wallet_) external view returns (uint256) {

85:     function setPrice(uint256 price_) external virtual onlyOwner {

90:     function setMintPeriod(uint32 start_, uint32 end_) external onlyOwner {

99:     function setClaimableUserSupply(uint32 claimable_) external virtual onlyOwner {

105:     function setUnit(uint24 unit_) external virtual onlyOwner {

117:     function setSupply(uint32 maxSupply_) external virtual onlyOwner {

122:     function _setMaxSupply(uint32 maxSupply_) internal {

129:     function _withdraw(address recipient_, uint256 amount_) internal virtual {

155:     function withdraw(address recipient_, uint256 amount_) public virtual nonReentrant {

159:     function _sendERC20(address token_, address recipient_, uint256 amount_) internal virtual {

168:     function rescueERC20(address token_, address recipient_) public virtual onlyOwner {

173:     function _sendERC721(address token_, address recipient_, uint256 tokenId_) internal virtual {

183:     function rescueERC721(address token_, address recipient_, uint256 tokenId_) public virtual onlyOwner {

```

```solidity
File: ERC721Core.sol

36:     function _canMint(uint256 amount_) internal view override returns (uint32 tokenAmount_) {

149:     function _handleMint(address recipient_, uint256 amount_, address referral_) internal virtual {

168:     function _mintBatch(address recipient_, uint32 amount_) internal virtual {

230:     function mint(uint256 amount_) public payable virtual {

240:     function mint(address recipient_, uint256 amount_) public payable virtual {

252:     function mint(address recipient_, uint256 amount_, address referral_) public payable virtual nonReentrant {

284:     function setSupply(uint32 maxSupply_) external virtual override onlyOwner {

291:     function setContractURI(string memory contractURI_) external virtual onlyOwner {

295:     function setBaseURI(string memory baseURI_, string memory fileExtension_) external virtual onlyOwner {

299:     function setTokenURI(uint256 tokenId_, string memory tokenURI_) external virtual onlyOwner {

307:     function freezeTokenURI(uint256 tokenId_) external virtual onlyOwner {

332:     function pauseList(uint8 listId_) external virtual onlyOwner {

336:     function unpauseList(uint8 listId_) external virtual onlyOwner {

340:     function deleteList(uint8 listId_) external virtual onlyOwner {

346:     function setRoyalties(address recipient_, uint96 bps_) external virtual onlyOwner {

351:     function setTokenRoyalties(uint256 tokenId_, address recipient_, uint96 bps_) external virtual onlyOwner {

356:     function disableRoyalties() external virtual onlyOwner {

362:     function setBlacklist(address[] calldata assets_, bool status_) external virtual onlyOwner {

368:     function setReferralFee(uint16 bps_) external virtual onlyOwner {

375:     function _processPayment() internal virtual override {

```

```solidity
File: extensions/blacklist/BlacklistExt.sol

31:     function getBlacklist() external view virtual returns (address[] memory blacklist_) {

42:     function _setBlacklist(address[] calldata assets_, bool status_) internal virtual {

55:     function _enforceBlacklist(address recipient_) internal virtual {

```

```solidity
File: extensions/blacklist/IAsset.sol

10:     function balanceOf(address holder) external returns (uint256);

```

```solidity
File: extensions/blacklist/IBlacklistExt.sol

24:     function getBlacklist() external view returns (address[] memory blacklist_);

31:     function setBlacklist(address[] calldata assets_, bool status_) external;

```

```solidity
File: extensions/lists/IMintlistExt.sol

95:     function listIndex() external view returns (uint8);

112:     function listClaimedOf(uint8 listId_, address wallet_) external view returns (uint256 claimed_);

114:     function listSupply(uint8 listId_) external view returns (uint32);

```

```solidity
File: extensions/lists/MintlistExt.sol

80:     function listClaimedOf(uint8 listId_, address wallet_) external view returns (uint256) {

146:     function _pauseList(uint8 listId_, bool paused_) internal virtual {

157:     function _deleteList(uint8 listId_) internal virtual {

171:     function _requireListExists(uint8 listId_) internal view {

175:     function _requireUnreservedSupply(uint256 amount_, uint32 totalSupply_, uint32 maxSupply_) internal view {

```

```solidity
File: extensions/lockable/ILockableExt.sol

16:     function transferFrom(address from_, address to_, uint256 tokenId_) external;

18:     function safeTransferFrom(address from_, address to_, uint256 tokenId_) external;

```

```solidity
File: extensions/referral/ReferralExt.sol

24:     function _handleReferral(address referral_, address recipient_) internal virtual {

42:     function _setReferralFee(uint16 bps_) internal virtual {

```

```solidity
File: extensions/royalty/IRoyaltyExt.sol

37:     function setRoyalties(address recipient_, uint96 bps_) external;

45:     function setTokenRoyalties(uint256 tokenId_, address recipient_, uint96 bps_) external;

```

```solidity
File: extensions/royalty/RoyaltyExt.sol

19:     function _requireRoyaltiesEnabled() internal view {

25:     function _setRoyalties(address recipient_, uint96 bps_) internal virtual {

35:     function _setTokenRoyalties(uint256 tokenId_, address recipient_, uint96 bps_) internal virtual {

57:     function supportsInterface(bytes4 interfaceId_) public view virtual override(ERC2981, IERC165) returns (bool) {

```

```solidity
File: metadata/CoreMetadata.sol

62:     function contractURI() external view virtual returns (string memory contractURI_) {

69:     function baseURI() external view virtual returns (string memory) {

73:     function _tokenURI(uint256 tokenId_) internal view virtual returns (string memory) {

92:     function _setContractURI(string memory contractURI_) internal virtual {

102:     function _setBaseURI(string memory baseURI_, string memory fileExtension_) internal virtual {

110:     function _setTokenURI(uint256 tokenId_, string memory tokenURI_) internal virtual {

121:     function _freezeURI(uint256 maxSupply_) internal virtual {

131:     function _freezeTokenURI(uint256 tokenId_) internal virtual {

```

```solidity
File: metadata/CoreMetadata1155.sol

16:     function uri(uint256 tokenId_) public view virtual returns (string memory tokenURI_) {

```

```solidity
File: metadata/CoreMetadata721.sol

20:     function name() public view virtual override returns (string memory name_) {

24:     function symbol() public view virtual override returns (string memory symbol_) {

44:     function _setTokenURI(uint256 tokenId_, string memory tokenURI_) internal virtual override {

50:     function _setBaseURI(string memory baseURI_, string memory fileExtension_, uint256 maxSupply_) internal virtual {

56:     function supportsInterface(bytes4 interfaceId_) public view virtual override returns (bool) {

```

```solidity
File: metadata/ICoreMetadata.sol

51:     function contractURI() external view returns (string memory contractURI_);

57:     function baseURI() external view returns (string memory);

64:     function setContractURI(string memory contractURI_) external;

71:     function setBaseURI(string memory baseURI_, string memory fileExtension_) external;

83:     function freezeTokenURI(uint256 tokenId_) external;

```

```solidity
File: metadata/ICoreMetadata1155.sol

15:     function setURI(uint256 tokenId_, string calldata tokenURI_) external;

```

```solidity
File: metadata/ICoreMetadata721.sol

25:     function setTokenURI(uint256 tokenId_, string memory tokenURI_) external;

34:     function tokenURI(uint256 tokenId_) external view returns (string memory tokenURI_);

```

### <a name="NC-5"></a>[NC-5] Use a `modifier` instead of a `require/if` statement for a special `msg.sender` actor
If a function is supposed to be access-controlled, a `modifier` should be used instead of a `require/if` statement for more readability.

*Instances (6)*:
```solidity
File: Core.sol

57:         if (_claimed[msg.sender] + tokenAmount > userSupply) revert ClaimSupply();

137:         if (!forfeit && contractOwner != msg.sender) revert Unauthorized();

189:         if (msg.sender == address(0) || msg.value == 0) revert NotZero();

```

```solidity
File: extensions/lists/MintlistExt.sol

199:             if (_claimedList[listId_][msg.sender] > list.userSupply) revert ListClaimSupply();

```

```solidity
File: extensions/lockable/LockableExt.sol

20:         if (locked[id_] != msg.sender) revert NotLocker();

```

```solidity
File: extensions/referral/ReferralExt.sol

26:             if (referral_ == msg.sender || referral_ == recipient_) revert SelfReferral();

```

### <a name="NC-6"></a>[NC-6] Owner can renounce while system is paused
The contract owner or single user with a role is not prevented from renouncing the role/ownership while the contract is paused, which would cause any user assets stored in the protocol, to be locked indefinitely.

*Instances (4)*:
```solidity
File: Core.sol

73:     function pause() external onlyOwner {

77:     function unpause() external onlyOwner {

```

```solidity
File: ERC721Core.sol

332:     function pauseList(uint8 listId_) external virtual onlyOwner {

336:     function unpauseList(uint8 listId_) external virtual onlyOwner {

```

### <a name="NC-7"></a>[NC-7] Take advantage of Custom Error's return value property
An important feature of Custom Error is that values such as address, tokenID, msg.value can be written inside the () sign, this kind of approach provides a serious advantage in debugging and examining the revert details of dapps such as tenderly.

*Instances (47)*:
```solidity
File: Core.sol

52:         if (msg.value < (price * amount_)) revert InsufficientPayment();

56:         if (_totalSupply + tokenAmount > maxSupply) revert MaxSupply();

57:         if (_claimed[msg.sender] + tokenAmount > userSupply) revert ClaimSupply();

59:         if ((start != 0 && block.timestamp < start) || (end != 0 && block.timestamp > end)) revert TimeOutOfBounds();

91:         if (end_ != 0 && start_ > end_) revert TimestampEnd();

100:         if (claimable_ == 0) revert NotZero();

106:         if (unit_ == 0) revert NotZero();

118:         if (maxSupply_ < _totalSupply) revert UnderSupply();

123:         if (maxSupply_ > maxSupply && _totalSupply != 0) revert MaxSupply();

130:         if (recipient_ == address(0)) revert NotZero();

137:         if (!forfeit && contractOwner != msg.sender) revert Unauthorized();

145:         if (!success) revert TransferFailed();

189:         if (msg.sender == address(0) || msg.value == 0) revert NotZero();

191:         if (!success) revert TransferFailed();

```

```solidity
File: ERC721Core.sol

127:         revert TokenDoesNotExist();

171:         if (recipient_ == address(0) || amount_ == 0) revert NotZero();

207:         if (msg.value < cost) revert InsufficientPayment();

209:         if (_totalSupply + tokenAmount > maxSupply) revert MaxSupply();

285:         if (maxSupply_ < _totalSupply + _reservedSupply) revert UnderSupply();

```

```solidity
File: extensions/blacklist/BlacklistExt.sol

62:                 if (count > 0) revert Blacklisted();

```

```solidity
File: extensions/lists/MintlistExt.sol

41:         if (listId_ > listIndex) revert ListUnknown();

43:         if (maxSupply_ == 0 || userSupply_ == 0 || unit_ == 0) revert NotZero();

45:         if (maxSupply_ < listSupply[listId_]) revert SupplyUnderflow();

47:         if (end_ != 0 && start_ < end_) revert ListTimestampEnd();

99:                     if (_reservedSupply > maxSupply_) revert ReservedMaxSupply();

130:         if (listId_ != 0 && list.userSupply == 0) revert ListDeleted();

151:         if (list.userSupply == 0) revert ListDeleted();

162:         if (list.userSupply == 0) revert ListDeleted();

172:         if (listId_ == 0 || listId_ > listIndex) revert ListUnknown();

176:         if (amount_ > maxSupply_ - totalSupply_ - _reservedSupply) revert ReservedSupply();

188:         if (list.paused) revert ListPaused();

192:         if (!MerkleProofLib.verifyCalldata(proof_, list.root, leaf)) revert NotEligible();

199:             if (_claimedList[listId_][msg.sender] > list.userSupply) revert ListClaimSupply();

202:             if (listSupply[listId_] > list.maxSupply) revert ListMaxSupply();

206:             revert ListTimeOutOfBounds();

```

```solidity
File: extensions/lockable/LockableExt.sol

15:         if (locked[id_] != address(0)) revert AlreadyLocked();

20:         if (locked[id_] != msg.sender) revert NotLocker();

```

```solidity
File: extensions/referral/ReferralExt.sol

26:             if (referral_ == msg.sender || referral_ == recipient_) revert SelfReferral();

36:             if (!success) revert TransferFailed();

43:         if (bps_ > _DENOMINATOR_BPS) revert MaxReferral();

```

```solidity
File: extensions/royalty/RoyaltyExt.sol

22:         if (receiver == address(0)) revert DisabledRoyalties();

26:         if (bps_ > _MAX_ROYALTY_BPS) revert MaxRoyalties();

36:         if (bps_ > _MAX_ROYALTY_BPS) revert MaxRoyalties();

39:         if (tokenId_ == 0) revert NotZero();

```

```solidity
File: metadata/CoreMetadata.sol

103:         if (permanentURI) revert URIPermanent();

111:         if (permanentURI || _permanentTokenURIs[tokenId_]) revert URIPermanent();

132:         if (permanentURI) revert URIPermanent();

```

### <a name="NC-8"></a>[NC-8] Avoid the use of sensitive terms
Use [alternative variants](https://www.zdnet.com/article/mysql-drops-master-slave-and-blacklist-whitelist-terminology/), e.g. allowlist/denylist instead of whitelist/blacklist

*Instances (26)*:
```solidity
File: ERC721Core.sol

12: import {BlacklistExt} from "./extensions/blacklist/BlacklistExt.sol";

35: contract ERC721Core is Core, BlacklistExt, MintlistExt, CoreMetadata721, ReferralExt, RoyaltyExt, Initializable {

174:         _enforceBlacklist(recipient_);

362:     function setBlacklist(address[] calldata assets_, bool status_) external virtual onlyOwner {

363:         _setBlacklist(assets_, status_);

```

```solidity
File: extensions/blacklist/BlacklistExt.sol

13: import {IAsset} from "../blacklist/IAsset.sol";

14: import {IBlacklistExt} from "../blacklist/IBlacklistExt.sol";

24: abstract contract BlacklistExt is IBlacklistExt {

28:     EnumerableSetLib.AddressSet internal _blacklist;

31:     function getBlacklist() external view virtual returns (address[] memory blacklist_) {

32:         return _blacklist.values();

42:     function _setBlacklist(address[] calldata assets_, bool status_) internal virtual {

44:             if (status_) _blacklist.add(assets_[i]);

45:             else _blacklist.remove(assets_[i]);

47:         emit BlacklistUpdate(assets_, status_);

55:     function _enforceBlacklist(address recipient_) internal virtual {

56:         address[] memory blacklist = _blacklist.values();

58:         for (uint256 i = 1; i < blacklist.length;) {

60:                 count += IAsset(blacklist[i]).balanceOf(msg.sender);

61:                 count += IAsset(blacklist[i]).balanceOf(recipient_);

62:                 if (count > 0) revert Blacklisted();

```

```solidity
File: extensions/blacklist/IBlacklistExt.sol

9: interface IBlacklistExt {

15:     event BlacklistUpdate(address[] indexed blacklistedAssets, bool indexed status);

18:     error Blacklisted();

24:     function getBlacklist() external view returns (address[] memory blacklist_);

31:     function setBlacklist(address[] calldata assets_, bool status_) external;

```

### <a name="NC-9"></a>[NC-9] Use Underscores for Number Literals (add an underscore every 3 digits)

*Instances (1)*:
```solidity
File: extensions/royalty/RoyaltyExt.sol

17:     uint16 internal constant _MAX_ROYALTY_BPS = 1000;

```

### <a name="NC-10"></a>[NC-10] Constants should be defined rather than using magic numbers

*Instances (1)*:
```solidity
File: ERC721Core.sol

88:         uint16 royalty_, // Percentage in basis points (420 == 4.20%)

```


## Low Issues


| |Issue|Instances|
|-|:-|:-:|
| [L-1](#L-1) | Use a 2-step ownership transfer pattern | 1 |
| [L-2](#L-2) | Division by zero not prevented | 1 |
| [L-3](#L-3) | External call recipient may consume all transaction gas | 3 |
| [L-4](#L-4) | Initializers could be front-run | 4 |
| [L-5](#L-5) | Owner can renounce while system is paused | 4 |
| [L-6](#L-6) | Use `Ownable2Step.transferOwnership` instead of `Ownable.transferOwnership` | 1 |
| [L-7](#L-7) | Sweeping may break accounting if tokens with multiple addresses are used | 2 |
| [L-8](#L-8) | Unsafe ERC20 operation(s) | 2 |
| [L-9](#L-9) | Upgradeable contract not initialized | 5 |
### <a name="L-1"></a>[L-1] Use a 2-step ownership transfer pattern
Recommend considering implementing a two step process where the owner or admin nominates an account and the nominated account needs to call an `acceptOwnership()` function for the transfer of ownership to fully succeed. This ensures the nominated EOA account is a valid and active account. Lack of two-step procedure for critical operations leaves them error-prone. Consider adding two step procedure on the critical functions.

*Instances (1)*:
```solidity
File: Core.sol

18: abstract contract Core is ICore, Ownable, Pausable, ReentrancyGuard {

```

### <a name="L-2"></a>[L-2] Division by zero not prevented
The divisions below take an input parameter which does not have any zero-value checks, which may lead to the functions reverting when zero is passed.

*Instances (1)*:
```solidity
File: ERC721Core.sol

377:             mint(msg.sender, (msg.value / price));

```

### <a name="L-3"></a>[L-3] External call recipient may consume all transaction gas
There is no limit specified on the amount of gas used, so the recipient can use up all of the transaction's gas, causing it to revert. Use `addr.call{gas: <amount>}("")` or [this](https://github.com/nomad-xyz/ExcessivelySafeCall) library instead.

*Instances (3)*:
```solidity
File: Core.sol

144:         (bool success,) = payable(recipient_).call{value: amount_}("");

190:         (bool success,) = payable(owner()).call{value: msg.value}("");

```

```solidity
File: extensions/referral/ReferralExt.sol

35:             (bool success,) = payable(referral_).call{value: referralAlloc}("");

```

### <a name="L-4"></a>[L-4] Initializers could be front-run
Initializers could be front-run, allowing an attacker to either set their own values, take ownership of the contract, and in the best case forcing a re-deployment

*Instances (4)*:
```solidity
File: ERC721Core.sol

57:     function initialize(

68:         initializer

70:         _initialize(name_, symbol_, maxSupply_, royalty_, owner_, price_);

84:     function _initialize(

```

### <a name="L-5"></a>[L-5] Owner can renounce while system is paused
The contract owner or single user with a role is not prevented from renouncing the role/ownership while the contract is paused, which would cause any user assets stored in the protocol, to be locked indefinitely.

*Instances (4)*:
```solidity
File: Core.sol

73:     function pause() external onlyOwner {

77:     function unpause() external onlyOwner {

```

```solidity
File: ERC721Core.sol

332:     function pauseList(uint8 listId_) external virtual onlyOwner {

336:     function unpauseList(uint8 listId_) external virtual onlyOwner {

```

### <a name="L-6"></a>[L-6] Use `Ownable2Step.transferOwnership` instead of `Ownable.transferOwnership`
Use [Ownable2Step.transferOwnership](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable2Step.sol) which is safer. Use it as it is more secure due to 2-stage ownership transfer.

**Recommended Mitigation Steps**

Use <a href="https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable2Step.sol">Ownable2Step.sol</a>
  
  ```solidity
      function acceptOwnership() external {
          address sender = _msgSender();
          require(pendingOwner() == sender, "Ownable2Step: caller is not the new owner");
          _transferOwnership(sender);
      }
```

*Instances (1)*:
```solidity
File: Core.sol

10: import {Ownable} from "solady/src/auth/Ownable.sol";

```

### <a name="L-7"></a>[L-7] Sweeping may break accounting if tokens with multiple addresses are used
There have been [cases](https://blog.openzeppelin.com/compound-tusd-integration-issue-retrospective/) in the past where a token mistakenly had two addresses that could control its balance, and transfers using one address impacted the balance of the other. To protect against this potential scenario, sweep functions should ensure that the balance of the non-sweepable token does not change after the transfer of the swept tokens.

*Instances (2)*:
```solidity
File: Core.sol

168:     function rescueERC20(address token_, address recipient_) public virtual onlyOwner {

183:     function rescueERC721(address token_, address recipient_, uint256 tokenId_) public virtual onlyOwner {

```

### <a name="L-8"></a>[L-8] Unsafe ERC20 operation(s)

*Instances (2)*:
```solidity
File: Core.sol

160:         IERC20(token_).transfer(recipient_, amount_);

174:         IERC721(token_).transferFrom(address(this), recipient_, tokenId_);

```

### <a name="L-9"></a>[L-9] Upgradeable contract not initialized
Upgradeable contracts are initialized via an initializer function rather than by a constructor. Leaving such a contract uninitialized may lead to it being taken over by a malicious user

*Instances (5)*:
```solidity
File: ERC721Core.sol

57:     function initialize(

68:         initializer

70:         _initialize(name_, symbol_, maxSupply_, royalty_, owner_, price_);

84:     function _initialize(

98:         _initializeOwner(owner_);

```


## Medium Issues


| |Issue|Instances|
|-|:-|:-:|
| [M-1](#M-1) | Centralization Risk for trusted owners | 24 |
| [M-2](#M-2) | Using `transferFrom` on ERC721 tokens | 1 |
| [M-3](#M-3) | Direct `supportsInterface()` calls may cause caller to revert | 3 |
### <a name="M-1"></a>[M-1] Centralization Risk for trusted owners

#### Impact:
Contracts have owners with privileged rights to perform admin tasks and need to be trusted to not perform malicious updates or drain funds.

*Instances (24)*:
```solidity
File: Core.sol

18: abstract contract Core is ICore, Ownable, Pausable, ReentrancyGuard {

73:     function pause() external onlyOwner {

77:     function unpause() external onlyOwner {

85:     function setPrice(uint256 price_) external virtual onlyOwner {

90:     function setMintPeriod(uint32 start_, uint32 end_) external onlyOwner {

99:     function setClaimableUserSupply(uint32 claimable_) external virtual onlyOwner {

105:     function setUnit(uint24 unit_) external virtual onlyOwner {

117:     function setSupply(uint32 maxSupply_) external virtual onlyOwner {

168:     function rescueERC20(address token_, address recipient_) public virtual onlyOwner {

183:     function rescueERC721(address token_, address recipient_, uint256 tokenId_) public virtual onlyOwner {

```

```solidity
File: ERC721Core.sol

284:     function setSupply(uint32 maxSupply_) external virtual override onlyOwner {

291:     function setContractURI(string memory contractURI_) external virtual onlyOwner {

295:     function setBaseURI(string memory baseURI_, string memory fileExtension_) external virtual onlyOwner {

299:     function setTokenURI(uint256 tokenId_, string memory tokenURI_) external virtual onlyOwner {

303:     function freezeURI() external virtual onlyOwner {

307:     function freezeTokenURI(uint256 tokenId_) external virtual onlyOwner {

332:     function pauseList(uint8 listId_) external virtual onlyOwner {

336:     function unpauseList(uint8 listId_) external virtual onlyOwner {

340:     function deleteList(uint8 listId_) external virtual onlyOwner {

346:     function setRoyalties(address recipient_, uint96 bps_) external virtual onlyOwner {

351:     function setTokenRoyalties(uint256 tokenId_, address recipient_, uint96 bps_) external virtual onlyOwner {

356:     function disableRoyalties() external virtual onlyOwner {

362:     function setBlacklist(address[] calldata assets_, bool status_) external virtual onlyOwner {

368:     function setReferralFee(uint16 bps_) external virtual onlyOwner {

```

### <a name="M-2"></a>[M-2] Using `transferFrom` on ERC721 tokens
The `transferFrom` function is used instead of `safeTransferFrom` and [it's discouraged by OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/109778c17c7020618ea4e035efb9f0f9b82d43ca/contracts/token/ERC721/IERC721.sol#L84). If the arbitrary address is a contract and is not aware of the incoming ERC721 token, the sent token could be locked.

*Instances (1)*:
```solidity
File: Core.sol

174:         IERC721(token_).transferFrom(address(this), recipient_, tokenId_);

```

### <a name="M-3"></a>[M-3] Direct `supportsInterface()` calls may cause caller to revert
Calling `supportsInterface()` on a contract that doesn't implement the ERC-165 standard will result in the call reverting. Even if the caller does support the function, the contract may be malicious and consume all of the transaction's available gas. Call it via a low-level [staticcall()](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f959d7e4e6ee0b022b41e5b644c79369869d8411/contracts/utils/introspection/ERC165Checker.sol#L119), with a fixed amount of gas, and check the return code, or use OpenZeppelin's [`ERC165Checker.supportsInterface()`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f959d7e4e6ee0b022b41e5b644c79369869d8411/contracts/utils/introspection/ERC165Checker.sol#L36-L39).

*Instances (3)*:
```solidity
File: ERC721Core.sol

137:         return RoyaltyExt.supportsInterface(interfaceId_) || CoreMetadata721.supportsInterface(interfaceId_);

```

```solidity
File: extensions/royalty/RoyaltyExt.sol

58:         return ERC2981.supportsInterface(interfaceId_);

```

```solidity
File: metadata/CoreMetadata721.sol

59:             || ERC721.supportsInterface(interfaceId_);

```

