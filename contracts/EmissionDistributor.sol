library Base64 {
    bytes internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    /// @notice Encodes some bytes to the base64 representation
    function encode(bytes memory data) internal pure returns (string memory) {
        uint len = data.length;
        if (len == 0) return "";

        // multiply by 4/3 rounded up
        uint encodedLen = 4 * ((len + 2) / 3);

        // Add some extra buffer at the end
        bytes memory result = new bytes(encodedLen + 32);

        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)

                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
                out := shl(224, out)

                mstore(resultPtr, out)

                resultPtr := add(resultPtr, 4)
            }

            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }

            mstore(result, encodedLen)
        }

        return string(result);
    }
}

/**
* @dev Interface of the ERC165 standard, as defined in the
* https://eips.ethereum.org/EIPS/eip-165[EIP].
*
* Implementers can declare support of contract interfaces, which can then be
* queried by others ({ERC165Checker}).
*
* For an implementation, see {ERC165}.
*/
interface IERC165 {
    /**
    * @dev Returns true if this contract implements the interface defined by
    * `interfaceId`. See the corresponding
    * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
    * to learn more about how these ids are created.
    *
    * This function call must use less than 30 000 gas.
    */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

/**
* @dev Required interface of an ERC721 compliant contract.
*/
interface IERC721 is IERC165 {
    /**
    * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
    */
    event Transfer(address indexed from, address indexed to, uint indexed tokenId);

    /**
    * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
    */
    event Approval(address indexed owner, address indexed approved, uint indexed tokenId);

    /**
    * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
    */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
    * @dev Returns the number of tokens in ``owner``'s account.
    */
    function balanceOf(address owner) external view returns (uint balance);

    /**
    * @dev Returns the owner of the `tokenId` token.
    *
    * Requirements:
    *
    * - `tokenId` must exist.
    */
    function ownerOf(uint tokenId) external view returns (address owner);

    /**
    * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
    * are aware of the ERC721 protocol to prevent tokens from being forever locked.
    *
    * Requirements:
    *
    * - `from` cannot be the zero address.
    * - `to` cannot be the zero address.
    * - `tokenId` token must exist and be owned by `from`.
    * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
    * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
    *
    * Emits a {Transfer} event.
    */
    function safeTransferFrom(
        address from,
        address to,
        uint tokenId
    ) external;

    /**
    * @dev Transfers `tokenId` token from `from` to `to`.
    *
    * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
    *
    * Requirements:
    *
    * - `from` cannot be the zero address.
    * - `to` cannot be the zero address.
    * - `tokenId` token must be owned by `from`.
    * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
    *
    * Emits a {Transfer} event.
    */
    function transferFrom(
        address from,
        address to,
        uint tokenId
    ) external;

    /**
    * @dev Gives permission to `to` to transfer `tokenId` token to another account.
    * The approval is cleared when the token is transferred.
    *
    * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
    *
    * Requirements:
    *
    * - The caller must own the token or be an approved operator.
    * - `tokenId` must exist.
    *
    * Emits an {Approval} event.
    */
    function approve(address to, uint tokenId) external;

    /**
    * @dev Returns the account approved for `tokenId` token.
    *
    * Requirements:
    *
    * - `tokenId` must exist.
    */
    function getApproved(uint tokenId) external view returns (address operator);

    /**
    * @dev Approve or remove `operator` as an operator for the caller.
    * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
    *
    * Requirements:
    *
    * - The `operator` cannot be the caller.
    *
    * Emits an {ApprovalForAll} event.
    */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
    * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
    *
    * See {setApprovalForAll}
    */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
    * @dev Safely transfers `tokenId` token from `from` to `to`.
    *
    * Requirements:
    *
    * - `from` cannot be the zero address.
    * - `to` cannot be the zero address.
    * - `tokenId` token must exist and be owned by `from`.
    * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
    * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
    *
    * Emits a {Transfer} event.
    */
    function safeTransferFrom(
        address from,
        address to,
        uint tokenId,
        bytes calldata data
    ) external;
}

/**
* @title ERC721 token receiver interface
* @dev Interface for any contract that wants to support safeTransfers
* from ERC721 asset contracts.
*/
interface IERC721Receiver {
    /**
    * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
    * by `operator` from `from`, this function is called.
    *
    * It must return its Solidity selector to confirm the token transfer.
    * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
    *
    * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
    */
    function onERC721Received(
        address operator,
        address from,
        uint tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

/**
* @title ERC-721 Non-Fungible Token Standard, optional metadata extension
* @dev See https://eips.ethereum.org/EIPS/eip-721
*/
interface IERC721Metadata is IERC721 {
    /**
    * @dev Returns the token collection name.
    */
    function name() external view returns (string memory);

    /**
    * @dev Returns the token collection symbol.
    */
    function symbol() external view returns (string memory);

    /**
    * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
    */
    function tokenURI(uint tokenId) external view returns (string memory);
}


/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

contract WAVEToken is ERC20("WAVEToken", "WAVE"), Ownable {
    uint256 public constant MAX_SUPPLY = 10_000_000e18; // 10 million WAVE

    /// @notice Creates `_amount` token to `_to`. Must only be called by the owner (MasterChef).
    function mint(address _to, uint256 _amount) public onlyOwner {
        require(
            totalSupply() + _amount <= MAX_SUPPLY,
            "WAVE::mint: cannot exceed max supply"
        );
        _mint(_to, _amount);
    }
}

contract veWAVEReceipt is ERC20("veWAVEReceipt", "veWAVEReceipt"), Ownable {

    /// @notice Creates `_amount` token to `_to`. Must only be called by the owner (EmissionsDistributor).
    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
    }

    function burn(address _to, uint256 _amount) public onlyOwner {
        _burn(_to, _amount);
    }
}

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

struct Point {
    int128 bias;
    int128 slope; // # -dweight / dt
    uint ts;
    uint blk; // block
}
/* We cannot really do block numbers per se b/c slope is per time, not per block
* and per block could be fairly bad b/c Ethereum changes blocktimes.
* What we can do is to extrapolate ***At functions */

struct LockedBalance {
    int128 amount;
    uint end;
}


/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

pragma solidity 0.8.7;

interface IRewarder {
    function onWAVEReward(
        uint256 pid,
        address user,
        address recipient,
        uint256 waveAmount,
        uint256 newLpAmount
    ) external;

    function pendingTokens(
        uint256 pid,
        address user,
        uint256 waveAmount
    ) external view returns (IERC20[] memory, uint256[] memory);
}

/*
    This master chef is based on SUSHI's version with some adjustments:
     - Upgrade to pragma 0.8.7
     - therefore remove usage of SafeMath (built in overflow check for solidity > 8)
     - Merge sushi's master chef V1 & V2 (no usage of dummy pool)
     - remove withdraw function (without harvest) => requires the rewardDebt to be an signed int instead of uint which requires a lot of casting and has no real usecase for us
     - no dev emissions, but treasury emissions instead
     - treasury percentage is subtracted from emissions instead of added on top
     - update of emission rate with upper limit of 6 BEETS/block
     - more require checks in general
*/

contract WAVEMasterChef is Ownable {
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;

    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        //
        // We do some fancy math here. Basically, any point in time, the amount of WAVE
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accWAVEPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accWAVEPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }
    // Info of each pool.
    struct PoolInfo {
        // we have a fixed number of WAVE tokens released per block, each pool gets his fraction based on the allocPoint
        uint256 allocPoint; // How many allocation points assigned to this pool. the fraction WAVE to distribute per block.
        uint256 lastRewardBlock; // Last block number that WAVE distribution occurs.
        uint256 accWAVEPerShare; // Accumulated WAVE per LP share. this is multiplied by ACC_WAVE_PRECISION for more exact results (rounding errors)
    }
    // The WAVE TOKEN!
    WAVEToken public wave;

    // Treasury address.
    address public treasuryAddress;

    // WAVE tokens created per block.
    uint256 public wavePerBlock;

    uint256 private constant ACC_WAVE_PRECISION = 1e12;

    // distribution percentages: a value of 1000 = 100%
    // 12.8% percentage of pool rewards that goes to the treasury.
    uint256 public constant TREASURY_PERCENTAGE = 124;

    // 87.2% percentage of pool rewards that goes to LP holders.
    uint256 public constant POOL_PERCENTAGE = 876;

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens per pool. poolId => address => userInfo
    /// @notice Address of the LP token for each MCV pool.
    IERC20[] public lpTokens;

    EnumerableSet.AddressSet private lpTokenAddresses;

    /// @notice Address of each `IRewarder` contract in MCV.
    IRewarder[] public rewarder;

    mapping(uint256 => mapping(address => UserInfo)) public userInfo; // mapping form poolId => user Address => User Info
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when WAVE mining starts.
    uint256 public startBlock;

    event Deposit(
        address indexed user,
        uint256 indexed pid,
        uint256 amount,
        address indexed to
    );
    event Withdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount,
        address indexed to
    );
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount,
        address indexed to
    );
    event Harvest(address indexed user, uint256 indexed pid, uint256 amount);
    event LogPoolAddition(
        uint256 indexed pid,
        uint256 allocPoint,
        IERC20 indexed lpToken,
        IRewarder indexed rewarder
    );
    event LogSetPool(
        uint256 indexed pid,
        uint256 allocPoint,
        IRewarder indexed rewarder,
        bool overwrite
    );
    event LogUpdatePool(
        uint256 indexed pid,
        uint256 lastRewardBlock,
        uint256 lpSupply,
        uint256 accWAVEPerShare
    );
    event SetTreasuryAddress(
        address indexed oldAddress,
        address indexed newAddress
    );
    event UpdateEmissionRate(address indexed user, uint256 _wavePerSec);

    constructor(
        WAVEToken _wave,
        address _treasuryAddress,
        uint256 _wavePerBlock,
        uint256 _startBlock
    ) {
        require(
            _wavePerBlock <= 6e18,
            "maximum emission rate of 6 wave per block exceeded"
        );
        wave = _wave;
        treasuryAddress = _treasuryAddress;
        wavePerBlock = _wavePerBlock;
        startBlock = _startBlock;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    function add(
        uint256 _allocPoint,
        IERC20 _lpToken,
        IRewarder _rewarder
    ) public onlyOwner {
        require(
            Address.isContract(address(_lpToken)),
            "add: LP token must be a valid contract"
        );
        require(
            Address.isContract(address(_rewarder)) ||
                address(_rewarder) == address(0),
            "add: rewarder must be contract or zero"
        );
        // we make sure the same LP cannot be added twice which would cause trouble
        require(
            !lpTokenAddresses.contains(address(_lpToken)),
            "add: LP already added"
        );

        // respect startBlock!
        uint256 lastRewardBlock = block.timestamp > startBlock
            ? block.timestamp
            : startBlock;
        totalAllocPoint = totalAllocPoint + _allocPoint;

        // LP tokens, rewarders & pools are always on the same index which translates into the pid
        lpTokens.push(_lpToken);
        lpTokenAddresses.add(address(_lpToken));
        rewarder.push(_rewarder);

        poolInfo.push(
            PoolInfo({
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accWAVEPerShare: 0
            })
        );
        emit LogPoolAddition(
            lpTokens.length - 1,
            _allocPoint,
            _lpToken,
            _rewarder
        );
    }

    // Update the given pool's WAVE allocation point. Can only be called by the owner.
    /// @param _pid The index of the pool. See `poolInfo`.
    /// @param _allocPoint New AP of the pool.
    /// @param _rewarder Address of the rewarder delegate.
    /// @param overwrite True if _rewarder should be `set`. Otherwise `_rewarder` is ignored.
    function set(
        uint256 _pid,
        uint256 _allocPoint,
        IRewarder _rewarder,
        bool overwrite
    ) public onlyOwner {
        require(
            Address.isContract(address(_rewarder)) ||
                address(_rewarder) == address(0),
            "set: rewarder must be contract or zero"
        );

        // we re-adjust the total allocation points
        totalAllocPoint =
            totalAllocPoint -
            poolInfo[_pid].allocPoint +
            _allocPoint;

        poolInfo[_pid].allocPoint = _allocPoint;

        if (overwrite) {
            rewarder[_pid] = _rewarder;
        }
        emit LogSetPool(
            _pid,
            _allocPoint,
            overwrite ? _rewarder : rewarder[_pid],
            overwrite
        );
    }

    // View function to see pending WAVE on frontend.
    function pendingWAVE(uint256 _pid, address _user)
        external
        view
        returns (uint256 pending)
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        // how many WAVE per lp token
        uint256 accWAVEPerShare = pool.accWAVEPerShare;
        // total staked lp tokens in this pool
        uint256 lpSupply = lpTokens[_pid].balanceOf(address(this));

        if (block.timestamp > pool.lastRewardBlock && lpSupply != 0) {
            uint256 blocksSinceLastReward = block.timestamp - pool.lastRewardBlock;
            // based on the pool weight (allocation points) we calculate the wave rewarded for this specific pool
            uint256 waveRewards = (blocksSinceLastReward *
                wavePerBlock *
                pool.allocPoint) / totalAllocPoint;

            // we take parts of the rewards for treasury, these can be subject to change, so we recalculate it
            // a value of 1000 = 100%
            uint256 waveRewardsForPool = (waveRewards * POOL_PERCENTAGE) /
                1000;

            // we calculate the new amount of accumulated wave per LP token
            accWAVEPerShare =
                accWAVEPerShare +
                ((waveRewardsForPool * ACC_WAVE_PRECISION) / lpSupply);
        }
        // based on the number of LP tokens the user owns, we calculate the pending amount by subtracting the amount
        // which he is not eligible for (joined the pool later) or has already harvested
        pending =
            (user.amount * accWAVEPerShare) /
            ACC_WAVE_PRECISION -
            user.rewardDebt;
    }

    /// @notice Update reward variables for all pools. Be careful of gas spending!
    /// @param pids Pool IDs of all to be updated. Make sure to update all active pools.
    function massUpdatePools(uint256[] calldata pids) external {
        uint256 len = pids.length;
        for (uint256 i = 0; i < len; ++i) {
            updatePool(pids[i]);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public returns (PoolInfo memory pool) {
        pool = poolInfo[_pid];

        if (block.timestamp > pool.lastRewardBlock) {
            // total lp tokens staked for this pool
            uint256 lpSupply = lpTokens[_pid].balanceOf(address(this));
            if (lpSupply > 0) {
                uint256 blocksSinceLastReward = block.timestamp -
                    pool.lastRewardBlock;

                // rewards for this pool based on his allocation points
                uint256 waveRewards = (blocksSinceLastReward *
                    wavePerBlock *
                    pool.allocPoint) / totalAllocPoint;

                uint256 waveRewardsForPool = (waveRewards * POOL_PERCENTAGE) /
                    1000;

                wave.mint(
                    treasuryAddress,
                    (waveRewards * TREASURY_PERCENTAGE) / 1000
                );

                wave.mint(address(this), waveRewardsForPool);

                pool.accWAVEPerShare =
                    pool.accWAVEPerShare +
                    ((waveRewardsForPool * ACC_WAVE_PRECISION) / lpSupply);
            }
            pool.lastRewardBlock = block.timestamp;
            poolInfo[_pid] = pool;

            emit LogUpdatePool(
                _pid,
                pool.lastRewardBlock,
                lpSupply,
                pool.accWAVEPerShare
            );
        }
    }

    // Deposit LP tokens to MasterChef for WAVE allocation.
    function deposit(
        uint256 _pid,
        uint256 _amount,
        address _to
    ) public {
        PoolInfo memory pool = updatePool(_pid);
        UserInfo storage user = userInfo[_pid][_to];

        user.amount = user.amount + _amount;
        // since we add more LP tokens, we have to keep track of the rewards he is not eligible for
        // if we would not do that, he would get rewards like he added them since the beginning of this pool
        // note that only the accWAVEPerShare have the precision applied
        user.rewardDebt =
            user.rewardDebt +
            (_amount * pool.accWAVEPerShare) /
            ACC_WAVE_PRECISION;

        IRewarder _rewarder = rewarder[_pid];
        if (address(_rewarder) != address(0)) {
            _rewarder.onWAVEReward(_pid, _to, _to, 0, user.amount);
        }

        lpTokens[_pid].safeTransferFrom(msg.sender, address(this), _amount);

        emit Deposit(msg.sender, _pid, _amount, _to);
    }

    function harvestAll(uint256[] calldata _pids, address _to) external {
        for (uint256 i = 0; i < _pids.length; i++) {
            if (userInfo[_pids[i]][msg.sender].amount > 0) {
                harvest(_pids[i], _to);
            }
        }
    }

    /// @notice Harvest proceeds for transaction sender to `_to`.
    /// @param _pid The index of the pool. See `poolInfo`.
    /// @param _to Receiver of WAVE rewards.
    function harvest(uint256 _pid, address _to) public {
        PoolInfo memory pool = updatePool(_pid);
        UserInfo storage user = userInfo[_pid][msg.sender];

        // this would  be the amount if the user joined right from the start of the farm
        uint256 accumulatedWAVE = (user.amount * pool.accWAVEPerShare) /
            ACC_WAVE_PRECISION;
        // subtracting the rewards the user is not eligible for
        uint256 eligibleWAVE = accumulatedWAVE - user.rewardDebt;

        // we set the new rewardDebt to the current accumulated amount of rewards for his amount of LP token
        user.rewardDebt = accumulatedWAVE;

        if (eligibleWAVE > 0) {
            safeWAVETransfer(_to, eligibleWAVE);
        }

        IRewarder _rewarder = rewarder[_pid];
        if (address(_rewarder) != address(0)) {
            _rewarder.onWAVEReward(
                _pid,
                msg.sender,
                _to,
                eligibleWAVE,
                user.amount
            );
        }

        emit Harvest(msg.sender, _pid, eligibleWAVE);
    }

    /// @notice Withdraw LP tokens from MCV and harvest proceeds for transaction sender to `_to`.
    /// @param _pid The index of the pool. See `poolInfo`.
    /// @param _amount LP token amount to withdraw.
    /// @param _to Receiver of the LP tokens and WAVE rewards.
    function withdrawAndHarvest(
        uint256 _pid,
        uint256 _amount,
        address _to
    ) public {
        PoolInfo memory pool = updatePool(_pid);
        UserInfo storage user = userInfo[_pid][msg.sender];

        require(_amount <= user.amount, "cannot withdraw more than deposited");

        // this would  be the amount if the user joined right from the start of the farm
        uint256 accumulatedWAVE = (user.amount * pool.accWAVEPerShare) /
            ACC_WAVE_PRECISION;
        // subtracting the rewards the user is not eligible for
        uint256 eligibleWAVE = accumulatedWAVE - user.rewardDebt;

        /*
            after harvest & withdraw, he should be eligible for exactly 0 tokens
            => userInfo.amount * pool.accWAVEPerShare / ACC_WAVE_PRECISION == userInfo.rewardDebt
            since we are removing some LP's from userInfo.amount, we also have to remove
            the equivalent amount of reward debt
        */

        user.rewardDebt =
            accumulatedWAVE -
            (_amount * pool.accWAVEPerShare) /
            ACC_WAVE_PRECISION;
        user.amount = user.amount - _amount;

        safeWAVETransfer(_to, eligibleWAVE);

        IRewarder _rewarder = rewarder[_pid];
        if (address(_rewarder) != address(0)) {
            _rewarder.onWAVEReward(
                _pid,
                msg.sender,
                _to,
                eligibleWAVE,
                user.amount
            );
        }

        lpTokens[_pid].safeTransfer(_to, _amount);

        emit Withdraw(msg.sender, _pid, _amount, _to);
        emit Harvest(msg.sender, _pid, eligibleWAVE);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid, address _to) public {
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;

        IRewarder _rewarder = rewarder[_pid];
        if (address(_rewarder) != address(0)) {
            _rewarder.onWAVEReward(_pid, msg.sender, _to, 0, 0);
        }

        // Note: transfer can fail or succeed if `amount` is zero.
        lpTokens[_pid].safeTransfer(_to, amount);
        emit EmergencyWithdraw(msg.sender, _pid, amount, _to);
    }

    // Safe WAVE transfer function, just in case if rounding error causes pool to not have enough WAVE.
    function safeWAVETransfer(address _to, uint256 _amount) internal {
        uint256 waveBalance = wave.balanceOf(address(this));
        if (_amount > waveBalance) {
            wave.transfer(_to, waveBalance);
        } else {
            wave.transfer(_to, _amount);
        }
    }

    // Update treasury address by the owner.
    function treasury(address _treasuryAddress) public onlyOwner {
        treasuryAddress = _treasuryAddress;
        emit SetTreasuryAddress(treasuryAddress, _treasuryAddress);
    }

    function updateEmissionRate(uint256 _wavePerBlock) public onlyOwner {
        require(
            _wavePerBlock <= 6e18,
            "maximum emission rate of 6 wave per block exceeded"
        );
        wavePerBlock = _wavePerBlock;
        emit UpdateEmissionRate(msg.sender, _wavePerBlock);
    }
}

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

interface ve {
    function token() external view returns (address);
    function locking(uint) external view returns (uint);
    function locked__end(uint) external view returns (uint);
    function totalSupply() external view returns (uint);
    function create_lock_for(uint, uint, address) external returns (uint);
    function transferFrom(address, address, uint) external;
}

pragma solidity 0.8.7;

contract WaveEmissionDistributor is
    ERC20("VEWAVE EMISSION DISTRIBUTOR", "edveWAVE"),
    AccessControl, Ownable
{
    using SafeERC20 for IERC20;

    // TokenInfo Struct
    struct TokenInfo {
        address user;  // address from the owner of this veWave
        uint256 numberNFT; // TokenId veWave
        uint256 numberDummyTokens; // Number of dummy tokens owned by the user on this numberNFT
    }

    /******************** AnotherToken Structs ********************/
    struct UserInfo {
        uint256 amount; // How many WAVE locked by the user on veWAVE.
        uint256 rewardDebt; // WAVE Reward debt.
    }

     // Info of each pool.
    struct PoolInfo {
        uint256 allocPoint; // How many allocation points assigned to this pool. the fraction WAVE to distribute per block.
        uint256 lastRewardBlock; // Last block number that WAVE distribution occurs.
        uint256 accWAVEPerShare; // Accumulated WAVE per LP share. this is multiplied by ACC_WAVE_PRECISION for more exact results (rounding errors)
    }
    /****************************************************************/


    /******************** AnotherToken Structs **********************/
    struct PoolInfoAnotherToken {
        address tokenReward; // address from the Reward of this each Pool
        uint256 anotherTokenPerBlock; // How much AnotherTokens Per Block
        bool isClosed; // If this pool reward isClosed or not
        uint256 allocPoint; // How many allocation points assigned to this pool. the fraction AnotherToken to distribute per block.
        uint256 lastRewardBlock; // Last block number that AnotherToken distribution occurs.
        uint256 accAnotherTokenPerShare; // Accumulated WAVE per veWave. this is multiplied by ACC_ANOTHERTOKEN_PRECISION for more exact results (rounding errors)
    }

    struct UserInfoAnotherToken {
        uint256 amount; // How many WAVE locked by the user on veWAVE.
        uint256 rewardDebt; // AnotherToken Reward debt.
    }
    /****************************************************************/

    PoolInfoAnotherToken[] public poolInfoAnotherToken; // an array to store information of all pools of another token
    uint256 public totalPidsAnotherToken = 0; // total number of another token pools
    mapping(uint256 => mapping(address => mapping(uint256 => UserInfoAnotherToken))) public userInfoAnotherToken; // mapping form poolId => user Address => User Info

    PoolInfo[] public poolInfo;  // an array to store information of all pools of WAVE
    TokenInfo[] public tokenInfo; // mapping form poolId => user Address => User Info
    mapping(address => mapping(uint256 => TokenInfo)) public tokenInfoCheck; // mapping form poolId => user Address => User Info
    mapping(uint256 => mapping(address => mapping(uint256 => UserInfo))) public userInfo; // mapping form poolId => user Address => User Info

    uint256 public totalAmountLockedWave = 0; // total WAVE locked in pools
    uint256 public wavePerBlock;     // WAVE distributed per block

    mapping (address => uint[]) public tokenIdsByUser;

    mapping (address => uint256) public totalNftsByUser;


    uint256 private constant ACC_ANOTHERTOKEN_PRECISION = 1e12; // precision used for calculations involving another token
    uint256 private constant ACC_WAVE_PRECISION = 1e12;   // Precision for accumulating WAVE
    uint256 public constant POOL_PERCENTAGE = 876;   // Percentage of WAVE allocated to pools

    WAVEMasterChef public chef;  // MasterChef contract for controlling distribution
    uint256 public farmPid;  // ID for the farming pool
    uint256 public constant DENOMINATOR = 1000;  // Constant denominator for calculating allocation points

    IERC721 public veWave;  // veWave ERC721 token
    IERC20 public wave;  // WAVE ERC20 token
    IERC20 public veWaveReceipt;  // veWave receipt token

    /* WAVE Rewards Events*/
    event LogSetPool(uint256 allocPoint);
    event Harvest(address indexed user, uint256 indexed pid, uint256 amount);
    event LogPoolAddition(uint256 indexed pid, uint256 allocPoint);
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount, address indexed to);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount, address indexed to);

    /* AnotherToken Rewards Events*/
    event LogSetPoolAnotherToken(uint256 indexed pid, address indexed tokenReward, bool indexed isClosed,  uint256 allocPoint);
    event LogPoolAnotherTokenAddition(uint256 indexed pid, address indexed tokenReward, bool indexed isClosed, uint256 allocPoint);
    event DepositAnotherToken(address indexed user, uint256 indexed pid, uint256 amount, address indexed to);
    event WithdrawAnotherToken(address indexed user, uint256 indexed pid, uint256 amount, address indexed to);
    event HarvestAnotherToken(address indexed user, uint256 indexed pid, uint256 amount);
    event LogUpdatePoolAnotherToken(uint256 indexed pid, uint256 lastRewardBlock, uint256 totalAmountLockedWave, uint256 accWAVEPerShare);
    
    /* General Events */
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount, address indexed to);

    constructor(
       IERC721 _veWave,  // veWave ERC721 token
        IERC20 _wave, // WAVE ERC20 token
        WAVEMasterChef _chef, // MasterChef contract for controlling distribution
        uint256 _farmPid, // ID for the farming pool
        IERC20 _veWaveReceipt // veWave receipt token
    ) {
        veWave = _veWave;
        wave = _wave;
        chef = _chef;
        farmPid = _farmPid;
        veWaveReceipt = _veWaveReceipt;
    }

    function setFarmId(uint256 id) external onlyOwner {
        farmPid = id;
    }

    // Function to deposit veWAVE token to the contract and receive rewards
    function depositToChef(uint256 _pid, uint256 _tokenId) external payable {
        // Check if msg.sender is the owner of the veWAVE
        address ownerOfTokenId = IERC721(veWave).ownerOf(_tokenId);
        require(ownerOfTokenId == address(msg.sender),"You are not the owner of this veWAVE");

        // AnotherToken Rewards attributes
        PoolInfoAnotherToken memory poolAnotherToken = updatePoolAnotherToken(_pid);
        UserInfoAnotherToken storage userAnotherToken = userInfoAnotherToken[_pid][address(msg.sender)][_tokenId];
        
        // Wave Rewards attributes
        PoolInfo memory pool = updatePool();
        UserInfo storage user = userInfo[0][address(msg.sender)][_tokenId];

        // Take and write info about tokenInfo (user address & _numberNFT/tokenId
        TokenInfo storage tokenInfoUser = tokenInfoCheck[address(msg.sender)][_tokenId];
        tokenInfoUser.user = address(msg.sender);
        tokenInfoUser.numberNFT = _tokenId;
        
        totalNftsByUser[address(msg.sender)] = totalNftsByUser[address(msg.sender)] + 1;
        tokenIdsByUser[address(msg.sender)].push(_tokenId);
        
        // Transfer the veWAVE token from the user to the contract
        ve(address(veWave)).transferFrom(address(msg.sender), address(this), _tokenId);
        uint256 amount = ve(address(veWave)).locking(_tokenId);

        /******************** AnotherToken Rewards Code ********************/
        // AnotherToken Rewards Code 
        if (poolAnotherToken.isClosed != true) {
            userAnotherToken.amount = userAnotherToken.amount + amount;
            userAnotherToken.rewardDebt = userAnotherToken.rewardDebt + (amount * poolAnotherToken.accAnotherTokenPerShare) / ACC_ANOTHERTOKEN_PRECISION;
        }      
        /*******************************************************************/
        
        /******************** WAVE Rewards Code ********************/
        totalAmountLockedWave = totalAmountLockedWave + amount;
        _mint(address(this), amount); // mint 
        _approve(address(this), address(chef), amount);
        chef.deposit(farmPid, amount, address(this));
        user.amount = amount;
        user.rewardDebt = user.rewardDebt + (amount * pool.accWAVEPerShare) / ACC_WAVE_PRECISION;
        /*************************************************************/

         /******************** veWAVEReceipt Code ********************/
        // Mint the veWAVEReceipt token for the user based on the locked time of the veWAVE token
        uint256 timeDays = ve(address(veWave)).locked__end(_tokenId) - block.timestamp;
        uint256 mediumMint = timeDays + 86400;
        uint256 finalMint = (mediumMint * 10 ** 18)/31556926;
        
        veWAVEReceipt(address(veWaveReceipt)).mint(address(msg.sender), finalMint);
        /*************************************************************/
        // Push the tokenInfo to the tokenInfo array
        tokenInfo.push(
            TokenInfo({
                user: address(msg.sender),
                numberNFT:  _tokenId,
                numberDummyTokens: finalMint  
            })
        );

        // Events    
        // Emit events for deposit
        emit Deposit(msg.sender, 0, amount, address(msg.sender));
        emit DepositAnotherToken(msg.sender, _pid, amount, address(msg.sender));
    }

    function withdrawAndDistribute(uint256 _pid, uint256 _tokenId) external {
        TokenInfo storage tokenInfoUser = tokenInfoCheck[address(msg.sender)][_tokenId];
        // Check if msg.sender is the owner of the veWAVE
        require(tokenInfoUser.numberNFT != 0, "You are not the owner of this veWAVE");  // Check if msg.sender is the owner of the veWAVE
        // Check if msg.sender have at least 1 veWAVEReceipt
        require(veWaveReceipt.balanceOf(address(msg.sender)) >= tokenInfoUser.numberDummyTokens, "You don't have any veWAVEReceipt");  // Check if msg.sender have at least 1 veWAVEReceipt
                                                                
        // AnotherToken Rewards attributes
        PoolInfoAnotherToken memory poolAnotherToken = updatePoolAnotherToken(_pid);
        UserInfoAnotherToken storage userAnotherToken = userInfoAnotherToken[_pid][address(msg.sender)][_tokenId];
        
        // Wave Rewards attributes
        PoolInfo memory pool = updatePool();
        UserInfo storage user = userInfo[0][address(msg.sender)][_tokenId];

        /******************** WAVE Rewards Code ********************/
        uint256  amount = ve(address(veWave)).locking(_tokenId);  // amount of locked WAVE on that veWAVE
        chef.withdrawAndHarvest(farmPid, amount, address(this));  // withdraw edveWAVE of MasterChef and harvest WAVE
        totalAmountLockedWave = totalAmountLockedWave + amount; // amount of lockedWave on the contract - amount of locked Wave of that veWAVE
        _burn(address(this), amount); // burn edveWAVE
        // this would  be the amount if the user joined right from the start of the farm
        uint256 accumulatedWAVE = (user.amount * pool.accWAVEPerShare) / ACC_WAVE_PRECISION;
        // subtracting the rewards the user is not eligible for
        uint256 eligibleWAVE = accumulatedWAVE - user.rewardDebt; 
        user.rewardDebt = accumulatedWAVE - (amount * pool.accWAVEPerShare) / ACC_WAVE_PRECISION; // update WAVE Reward Debt
        user.amount = user.amount - amount; // put user amount of UserInfo a zero
        safeWAVETransfer(address(msg.sender), eligibleWAVE); 
        /************************************************************/

        /******************** AnotherToken Rewards Code ********************/
        if (poolAnotherToken.isClosed == false) {
            // this would  be the amount if the user joined right from the start of the farm
            uint256 accumulatedWAnotherToken = (userAnotherToken.amount * poolAnotherToken.accAnotherTokenPerShare) / ACC_ANOTHERTOKEN_PRECISION;
            // subtracting the rewards the user is not eligible for
            uint256 eligibleAnotherToken = accumulatedWAnotherToken - userAnotherToken.rewardDebt;
            user.rewardDebt = accumulatedWAnotherToken - (amount * poolAnotherToken.accAnotherTokenPerShare) / ACC_ANOTHERTOKEN_PRECISION; // update AnotherToken Reward Debt
            userAnotherToken.amount = userAnotherToken.amount - amount; // put user amount of UserInfo a zero
            safeAnotherTokenTransfer(_pid, address(msg.sender), eligibleAnotherToken); 
        }
        /********************************************************************/

        /******************** veWAVEReceipt Code ********************/
        veWAVEReceipt(address(veWaveReceipt)).burn(address(msg.sender), tokenInfoUser.numberDummyTokens);
        /*************************************************************/

        /* Token Info delete data */
        tokenInfoUser.numberDummyTokens = 0;
        tokenInfoUser.user = address(0); 
        tokenInfoUser.numberNFT = 0;
        /***********************/


        IERC721(veWave).safeTransferFrom(address(this), address(msg.sender), _tokenId); // transfer veWAVE to his owner

       for (uint i = 0; i < tokenIdsByUser[address(msg.sender)].length; i++) {
        if (tokenIdsByUser[address(msg.sender)][i] == _tokenId) {
            delete tokenIdsByUser[address(msg.sender)][i];
        }
        }

        totalNftsByUser[address(msg.sender)] = totalNftsByUser[address(msg.sender)] - 1;

        // Events
        emit Withdraw(msg.sender, 0, amount, msg.sender);
        emit WithdrawAnotherToken(msg.sender, _pid, amount, msg.sender);
    }

    function harvestAndDistribute(uint256 _tokenId) public {
        // Get the current pool information
        PoolInfo memory pool = updatePool();
        // Get the current user's information based on the tokenId
        UserInfo storage user = userInfo[0][msg.sender][_tokenId];
        
        // Call the harvest function on the chef contract with the farmPid and this contract's address
        chef.harvest(farmPid, address(this));

        // this would  be the amount if the user joined right from the start of the farm
        uint256 accumulatedWAVE = (user.amount * pool.accWAVEPerShare) /
            ACC_WAVE_PRECISION;
        // subtracting the rewards the user is not eligible for
        uint256 eligibleWAVE = accumulatedWAVE - user.rewardDebt;

        // we set the new rewardDebt to the current accumulated amount of rewards for his amount of LP token
        user.rewardDebt = accumulatedWAVE;

        // If there are any eligible WAVE rewards, transfer them to the user
        if (eligibleWAVE > 0) {
            safeWAVETransfer(address(msg.sender), eligibleWAVE);
        }

        // Emit an event to log the harvest
        emit Harvest(msg.sender, 0, eligibleWAVE);
    }

    function harvestAndDistributeAnotherToken(uint256 _pid, uint256 _tokenId) public {
        // Get the current pool information for the specified pid
        PoolInfoAnotherToken memory poolAnotherToken = updatePoolAnotherToken(_pid);
        // Get the current user's information for the specified pid and tokenId
        UserInfoAnotherToken storage userAnotherToken = userInfoAnotherToken[0][msg.sender][_tokenId];
    

     //  if (poolAnotherToken.isClosed == false) {
            // Calculate the total accumulated AnotherToken rewards for the user based on their LP token amount
            uint256 accumulatedAnotherToken = (userAnotherToken.amount * poolAnotherToken.accAnotherTokenPerShare) / ACC_ANOTHERTOKEN_PRECISION;
            // Subtract any rewards the user is not eligible for
            uint256 eligibleAnotherToken = accumulatedAnotherToken - userAnotherToken.rewardDebt;

            // Update the user's reward debt to the current accumulated AnotherToken rewards
            userAnotherToken.rewardDebt = accumulatedAnotherToken;

            // If there are any eligible AnotherToken rewards, transfer them to the user
            if (eligibleAnotherToken > 0) {
                safeAnotherTokenTransfer(_pid, address(msg.sender), eligibleAnotherToken);
            }
        
        // Emit an event to log the harvest
        emit HarvestAnotherToken(msg.sender, _pid, eligibleAnotherToken);
   //     }
        
    }
    
     // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid, uint256 _tokenId, address _to) public {
        // Get the current user's information for the specified tokenId
        UserInfo storage user = userInfo[0][msg.sender][_tokenId];
        // Get the current user's information for the specified pid and tokenId
        UserInfoAnotherToken storage userAnotherToken = userInfoAnotherToken[_pid][address(msg.sender)][_tokenId];
        // Get the current user's LP token amount
        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        userAnotherToken.amount = 0;
        userAnotherToken.rewardDebt = 0;
        // Transfer the user's LP token back to them using the IERC721 contract
        IERC721(veWave).safeTransferFrom(address(this), address(msg.sender), _tokenId);

        for (uint i = 0; i < tokenIdsByUser[address(msg.sender)].length; i++) {
        if (tokenIdsByUser[address(msg.sender)][i] == _tokenId) {
            delete tokenIdsByUser[address(msg.sender)][i];
        }
        }

        totalNftsByUser[address(msg.sender)] = totalNftsByUser[address(msg.sender)] - 1;

        // Emit an event to log the emergency withdraw
        emit EmergencyWithdraw(msg.sender, _pid, amount, _to);
    }

    // Add a new pool to the pool. Can only be called by the owner.
    function add(
        // Add a new pool with the specified allocation point and current timestamp to the poolInfo array
        uint256 _allocPoint
    ) public onlyOwner {
        poolInfo.push(
            PoolInfo({
                allocPoint: _allocPoint,
                lastRewardBlock: block.timestamp,
                accWAVEPerShare: 0
            })
        );
        // Emit an event to log the pool addition
        emit LogPoolAddition(
           0,
            _allocPoint
        );
    }

    // Add a new AnotherToken to the pool. Can only be called by the owner.
    function addAnotherToken(
        address _tokenReward,
        uint256 _anotherTokenPerBlock,
        bool _isClosed,
       uint256 _allocPoint
    ) public onlyOwner {
        // Add a new pool with the specified token reward, block reward, closed status, allocation point and current timestamp to the poolInfoAnotherToken array
        poolInfoAnotherToken.push(
            PoolInfoAnotherToken({
                tokenReward: _tokenReward,
                anotherTokenPerBlock: _anotherTokenPerBlock,
                isClosed: _isClosed,
                allocPoint: _allocPoint,
                lastRewardBlock: block.timestamp,
                accAnotherTokenPerShare: 0
            })
        );

        totalPidsAnotherToken++;
        // Emit an event to log the pool addition
        emit LogPoolAnotherTokenAddition(
            totalPidsAnotherToken - 1,
            _tokenReward,
            _isClosed,
            _allocPoint
        );
    }

    function set(
        uint256 _allocPoint,
        bool _isClosed
    ) public onlyOwner {
        // we re-adjust the total allocation points
        poolInfo[0].allocPoint = _allocPoint;
        emit LogSetPool( _allocPoint);
    }

    // Update the given Another Token pool's. Can only be called by the owner.
    function setAnotherToken(
        uint256 _pid,
        address _tokenReward,
        uint256 _allocPoint,
        uint256 _anotherTokenPerBlock,
        bool _isClosed
    ) public onlyOwner {
        // Update the allocation point, token reward, block reward and closed status of the specified AnotherToken pool
        poolInfoAnotherToken[_pid].allocPoint = _allocPoint;
        poolInfoAnotherToken[_pid].tokenReward = _tokenReward;
        poolInfoAnotherToken[_pid].anotherTokenPerBlock = _anotherTokenPerBlock;
        poolInfoAnotherToken[_pid].isClosed = _isClosed;
        // Emit an event to log the pool update
        emit LogSetPoolAnotherToken(_pid, _tokenReward, _isClosed, _allocPoint);
    }

    // Update reward variables of the given WAVE pool to be up-to-date.
    function updatePool() public returns (PoolInfo memory pool) {
         pool = poolInfo[0];
         // Check if it's time to update the rewards based on the current timestamp
         if (block.timestamp > pool.lastRewardBlock) {
            // Only update if there are any LP tokens staked in the pool
            if (totalAmountLockedWave > 0) {
                // Calculate the number of blocks since the last reward update
                uint256 blocksSinceLastReward = block.timestamp -
                    pool.lastRewardBlock;

                // Calculate the total WAVE rewards for the pool based on the number of blocks, WAVE per block, and pool allocation points                
                uint256 waveRewards = (blocksSinceLastReward *
                    wavePerBlock *
                    pool.allocPoint) / 1000;
                // Calculate the WAVE rewards for the pool after taking a percentage for the treasury
                uint256 waveRewardsForPool = (waveRewards * POOL_PERCENTAGE) /
                    1000;
                // Update the accumulated WAVE per LP token based on the new rewards and total staked LP tokens
                pool.accWAVEPerShare =
                    pool.accWAVEPerShare +
                    ((waveRewardsForPool * ACC_WAVE_PRECISION) / totalAmountLockedWave);
            }
            // Update the last reward block timestamp
            pool.lastRewardBlock = block.timestamp;
            poolInfo[0] = pool;

          /*  emit LogUpdatePool(
                0,
                pool.lastRewardBlock,
                totalAmountLockedWave,
                pool.accWAVEPerShare
            ); */
        }
    }

    // View function to see the pending WAVE rewards for a user
    function pendingWave(address _user, uint256 _tokenId)  
        external
        view
        returns (uint256 pending)
    {
       PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[0][_user][_tokenId];
        // Get the accumulated WAVE per LP token
        uint256 accWAVEPerShare = pool.accWAVEPerShare;
        // Only update the rewards if it's time to do so and there are LP tokens staked in the pool

        if (block.timestamp > pool.lastRewardBlock && totalAmountLockedWave != 0) {
            uint256 blocksSinceLastReward = block.timestamp - pool.lastRewardBlock;
            // Calculate the WAVE rewards for the pool based on the number of blocks, WAVE per block, and pool allocation points
            uint256 waveRewards = (blocksSinceLastReward *
                wavePerBlock *
                pool.allocPoint) / 1000;

            // Calculate the WAVE rewards for the pool after taking a percentage for the treasury
            uint256 waveRewardsForPool = (waveRewards * POOL_PERCENTAGE) /
                1000;

            // Update the accumulated WAVE per LP token based on the new rewards and total staked LP tokens
            accWAVEPerShare =
                accWAVEPerShare +
                ((waveRewardsForPool * ACC_WAVE_PRECISION) / totalAmountLockedWave);
        }
        // Calculate the pending WAVE rewards for the user based on their staked LP tokens and subtracting any rewards they are not eligible for or have already claimed
        pending =
            (user.amount * accWAVEPerShare) /
            ACC_WAVE_PRECISION -
            user.rewardDebt;
    }

    // View function to see the pending AnotherToken rewards for a user
    function pendingAnotherToken(uint256 _pid, uint256 _tokenId, address _user)
        external
        view
        returns (uint256 pending)
    {
        PoolInfoAnotherToken storage poolAnotherToken = poolInfoAnotherToken[_pid];
        UserInfoAnotherToken storage userAnotherToken = userInfoAnotherToken[_pid][_user][_tokenId];
        // Get the accumulated AnotherToken per LP token
        uint256 accAnotherTokenPerShare = poolAnotherToken.accAnotherTokenPerShare;
        // Calculate the pending AnotherToken rewards for the user based on their staked LP tokens and subtracting any rewards they are not eligible for or have already claimed
        uint256 anotherTokenSupply = IERC20(poolInfoAnotherToken[_pid].tokenReward).balanceOf(address(this));

        if (block.timestamp > poolAnotherToken.lastRewardBlock && anotherTokenSupply != 0) {
            uint256 blocksSinceLastReward = block.timestamp - poolAnotherToken.lastRewardBlock;
            // based on the pool weight (allocation points) we calculate the anotherToken rewarded for this specific pool
            uint256 anotherTokenRewards = (blocksSinceLastReward + poolAnotherToken.anotherTokenPerBlock * poolAnotherToken.allocPoint) / 1000;
            // we take parts of the rewards for treasury, these can be subject to change, so we recalculate it
            // a value of 1000 = 100%
            uint256 anotherTokenRewardsForPool = (anotherTokenRewards * 1000) /1000;

            // we calculate the new amount of accumulated anotherToken per veWAVE
            accAnotherTokenPerShare =
                accAnotherTokenPerShare +
                ((anotherTokenRewardsForPool * ACC_ANOTHERTOKEN_PRECISION) / anotherTokenSupply);
        }
        // Calculate the pending AnotherToken rewards for the user based on their staked LP tokens and subtracting any rewards they are not eligible for or have already claimed
        pending =
            (userAnotherToken.amount * accAnotherTokenPerShare) /
            ACC_ANOTHERTOKEN_PRECISION -
            userAnotherToken.rewardDebt;
    }

    // Update reward variables of the given anotherToken pool to be up-to-date.
    function updatePoolAnotherToken(uint256 _pid) public returns (PoolInfoAnotherToken memory poolAnotherToken) {
        poolAnotherToken = poolInfoAnotherToken[_pid];

        if (block.timestamp > poolAnotherToken.lastRewardBlock) {
            // total of AnotherTokens staked for this pool
            uint256 anotherTokenSupply = IERC20(poolInfoAnotherToken[_pid].tokenReward).balanceOf(address(this));
            if (anotherTokenSupply > 0) {
                uint256 blocksSinceLastReward = block.timestamp -
                    poolAnotherToken.lastRewardBlock;

                // rewards for this pool based on his allocation points
                uint256 anotherTokenRewards = (blocksSinceLastReward *
                    poolInfoAnotherToken[_pid].anotherTokenPerBlock *
                    1000) / 1000;

                uint256 anotherTokenRewardsForPool = (anotherTokenRewards * 1000) /
                    1000;

                poolAnotherToken.accAnotherTokenPerShare =
                    poolAnotherToken.accAnotherTokenPerShare +
                    ((anotherTokenRewardsForPool * ACC_ANOTHERTOKEN_PRECISION) / anotherTokenSupply);
            }
            poolAnotherToken.lastRewardBlock = block.timestamp;
            poolInfoAnotherToken[_pid] = poolAnotherToken;

            /*emit LogUpdatePool(_pid, poolAnotherToken.lastRewardBlock, anotherTokenSupply, poolAnotherToken.accAnotherTokenPerShare);*/
        }
    }

    // Safe WAVE transfer function, just in case if rounding error causes pool to not have enough WAVE.
    function safeWAVETransfer(address _to, uint256 _amount) internal {
        // Check the balance of WAVE in the pool
        uint256 waveBalance = wave.balanceOf(address(this));
        // If the requested amount is more than the balance, transfer the entire balance
        if (_amount > waveBalance) {
            wave.transfer(_to, waveBalance);
        } else {
            // Otherwise, transfer the requested amount
            wave.transfer(_to, _amount);
        }
    }

    // Safe anotherToken transfer function, just in case if rounding error causes pool to not have enough anotherToken.
    function safeAnotherTokenTransfer(uint256 _pid, address _to, uint256 _amount) internal {
        // Get the specified anotherToken pool
        PoolInfoAnotherToken memory pool = poolInfoAnotherToken[_pid];
        // Check the balance of anotherToken in the pool
        uint256 anotherTokenBalance = IERC20(pool.tokenReward).balanceOf(address(this));
        // If the requested amount is more than the balance, transfer the entire balance
        if (_amount > anotherTokenBalance) {
            IERC20(pool.tokenReward).transfer(_to, anotherTokenBalance);
        } else {
            // Otherwise, transfer the requested amount
            IERC20(pool.tokenReward).transfer(_to, _amount);
        }
    }

    // Update the emission rate of the WAVE token
    function updateEmissionRate(uint256 _wavePerBlock) public onlyOwner {
        // Ensure the emission rate does not exceed the maximum of 6 anothertoken per block
        require(
            _wavePerBlock <= 6e18,
            "maximum emission rate of 6 anothertoken per block exceeded"
        );
        // Update the emission rate
        wavePerBlock = _wavePerBlock;
    }
}
