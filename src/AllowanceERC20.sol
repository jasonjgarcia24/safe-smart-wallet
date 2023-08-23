// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IAllowanceERC20} from "./interfaces/IAllowanceERC20.sol";
import {AllowanceMeta} from "./utils/AllowanceMeta.sol";
import {AllowanceDatabase} from "./utils/AllowanceDatabase.sol";
import {AllowanceModifier, Allowance} from "./utils/AllowanceModifier.sol";

error InvalidTokenAmount(uint256 amount);

contract AllowanceERC20 is IAllowanceERC20, AllowanceMeta, AllowanceDatabase {
    using AllowanceModifier for mapping(bytes32 => Allowance);

    constructor(
        string memory _name,
        string memory _version
    ) AllowanceMeta(_name, _version) {}

    function setAllowance(
        address _delegate,
        address _token,
        uint96 _amount,
        uint64 _expiration,
        uint32 _resetPeriod
    ) external {
        _allowances.setAllowance(
            _delegate,
            _token,
            _amount,
            _expiration,
            _resetPeriod
        );

        emit AllowanceSet(
            msg.sender,
            _delegate,
            _token,
            _amount,
            _expiration,
            _resetPeriod
        );
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
        uint64 _expiration,
        uint32 _resetPeriod
    ) external {
        _allowances.updateAllowanceExpiration(
            _delegate,
            _token,
            _expiration,
            _resetPeriod
        );

        emit AllowanceExpirationUpdated(
            msg.sender,
            _delegate,
            _token,
            _expiration,
            _resetPeriod
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

    function getAllowance(
        bytes32 _allowanceKey
    ) public view returns (Allowance memory) {
        return _allowances[_allowanceKey];
    }

    function _spendAllowance(
        address _safe,
        address _token,
        uint96 _amount
    )
        internal
        override
        onlyDelegate(_safe, msg.sender, _token)
        returns (uint96 _remaining)
    {
        if (_amount == 0) revert InvalidTokenAmount(_amount);

        // Validate allowance expiration.
        _allowances.validateExpiration(_safe, msg.sender, _token);

        // Spend allowance.
        _remaining = super._spendAllowance(_safe, _token, _amount);

        emit AllowanceSpentUpdated(
            _safe,
            msg.sender,
            _token,
            _amount,
            _remaining
        );
    }
}
