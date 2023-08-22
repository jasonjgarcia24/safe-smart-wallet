// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

bytes32 constant DOMAIN_SEPARATOR_TYPEHASH = 0x47e79534a245952e8b16893a336b85a3d9ea9fa8c573f3d803afb92a79469218;
// keccak256(
//     "EIP712Domain(uint256 chainId,address verifyingContract)"
// );

bytes32 constant ALLOWANCE_TRANSFER_TYPEHASH = 0x97c7ed08d51f4a077f71428543a8a2454799e5f6df78c03ef278be094511eda4;
// keccak256(
//     "AllowanceTransfer(address safe,address token,address to,uint96 amount,address paymentToken,uint96 payment,uint16 nonce)"
// );
