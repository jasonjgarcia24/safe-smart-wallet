// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

// OpenZeppelin Contracts (last updated v4.9.0) (utils/cryptography/ECDSA.sol)

// OpenZeppelin Contracts (last updated v4.9.0) (utils/Strings.sol)

// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/Math.sol)

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1, "Math: mulDiv overflow");

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result << 3) < value ? 1 : 0);
        }
    }
}

// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/SignedMath.sol)

/**
 * @dev Standard signed math utilities missing in the Solidity language.
 */
library SignedMath {
    /**
     * @dev Returns the largest of two signed numbers.
     */
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two signed numbers.
     */
    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two signed numbers without overflow.
     * The result is rounded towards zero.
     */
    function average(int256 a, int256 b) internal pure returns (int256) {
        // Formula from the book "Hacker's Delight"
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

    /**
     * @dev Returns the absolute unsigned value of a signed value.
     */
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            // must be unchecked in order to support `n = type(int256).min`
            return uint256(n >= 0 ? n : -n);
        }
    }
}

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `int256` to its ASCII `string` decimal representation.
     */
    function toString(int256 value) internal pure returns (string memory) {
        return string(abi.encodePacked(value < 0 ? "-" : "", toString(SignedMath.abs(value))));
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }
}

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV // Deprecated in v4.8
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32 message) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, "\x19Ethereum Signed Message:\n32")
            mstore(0x1c, hash)
            message := keccak256(0x00, 0x3c)
        }
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32 data) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, "\x19\x01")
            mstore(add(ptr, 0x02), domainSeparator)
            mstore(add(ptr, 0x22), structHash)
            data := keccak256(ptr, 0x42)
        }
    }

    /**
     * @dev Returns an Ethereum Signed Data with intended validator, created from a
     * `validator` and `data` according to the version 0 of EIP-191.
     *
     * See {recover}.
     */
    function toDataWithIntendedValidatorHash(address validator, bytes memory data) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x00", validator, data));
    }
}

struct TransferMsgData {
    address safe;
    address token;
    address to;
    uint96 amount;
    address paymentToken;
    uint96 payment;
    uint256 nonce;
}

// keccak256(
//     "EIP712Domain(uint256 chainId,address verifyingContract)"
// );
bytes32 constant DOMAIN_SEPARATOR_TYPEHASH = 0x47e79534a245952e8b16893a336b85a3d9ea9fa8c573f3d803afb92a79469218;

// keccak256(
//     "AllowanceTransfer(address safe,address token,address to,uint96 amount,address paymentToken,uint96 payment,uint256 nonce)"
// );
bytes32 constant ALLOWANCE_TRANSFER_TYPEHASH = 0xfd2d14bb7eac18a8320c374fc2fe8d30d437ab29df02b8cfdd34ff8218fc8cc1;

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
                    ALLOWANCE_TRANSFER_TYPEHASH,
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

interface IAllowanceERC20 {
    event AllowanceSet(
        address indexed safe,
        address indexed delegate,
        address indexed token,
        uint64 expiration,
        uint96 amount
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
        uint64 expiration
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

abstract contract AllowanceMeta {
    string private __name;
    string private __version;

    constructor(string memory _name, string memory _version) {
        __name = _name;
        __version = _version;
    }

    function name() public view returns (string memory) {
        return __name;
    }

    function version() public view returns (string memory) {
        return __version;
    }
}

uint256 constant AMOUNT = 0;
uint256 constant TOKEN = 1;
uint256 constant DELEGATE = 2;
uint256 constant EXPIRATION = 3;

error InvalidAllowanceParam(uint256 param);

struct Allowance {
    address safe;
    uint96 amount;
    address delegate;
    uint96 spent;
    address token;
    uint64 lastReset;
    uint32 resetPeriod;
    uint64 expiration;
    uint192 nonce;
}

library AllowanceModifier {
    modifier onlyValidDelegate(address _delegate) {
        if (_delegate == address(0) || _delegate == msg.sender)
            revert InvalidAllowanceParam(DELEGATE);
        _;
    }

    modifier onlyValidToken(address _token) {
        if (_token == address(0)) revert InvalidAllowanceParam(TOKEN);
        _;
    }

    function getAllowanceKey(
        address _safe,
        address _delegate,
        address _token
    ) public pure returns (bytes32) {
        return keccak256(abi.encode(_safe, _token, _delegate));
    }

    function setAllowance(
        mapping(bytes32 => Allowance) storage _allowances,
        address _delegate,
        address _token,
        uint64 _expiration,
        uint96 _amount
    ) internal onlyValidDelegate(_delegate) onlyValidToken(_token) {
        if (_amount == 0) revert InvalidAllowanceParam(AMOUNT);
        if (_expiration < block.timestamp)
            revert InvalidAllowanceParam(EXPIRATION);

        _setAllowance(
            _allowances,
            msg.sender,
            _delegate,
            _token,
            _expiration,
            _amount
        );
    }

    function updateAllowanceAmount(
        mapping(bytes32 => Allowance) storage _allowances,
        address _delegate,
        address _token,
        uint96 _amount
    ) internal onlyValidDelegate(_delegate) onlyValidToken(_token) {
        _updateAllowanceAmount(
            _allowances,
            msg.sender,
            _delegate,
            _token,
            _amount
        );
    }

    function updateAllowanceExpiration(
        mapping(bytes32 => Allowance) storage _allowances,
        address _delegate,
        address _token,
        uint64 _expiration
    ) internal onlyValidDelegate(_delegate) onlyValidToken(_token) {
        _updateAllowanceExpiration(
            _allowances,
            msg.sender,
            _delegate,
            _token,
            _expiration
        );
    }

    function resetAllowanceSpent(
        mapping(bytes32 => Allowance) storage _allowances,
        address _delegate,
        address _token
    ) internal onlyValidDelegate(_delegate) onlyValidToken(_token) {
        _resetAllowanceSpent(_allowances, msg.sender, _delegate, _token);
    }

    function removeAllowanceDelegate(
        mapping(bytes32 => Allowance) storage _allowances,
        address _token,
        address _delegate
    ) internal onlyValidDelegate(_delegate) onlyValidToken(_token) {
        _removeAllowanceDelegate(_allowances, msg.sender, _delegate, _token);
    }

    function _setAllowance(
        mapping(bytes32 => Allowance) storage _allowances,
        address _safe,
        address _delegate,
        address _token,
        uint64 _expiration,
        uint96 _amount
    ) internal {
        bytes32 _allowanceKey = getAllowanceKey(_safe, _delegate, _token);

        Allowance storage _allowance = _allowances[_allowanceKey];

        _allowance.safe = _safe;
        _allowance.delegate = _delegate;
        _allowance.token = _token;
        _allowance.amount = _amount;
        _allowance.spent = 0;
        _allowance.expiration = _expiration;
    }

    function _updateAllowanceAmount(
        mapping(bytes32 => Allowance) storage _allowances,
        address _safe,
        address _delegate,
        address _token,
        uint96 _amount
    ) internal {
        bytes32 _allowanceKey = getAllowanceKey(_safe, _delegate, _token);

        _allowances[_allowanceKey].amount = _amount;
    }

    function _updateAllowanceExpiration(
        mapping(bytes32 => Allowance) storage _allowances,
        address _safe,
        address _delegate,
        address _token,
        uint64 _expiration
    ) internal {
        bytes32 _allowanceKey = getAllowanceKey(_safe, _delegate, _token);

        _allowances[_allowanceKey].expiration = _expiration;
    }

    function _resetAllowanceSpent(
        mapping(bytes32 => Allowance) storage _allowances,
        address _safe,
        address _delegate,
        address _token
    ) internal {
        bytes32 _allowanceKey = getAllowanceKey(_safe, _delegate, _token);

        _allowances[_allowanceKey].spent = 0;
    }

    function _removeAllowanceDelegate(
        mapping(bytes32 => Allowance) storage _allowances,
        address _safe,
        address _delegate,
        address _token
    ) internal {
        bytes32 _allowanceKey = getAllowanceKey(_safe, _delegate, _token);

        Allowance storage _allowance = _allowances[_allowanceKey];

        _allowance.delegate = address(0);
        _allowance.amount = 0;
        _allowance.spent = 0;
        _allowance.expiration = 0;
    }
}

error InvalidDelegate();
error InsufficientAllowance(address token);

abstract contract AllowanceDatabase {
    // allowanceKey = keccak256(abi.encode(safe, delegate, token))
    mapping(bytes32 allowanceKey => Allowance) internal _allowances;

    modifier onlyDelegate(
        address _safe,
        address _delegate,
        address _token
    ) {
        __verifyDelegate(_safe, _delegate, _token);
        _;
    }

    function checkDelegate(bytes32 _allowanceKey) public view returns (bool) {
        return _allowances[_allowanceKey].delegate == msg.sender;
    }

    function _getAllowanceBalance(
        Allowance memory _allowance
    ) internal pure returns (uint96) {
        return _allowance.amount - _allowance.spent;
    }

    function _spendAllowance(
        address _safe,
        address _token,
        uint96 _amount
    ) internal virtual returns (uint96 _remaining) {
        bytes32 _allowanceKey = AllowanceModifier.getAllowanceKey(
            _safe,
            msg.sender,
            _token
        );

        Allowance storage _allowance = _allowances[_allowanceKey];
        _allowance.spent += _amount;

        if (_allowance.spent > _allowance.amount)
            revert InsufficientAllowance(_token);

        return _getAllowanceBalance(_allowance);
    }

    function __verifyDelegate(
        address _safe,
        address _delegate,
        address _token
    ) private view {
        bytes32 _allowanceKey = AllowanceModifier.getAllowanceKey(
            _safe,
            _delegate,
            _token
        );

        if (!checkDelegate(_allowanceKey)) revert InvalidDelegate();
    }
}

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
        uint64 _expiration,
        uint96 _amount
    ) external {
        _allowances.setAllowance(_delegate, _token, _expiration, _amount);

        emit AllowanceSet(msg.sender, _delegate, _token, _expiration, _amount);
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
        uint64 _expiration
    ) external {
        _allowances.updateAllowanceExpiration(_delegate, _token, _expiration);

        emit AllowanceExpirationUpdated(
            msg.sender,
            _delegate,
            _token,
            _expiration
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

interface IOperations {
    enum Operation {
        Call,
        DelegateCall
    }
}

interface IGnosisSafe {
    /**
     * @dev Allows a Module to execute a Safe transaction without any
     * further confirmations.
     * @param _to destination address of module transaction.
     * @param _value ether value of module transaction.
     * @param _data data payload of module transaction.
     * @param _operation operation type of module transaction.
     */
    function execTransactionFromModule(
        address _to,
        uint256 _value,
        bytes calldata _data,
        IOperations.Operation _operation
    ) external returns (bool success);
}

uint256 constant ETH_TOKEN_TYPE = 0;
uint256 constant ERC20_TOKEN_TYPE = 1;

error TokenTransferFailed(uint256 _type);

contract DelegatedTransferModule is
    IDelegatedTransferModule,
    AllowanceERC20,
    AllowanceNotary
{
    constructor()
        AllowanceERC20("DelegatedTransferModule", "1.0.0")
        AllowanceNotary()
    {}

    function executeTransfer(
        bytes32 _allowanceKey,
        address payable _to,
        uint96 _amount,
        address _paymentToken,
        uint96 _payment,
        bytes memory _signature
    ) public {
        // Get allowance.
        Allowance storage _allowance = _allowances[_allowanceKey];
        if (_allowance.delegate != msg.sender) revert InvalidDelegate();

        // Verify signature.
        _verifySigner(
            TransferMsgData({
                safe: _allowance.safe,
                token: _allowance.token,
                to: _to,
                amount: _amount,
                paymentToken: _paymentToken,
                payment: _payment,
                nonce: _allowance.nonce++
            }),
            _signature
        );

        // Get safe interface.
        IGnosisSafe _safe = IGnosisSafe(_allowance.safe);

        // Transfer payment.
        if (_payment > 0) {
            _spendAllowance(_allowance.safe, _paymentToken, _amount);
            __paymentTransfer(_safe, _paymentToken, _to, _payment);
        }

        // Transfer tokens.
        _spendAllowance(_allowance.safe, _allowance.token, _amount);
        __transfer(_safe, _allowance.token, _to, _amount);
        emit AllowanceTransfer(_allowance.safe, _allowance.token, _to, _amount);
    }

    function __paymentTransfer(
        IGnosisSafe _safe,
        address _paymentToken,
        address payable _to,
        uint96 _payment
    ) private {
        if (_payment > 0) {
            __transfer(_safe, _paymentToken, _to, _payment);

            emit AllowancePaymentTransfer(
                address(_safe),
                _paymentToken,
                _to,
                _payment
            );
        }
    }

    function __transfer(
        IGnosisSafe _safe,
        address _token,
        address payable _to,
        uint96 _amount
    ) private {
        if (_token == address(0)) {
            if (
                !_safe.execTransactionFromModule(
                    _to,
                    _amount,
                    "",
                    IOperations.Operation.Call
                )
            ) revert TokenTransferFailed(ETH_TOKEN_TYPE);
        } else {
            bytes memory _data = abi.encodeWithSignature(
                "transfer(address,uint256)",
                _to,
                _amount
            );
            if (
                !_safe.execTransactionFromModule(
                    _token,
                    0,
                    _data,
                    IOperations.Operation.Call
                )
            ) revert TokenTransferFailed(ERC20_TOKEN_TYPE);
        }
    }
}
