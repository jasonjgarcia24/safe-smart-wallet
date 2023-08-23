// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {AllowanceModifier, Allowance} from "./AllowanceModifier.sol";

error InvalidDelegate();
error InsufficientAllowance(address token);

abstract contract AllowanceDatabase {
    // allowanceKey = keccak256(abi.encode(safe, delegate, token))
    mapping(bytes32 allowanceKey => Allowance) internal _allowances;

    modifier onlyDelegate(
        address _safe,
        address _delegate,
        address _token
    ) {
        __verifyDelegate(_safe, _delegate, _token);
        _;
    }

    function checkDelegate(bytes32 _allowanceKey) public view returns (bool) {
        return _allowances[_allowanceKey].delegate == msg.sender;
    }

    function _getAllowanceBalance(
        Allowance memory _allowance
    ) internal pure returns (uint96) {
        return _allowance.amount - _allowance.spent;
    }

    function _spendAllowance(
        address _safe,
        address _token,
        uint96 _amount
    ) internal virtual returns (uint96 _remaining) {
        bytes32 _allowanceKey = AllowanceModifier.getAllowanceKey(
            _safe,
            msg.sender,
            _token
        );

        Allowance storage _allowance = _allowances[_allowanceKey];
        _allowance.spent += _amount;

        if (_allowance.spent > _allowance.amount)
            revert InsufficientAllowance(_token);

        return _getAllowanceBalance(_allowance);
    }

    function __verifyDelegate(
        address _safe,
        address _delegate,
        address _token
    ) private view {
        bytes32 _allowanceKey = AllowanceModifier.getAllowanceKey(
            _safe,
            _delegate,
            _token
        );

        if (!checkDelegate(_allowanceKey)) revert InvalidDelegate();
    }
}
