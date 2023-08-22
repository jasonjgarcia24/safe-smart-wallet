// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {AllowanceModifier, Allowance, InvalidAllowanceParam} from "./AllowanceModifier.sol";

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

    function checkDelegate(bytes32 _allowanceKey) public view returns (bool) {
        return _allowances[_allowanceKey].delegate == msg.sender;
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
