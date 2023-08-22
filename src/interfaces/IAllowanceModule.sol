// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IAllowanceModule {
    // 0 = amount, 1 = token, 2 = delegate, 3 = expiration
    error InvalidAllowanceParam(uint256 param);
}
