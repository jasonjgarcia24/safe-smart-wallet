// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {DOMAIN_SEPARATOR_TYPEHASH, ALLOWANCE_TRANSFER_TYPEHASH} from "./utils/AllowanceNotary.sol";

import {IDelegatedTransferModule} from "./interfaces/IDelegatedTransferModule.sol";
import {AllowanceERC20} from "./AllowanceERC20.sol";
import {IOperations, IGnosisSafe} from "./interfaces/IGnosisSafe.sol";
import {AllowanceModifier, Allowance} from "./utils/AllowanceModifier.sol";
import {AllowanceNotary, TransferMsgData} from "./utils/AllowanceNotary.sol";
import {InvalidDelegate} from "./utils/AllowanceDatabase.sol";

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
