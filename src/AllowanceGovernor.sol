// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {DOMAIN_SEPARATOR_TYPEHASH, ALLOWANCE_TRANSFER_TYPEHASH} from "./modules/AllowanceSignerModule.sol";

import {IAllowanceModule} from "./interfaces/IAllowanceModule.sol";
import {AllowanceMeta} from "./modules/AllowanceMeta.sol";
import {AllowanceDatabase} from "./modules/AllowanceDatabase.sol";
import {IOperations, IGnosisSafe} from "./interfaces/IGnosisSafe.sol";
import {AllowanceModifier, Allowance} from "./modules/AllowanceModifier.sol";

contract AllowanceModule is IAllowanceModule, AllowanceMeta, AllowanceDatabase {
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
    }

    function updateAllowanceAmount(
        address _delegate,
        address _token,
        uint96 _amount
    ) external {
        _allowances.updateAllowanceAmount(_delegate, _token, _amount);
    }

    function updateAllowanceExpiration(
        address _delegate,
        address _token,
        uint64 _expiration
    ) external {
        _allowances.updateAllowanceExpiration(_delegate, _token, _expiration);
    }

    function removeAllowanceDelegate(
        address _delegate,
        address _token
    ) external {
        _allowances.removeAllowanceDelegate(_delegate, _token);
    }

    function getAllowance(
        bytes32 _allowanceKey
    ) external view returns (Allowance memory) {
        return _allowances[_allowanceKey];
    }
}
