// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

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
