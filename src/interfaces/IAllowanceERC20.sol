// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IAllowanceERC20 {
    event AllowanceSet(
        address indexed safe,
        address indexed delegate,
        address indexed token,
        uint96 amount,
        uint64 expiration,
        uint32 resetPeriod
    );

    event AllowanceAmountUpdated(
        address indexed safe,
        address indexed delegate,
        address indexed token,
        uint96 amount
    );

    event AllowanceExpirationUpdated(
        address indexed safe,
        address indexed delegate,
        address indexed token,
        uint64 expiration,
        uint32 resetPeriod
    );

    event AllowanceDelegateRemoved(
        address indexed safe,
        address indexed delegate,
        address indexed token
    );

    event AllowanceSpentUpdated(
        address indexed safe,
        address indexed delegate,
        address indexed token,
        uint96 amount,
        uint96 remaining
    );

    function setAllowance(
        address _delegate,
        address _token,
        uint96 _amount,
        uint64 _expiration,
        uint32 _resetPeriod
    ) external;

    function updateAllowanceAmount(
        address _delegate,
        address _token,
        uint96 _amount
    ) external;

    function updateAllowanceExpiration(
        address _delegate,
        address _token,
        uint64 _expiration,
        uint32 _resetPeriod
    ) external;

    function removeAllowanceDelegate(
        address _delegate,
        address _token
    ) external;
}
