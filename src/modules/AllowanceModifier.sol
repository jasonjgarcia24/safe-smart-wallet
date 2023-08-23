// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

// 0 = amount, 1 = token, 2 = delegate, 3 = expiration
error InvalidAllowanceParam(uint256 param);

struct Allowance {
    address owner;
    uint64 expiration;
    address delegate;
    uint96 amount;
    address token;
    uint96 spent;
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
