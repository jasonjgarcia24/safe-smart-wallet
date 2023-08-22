// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

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
