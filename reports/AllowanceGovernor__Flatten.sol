// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

bytes32 constant DOMAIN_SEPARATOR_TYPEHASH = 0x47e79534a245952e8b16893a336b85a3d9ea9fa8c573f3d803afb92a79469218;
// keccak256(
//     "EIP712Domain(uint256 chainId,address verifyingContract)"
// );

bytes32 constant ALLOWANCE_TRANSFER_TYPEHASH = 0x97c7ed08d51f4a077f71428543a8a2454799e5f6df78c03ef278be094511eda4;
// keccak256(
//     "AllowanceTransfer(address safe,address token,address to,uint96 amount,address paymentToken,uint96 payment,uint16 nonce)"
// );

interface IAllowanceGovernor {
    event AllowanceSet(
        address indexed owner,
        address indexed delegate,
        address indexed token,
        uint64 expiration,
        uint96 amount
    );

    event AllowanceAmountUpdated(
        address indexed owner,
        address indexed delegate,
        address indexed token,
        uint96 amount
    );

    event AllowanceExpirationUpdated(
        address indexed owner,
        address indexed delegate,
        address indexed token,
        uint64 expiration
    );

    event AllowanceDelegateRemoved(
        address indexed owner,
        address indexed delegate,
        address indexed token
    );

    event AllowanceSpentUpdated(
        address indexed owner,
        address indexed delegate,
        address indexed token,
        uint96 amount,
        uint96 remaining
    );

    function setAllowance(
        address _delegate,
        address _token,
        uint64 _expiration,
        uint96 _amount
    ) external;

    function updateAllowanceAmount(
        address _delegate,
        address _token,
        uint96 _amount
    ) external;

    function updateAllowanceExpiration(
        address _delegate,
        address _token,
        uint64 _expiration
    ) external;

    function removeAllowanceDelegate(
        address _delegate,
        address _token
    ) external;
}

abstract contract AllowanceMeta {
    string private __name;
    string private __version;

    constructor(string memory _name, string memory _version) {
        __name = _name;
        __version = _version;
    }

    function name() public view returns (string memory) {
        return __name;
    }

    function version() public view returns (string memory) {
        return __version;
    }
}

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

// 0 = amount, 1 = token, 2 = delegate, 3 = expiration
error InvalidAllowanceParam(uint256 param);

struct Allowance {
    address owner;
    uint64 expiration;
    address delegate;
    uint96 amount;
    address token;
    uint96 spent;
    IERC20 tokenContract;
}

library AllowanceModifier {
    modifier onlyValidDelegate(address _delegate) {
        if (_delegate == address(0) || _delegate == msg.sender)
            revert InvalidAllowanceParam(2);
        _;
    }

    modifier onlyValidToken(address _token) {
        if (_token == address(0)) revert InvalidAllowanceParam(1);
        _;
    }

    function getAllowanceKey(
        address _owner,
        address _delegate,
        address _token
    ) public pure returns (bytes32) {
        return keccak256(abi.encode(_owner, _token, _delegate));
    }

    function setAllowance(
        mapping(bytes32 => Allowance) storage _allowances,
        address _delegate,
        address _token,
        uint64 _expiration,
        uint96 _amount
    ) internal onlyValidDelegate(_delegate) onlyValidToken(_token) {
        if (_amount == 0) revert InvalidAllowanceParam(0);
        if (_expiration < block.timestamp) revert InvalidAllowanceParam(3);

        _setAllowance(
            _allowances,
            msg.sender,
            _delegate,
            _token,
            _expiration,
            _amount
        );
    }

    function updateAllowanceAmount(
        mapping(bytes32 => Allowance) storage _allowances,
        address _delegate,
        address _token,
        uint96 _amount
    ) internal onlyValidDelegate(_delegate) onlyValidToken(_token) {
        _updateAllowanceAmount(
            _allowances,
            msg.sender,
            _delegate,
            _token,
            _amount
        );
    }

    function updateAllowanceExpiration(
        mapping(bytes32 => Allowance) storage _allowances,
        address _delegate,
        address _token,
        uint64 _expiration
    ) internal onlyValidDelegate(_delegate) onlyValidToken(_token) {
        _updateAllowanceExpiration(
            _allowances,
            msg.sender,
            _delegate,
            _token,
            _expiration
        );
    }

    function resetAllowanceSpent(
        mapping(bytes32 => Allowance) storage _allowances,
        address _delegate,
        address _token
    ) internal onlyValidDelegate(_delegate) onlyValidToken(_token) {
        _resetAllowanceSpent(_allowances, msg.sender, _delegate, _token, 0);
    }

    function removeAllowanceDelegate(
        mapping(bytes32 => Allowance) storage _allowances,
        address _token,
        address _delegate
    ) internal onlyValidDelegate(_delegate) onlyValidToken(_token) {
        _removeAllowanceDelegate(_allowances, msg.sender, _delegate, _token);
    }

    function _setAllowance(
        mapping(bytes32 => Allowance) storage _allowances,
        address _owner,
        address _delegate,
        address _token,
        uint64 _expiration,
        uint96 _amount
    ) internal {
        bytes32 _allowanceKey = getAllowanceKey(_owner, _delegate, _token);

        _allowances[_allowanceKey] = Allowance({
            owner: _owner,
            delegate: _delegate,
            token: _token,
            amount: _amount,
            spent: 0,
            expiration: _expiration
        });
    }

    function _updateAllowanceAmount(
        mapping(bytes32 => Allowance) storage _allowances,
        address _owner,
        address _delegate,
        address _token,
        uint96 _amount
    ) internal {
        bytes32 _allowanceKey = getAllowanceKey(_owner, _delegate, _token);

        _allowances[_allowanceKey].amount = _amount;
    }

    function _updateAllowanceExpiration(
        mapping(bytes32 => Allowance) storage _allowances,
        address _owner,
        address _delegate,
        address _token,
        uint64 _expiration
    ) internal {
        bytes32 _allowanceKey = getAllowanceKey(_owner, _delegate, _token);

        _allowances[_allowanceKey].expiration = _expiration;
    }

    function _resetAllowanceSpent(
        mapping(bytes32 => Allowance) storage _allowances,
        address _owner,
        address _delegate,
        address _token,
        uint96 _spent
    ) internal {
        bytes32 _allowanceKey = getAllowanceKey(_owner, _delegate, _token);

        _allowances[_allowanceKey].spent = _spent;
    }

    function _removeAllowanceDelegate(
        mapping(bytes32 => Allowance) storage _allowances,
        address _owner,
        address _delegate,
        address _token
    ) internal {
        bytes32 _allowanceKey = getAllowanceKey(_owner, _delegate, _token);

        _allowances[_allowanceKey] = Allowance({
            owner: _owner,
            delegate: address(0),
            token: _token,
            amount: 0,
            spent: 0,
            expiration: 0
        });
    }
}

error InsufficientAllowance();

abstract contract AllowanceDatabase {
    // allowanceKey = keccak256(abi.encode(owner, delegate, token))
    mapping(bytes32 allowanceKey => Allowance) internal _allowances;

    modifier onlyDelegate(
        address _owner,
        address _delegate,
        address _token
    ) {
        __verifyDelegate(_owner, _delegate, _token);
        _;
    }

    function spendAllowance(
        address _owner,
        address _token,
        uint96 _amount
    ) external virtual;

    function checkDelegate(bytes32 _allowanceKey) public view returns (bool) {
        return _allowances[_allowanceKey].delegate == msg.sender;
    }

    function _getAllowanceBalance(
        Allowance memory _allowance
    ) internal pure returns (uint96) {
        return _allowance.amount - _allowance.spent;
    }

    function _spendAllowance(
        address _owner,
        address _token,
        uint96 _amount
    ) internal returns (uint96 _remaining) {
        bytes32 _allowanceKey = AllowanceModifier.getAllowanceKey(
            _owner,
            msg.sender,
            _token
        );

        Allowance storage _allowance = _allowances[_allowanceKey];
        _allowance.spent += _amount;

        if (_allowance.spent > _allowance.amount)
            revert InsufficientAllowance();

        return _getAllowanceBalance(_allowance);
    }

    function __verifyDelegate(
        address _owner,
        address _delegate,
        address _token
    ) private view {
        bytes32 _allowanceKey = AllowanceModifier.getAllowanceKey(
            _owner,
            _delegate,
            _token
        );

        if (!checkDelegate(_allowanceKey)) revert InvalidAllowanceParam(2);
    }
}

interface IOperations {
    enum Operation {
        Call,
        DelegateCall
    }
}

interface IGnosisSafe {
    /**
     * @dev Allows a Module to execute a Safe transaction without any
     * further confirmations.
     * @param _to destination address of module transaction.
     * @param _value ether value of module transaction.
     * @param _data data payload of module transaction.
     * @param _operation operation type of module transaction.
     */
    function execTransactionFromModule(
        address _to,
        uint256 _value,
        bytes calldata _data,
        IOperations.Operation _operation
    ) external returns (bool success);
}

contract AllowanceGovernor is
    IAllowanceGovernor,
    AllowanceMeta,
    AllowanceDatabase
{
    using AllowanceModifier for mapping(bytes32 => Allowance);

    constructor(
        string memory _name,
        string memory _version
    ) AllowanceMeta(_name, _version) {}

    function setAllowance(
        address _delegate,
        address _token,
        uint64 _expiration,
        uint96 _amount
    ) external {
        _allowances.setAllowance(_delegate, _token, _expiration, _amount);

        emit AllowanceSet(msg.sender, _delegate, _token, _expiration, _amount);
    }

    function updateAllowanceAmount(
        address _delegate,
        address _token,
        uint96 _amount
    ) external {
        _allowances.updateAllowanceAmount(_delegate, _token, _amount);

        emit AllowanceAmountUpdated(msg.sender, _delegate, _token, _amount);
    }

    function updateAllowanceExpiration(
        address _delegate,
        address _token,
        uint64 _expiration
    ) external {
        _allowances.updateAllowanceExpiration(_delegate, _token, _expiration);

        emit AllowanceExpirationUpdated(
            msg.sender,
            _delegate,
            _token,
            _expiration
        );
    }

    function resetAllowanceSpent(address _delegate, address _token) external {
        _allowances.resetAllowanceSpent(_delegate, _token);

        bytes32 _allowanceKey = AllowanceModifier.getAllowanceKey(
            msg.sender,
            _delegate,
            _token
        );

        emit AllowanceSpentUpdated(
            msg.sender,
            _delegate,
            _token,
            0,
            _getAllowanceBalance(_allowances[_allowanceKey])
        );
    }

    function removeAllowanceDelegate(
        address _delegate,
        address _token
    ) external {
        _allowances.removeAllowanceDelegate(_delegate, _token);

        emit AllowanceDelegateRemoved(msg.sender, _delegate, _token);
    }

    function spendAllowance(
        address _owner,
        address _token,
        uint96 _amount
    ) external override onlyDelegate(_owner, msg.sender, _token) {
        uint96 _remaining = _spendAllowance(_owner, _token, _amount);

        emit AllowanceSpentUpdated(
            _owner,
            msg.sender,
            _token,
            _amount,
            _remaining
        );
    }

    function getAllowance(
        bytes32 _allowanceKey
    ) external view returns (Allowance memory) {
        return _allowances[_allowanceKey];
    }
}
