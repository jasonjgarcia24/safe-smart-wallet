// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {AllowanceModifier, Allowance, InvalidAllowanceParam} from "./AllowanceModifier.sol";

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
