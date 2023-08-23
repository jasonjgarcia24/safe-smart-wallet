// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

struct Allowance {
    address safe;
    uint96 amount;
    address delegate;
    uint96 spent;
    address token;
    uint64 expiration;
    uint32 resetPeriod;
    uint64 lastReset;
    uint192 nonce;
}

uint256 constant AMOUNT = 0;
uint256 constant TOKEN = 1;
uint256 constant DELEGATE = 2;
uint256 constant EXPIRATION = 3;

error InvalidAllowanceParam(uint256 param);

library AllowanceModifier {
    event ExpirationRolled(
        address safe,
        address delegate,
        address token,
        uint64 newExpiration,
        uint64 oldExpiration,
        uint32 resetPeriod
    );

    modifier onlyValidDelegate(address _delegate) {
        if (_delegate == address(0) || _delegate == msg.sender)
            revert InvalidAllowanceParam(DELEGATE);
        _;
    }

    modifier onlyValidToken(address _token) {
        if (_token == address(0)) revert InvalidAllowanceParam(TOKEN);
        _;
    }

    function getAllowanceKey(
        address _safe,
        address _delegate,
        address _token
    ) public pure returns (bytes32) {
        return keccak256(abi.encode(_safe, _token, _delegate));
    }

    function validateExpiration(
        mapping(bytes32 => Allowance) storage _allowances,
        address _safe,
        address _delegate,
        address _token
    ) internal {
        _validateExpiration(_allowances, _safe, _delegate, _token);
    }

    function setAllowance(
        mapping(bytes32 => Allowance) storage _allowances,
        address _delegate,
        address _token,
        uint96 _amount,
        uint64 _expiration,
        uint32 _resetPeriod
    ) internal onlyValidDelegate(_delegate) onlyValidToken(_token) {
        if (_amount == 0) revert InvalidAllowanceParam(AMOUNT);
        if (_expiration < block.timestamp)
            revert InvalidAllowanceParam(EXPIRATION);

        _setAllowance(
            _allowances,
            msg.sender,
            _delegate,
            _token,
            _amount,
            _expiration,
            _resetPeriod
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
        uint64 _expiration,
        uint32 _resetPeriod
    ) internal onlyValidDelegate(_delegate) onlyValidToken(_token) {
        _updateAllowanceExpiration(
            _allowances,
            msg.sender,
            _delegate,
            _token,
            _expiration,
            _resetPeriod
        );
    }

    function resetAllowanceSpent(
        mapping(bytes32 => Allowance) storage _allowances,
        address _delegate,
        address _token
    ) internal onlyValidDelegate(_delegate) onlyValidToken(_token) {
        _resetAllowanceSpent(_allowances, msg.sender, _delegate, _token);
    }

    function removeAllowanceDelegate(
        mapping(bytes32 => Allowance) storage _allowances,
        address _token,
        address _delegate
    ) internal onlyValidDelegate(_delegate) onlyValidToken(_token) {
        _removeAllowanceDelegate(_allowances, msg.sender, _delegate, _token);
    }

    function _validateExpiration(
        mapping(bytes32 => Allowance) storage _allowances,
        address _safe,
        address _delegate,
        address _token
    ) internal {
        bytes32 _allowanceKey = getAllowanceKey(_safe, _delegate, _token);

        Allowance storage _allowance = _allowances[_allowanceKey];

        // Roll expiration if needed.
        (_allowance.expiration, _allowance.lastReset) = __rollExpiration(
            _allowance
        );

        // Check expiration.
        if (_allowance.expiration < block.timestamp)
            revert InvalidAllowanceParam(EXPIRATION);
    }

    function _setAllowance(
        mapping(bytes32 => Allowance) storage _allowances,
        address _safe,
        address _delegate,
        address _token,
        uint96 _amount,
        uint64 _expiration,
        uint32 _resetPeriod
    ) internal {
        bytes32 _allowanceKey = getAllowanceKey(_safe, _delegate, _token);

        Allowance storage _allowance = _allowances[_allowanceKey];

        _allowance.safe = _safe;
        _allowance.delegate = _delegate;
        _allowance.token = _token;
        _allowance.amount = _amount;
        _allowance.spent = 0;
        _allowance.expiration = _expiration;
        _allowance.resetPeriod = _resetPeriod;
        _allowance.lastReset = uint64(block.timestamp);
    }

    function _updateAllowanceAmount(
        mapping(bytes32 => Allowance) storage _allowances,
        address _safe,
        address _delegate,
        address _token,
        uint96 _amount
    ) internal {
        bytes32 _allowanceKey = getAllowanceKey(_safe, _delegate, _token);

        _allowances[_allowanceKey].amount = _amount;
    }

    function _updateAllowanceExpiration(
        mapping(bytes32 => Allowance) storage _allowances,
        address _safe,
        address _delegate,
        address _token,
        uint64 _expiration,
        uint32 _resetPeriod
    ) internal {
        bytes32 _allowanceKey = getAllowanceKey(_safe, _delegate, _token);

        Allowance storage _allowance = _allowances[_allowanceKey];

        _allowance.expiration = _expiration;
        _allowance.resetPeriod = _resetPeriod;
        _allowance.lastReset = uint64(block.timestamp);
    }

    function _resetAllowanceSpent(
        mapping(bytes32 => Allowance) storage _allowances,
        address _safe,
        address _delegate,
        address _token
    ) internal {
        bytes32 _allowanceKey = getAllowanceKey(_safe, _delegate, _token);

        _allowances[_allowanceKey].spent = 0;
    }

    function _removeAllowanceDelegate(
        mapping(bytes32 => Allowance) storage _allowances,
        address _safe,
        address _delegate,
        address _token
    ) internal {
        bytes32 _allowanceKey = getAllowanceKey(_safe, _delegate, _token);

        Allowance storage _allowance = _allowances[_allowanceKey];

        _allowance.delegate = address(0);
        _allowance.amount = 0;
        _allowance.spent = 0;
        _allowance.expiration = 0;
        _allowance.resetPeriod = 0;
        _allowance.lastReset = uint64(block.timestamp);
    }

    function __rollExpiration(
        Allowance memory _allowance
    ) private returns (uint64 _expiration, uint64 _lastReset) {
        uint64 _now = uint64(block.timestamp);

        if (
            _allowance.resetPeriod != 0 &&
            (_allowance.resetPeriod + _allowance.lastReset) < _now
        ) {
            unchecked {
                // Find the number of periods since last reset.
                uint64 _periods = (_now - _allowance.lastReset) /
                    _allowance.resetPeriod;

                // Update lastReset.
                _lastReset =
                    _allowance.expiration +
                    (_allowance.resetPeriod * _periods);

                // Update expiration.
                _expiration =
                    _allowance.expiration +
                    (_allowance.resetPeriod * (_periods + 1));

                emit ExpirationRolled(
                    _allowance.safe,
                    _allowance.delegate,
                    _allowance.token,
                    _expiration,
                    _allowance.expiration,
                    _allowance.resetPeriod
                );
            }
        } else {
            _lastReset = _allowance.lastReset;
            _expiration = _allowance.expiration;
        }
    }
}
