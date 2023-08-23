// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

struct TransferMsgData {
    address safe;
    address token;
    address to;
    uint96 amount;
    address paymentToken;
    uint96 payment;
    uint192 nonce;
}

// keccak256(
//     "EIP712Domain(uint256 chainId,address verifyingContract)"
// );
bytes32 constant DOMAIN_SEPARATOR_TYPEHASH = 0x47e79534a245952e8b16893a336b85a3d9ea9fa8c573f3d803afb92a79469218;

// keccak256(
//     "TransferMsgData(address safe,address token,address to,uint96 amount,address paymentToken,uint96 payment,uint192 nonce)"
// );
bytes32 constant TRANSFER_MSG_DATA_TYPEHASH = 0x0f4999bdd02a26c4ee10acb698cde0de6ee4ba57266b69f4fbb84d8cde62c15c;

error InvalidSigner();
error InvalidSignatureLength();

abstract contract AllowanceNotary {
    uint256 private immutable __chainId;
    bytes32 private immutable __domainSeparator;

    constructor() {
        __chainId = block.chainid;
        __domainSeparator = keccak256(
            abi.encode(DOMAIN_SEPARATOR_TYPEHASH, __chainId, address(this))
        );
    }

    function checkSigner(
        TransferMsgData memory _msgData,
        bytes memory _signature
    ) public view returns (bool) {
        return __recoverSigner(_msgData, _signature) == msg.sender;
    }

    function _verifySigner(
        TransferMsgData memory _msgData,
        bytes memory _signature
    ) internal view {
        if (!checkSigner(_msgData, _signature)) revert InvalidSigner();
    }

    function __recoverSigner(
        TransferMsgData memory _msgData,
        bytes memory _signature
    ) private view returns (address) {
        bytes32 _msgHash = __typedDataHash(_msgData);

        (uint8 v, bytes32 r, bytes32 s) = __splitSignature(_signature);

        return ECDSA.recover(_msgHash, v, r, s);
    }

    function __typedDataHash(
        TransferMsgData memory _msgData
    ) private view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    __domainSeparator,
                    __structHash(_msgData)
                )
            );
    }

    function __structHash(
        TransferMsgData memory _msgData
    ) private pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    TRANSFER_MSG_DATA_TYPEHASH,
                    _msgData.safe,
                    _msgData.token,
                    _msgData.to,
                    _msgData.amount,
                    _msgData.paymentToken,
                    _msgData.payment,
                    _msgData.nonce
                )
            );
    }

    function __splitSignature(
        bytes memory _signature
    ) public pure returns (uint8 v, bytes32 r, bytes32 s) {
        if (_signature.length != 65) revert InvalidSignatureLength();

        assembly {
            r := mload(add(_signature, 0x20))
            s := mload(add(_signature, 0x40))
            v := byte(0, mload(add(_signature, 0x60)))
        }
    }
}
