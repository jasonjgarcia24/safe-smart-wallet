// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IDelegatedTransferModule {
    event AllowancePaymentTransfer(
        address indexed safe,
        address indexed token,
        address indexed to,
        uint256 amount
    );

    event AllowanceTransfer(
        address indexed safe,
        address indexed token,
        address indexed to,
        uint256 amount
    );
}
