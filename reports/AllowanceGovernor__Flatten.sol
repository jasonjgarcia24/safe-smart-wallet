/**
 *  SourceUnit: /home/jason/Documents/software/safe-smart-wallet/src/AllowanceGovernor.sol
 */

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity 0.8.20;

// 0 = amount, 1 = token, 2 = delegate, 3 = expiration
error InvalidAllowanceParam(uint256 param);

struct Allowance {
    address owner;
    uint64 expiration;
    address delegate;
    uint96 amount;
    address token;
    uint96 spent;
}

library AllowanceModifier {
    modifier onlyValidDelegate(address _delegate) {
        if (_delegate == address(0) || _delegate == msg.sender)
            revert InvalidAllowanceParam(2);
        _;
    }

    modifier onlyValidToken(address _token) {
        if (_token == address(0)) revert InvalidAllowanceParam(1);
        _;
    }

    function getAllowanceKey(
        address _owner,
        address _delegate,
        address _token
    ) public pure returns (bytes32) {
        return keccak256(abi.encode(_owner, _token, _delegate));
    }

    function setAllowance(
        mapping(bytes32 => Allowance) storage _allowances,
        address _delegate,
        address _token,
        uint64 _expiration,
        uint96 _amount
    ) internal onlyValidDelegate(_delegate) onlyValidToken(_token) {
        if (_amount == 0) revert InvalidAllowanceParam(0);
        if (_expiration < block.timestamp) revert InvalidAllowanceParam(3);

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

    function removeAllowanceDelegate(
        mapping(bytes32 => Allowance) storage _allowances,
        address _token,
        address _delegate
    ) internal onlyValidDelegate(_delegate) onlyValidToken(_token) {
        _removeAllowanceDelegate(_allowances, msg.sender, _delegate, _token);
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

    function _setAllowance(
        mapping(bytes32 => Allowance) storage _allowances,
        address _owner,
        address _delegate,
        address _token,
        uint64 _expiration,
        uint96 _amount
    ) internal {
        bytes32 _allowanceKey = getAllowanceKey(_owner, _delegate, _token);

        _allowances[_allowanceKey] = Allowance(
            _owner,
            _delegate,
            _token,
            _expiration,
            _amount,
            0
        );
    }

    function _updateAllowanceAmount(
        mapping(bytes32 => Allowance) storage _allowances,
        address _owner,
        address _delegate,
        address _token,
        uint96 _amount
    ) internal {
        bytes32 _allowanceKey = getAllowanceKey(_owner, _delegate, _token);

        _allowances[_allowanceKey].amount = _amount;
    }

    function _updateAllowanceExpiration(
        mapping(bytes32 => Allowance) storage _allowances,
        address _owner,
        address _delegate,
        address _token,
        uint64 _expiration
    ) internal {
        bytes32 _allowanceKey = getAllowanceKey(_owner, _delegate, _token);

        _allowances[_allowanceKey].expiration = _expiration;
    }

    function _removeAllowanceDelegate(
        mapping(bytes32 => Allowance) storage _allowances,
        address _owner,
        address _delegate,
        address _token
    ) internal {
        bytes32 _allowanceKey = getAllowanceKey(_owner, _delegate, _token);

        _allowances[_allowanceKey] = Allowance(
            _owner,
            address(0),
            _token,
            0,
            0,
            0
        );
    }
}

/**
 *  SourceUnit: /home/jason/Documents/software/safe-smart-wallet/src/AllowanceGovernor.sol
 */

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
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

/**
 *  SourceUnit: /home/jason/Documents/software/safe-smart-wallet/src/AllowanceGovernor.sol
 */

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity 0.8.20;

////import {AllowanceModifier, Allowance, InvalidAllowanceParam} from "./AllowanceModifier.sol";

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

/**
 *  SourceUnit: /home/jason/Documents/software/safe-smart-wallet/src/AllowanceGovernor.sol
 */

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity 0.8.20;

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

/**
 *  SourceUnit: /home/jason/Documents/software/safe-smart-wallet/src/AllowanceGovernor.sol
 */

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity 0.8.20;

interface IAllowanceModule {
    // 0 = amount, 1 = token, 2 = delegate, 3 = expiration
    error InvalidAllowanceParam(uint256 param);
}

/**
 *  SourceUnit: /home/jason/Documents/software/safe-smart-wallet/src/AllowanceGovernor.sol
 */

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity 0.8.20;

bytes32 constant DOMAIN_SEPARATOR_TYPEHASH = 0x47e79534a245952e8b16893a336b85a3d9ea9fa8c573f3d803afb92a79469218;
// keccak256(
//     "EIP712Domain(uint256 chainId,address verifyingContract)"
// );

bytes32 constant ALLOWANCE_TRANSFER_TYPEHASH = 0x97c7ed08d51f4a077f71428543a8a2454799e5f6df78c03ef278be094511eda4;
// keccak256(
//     "AllowanceTransfer(address safe,address token,address to,uint96 amount,address paymentToken,uint96 payment,uint16 nonce)"
// );

/**
 *  SourceUnit: /home/jason/Documents/software/safe-smart-wallet/src/AllowanceGovernor.sol
 */

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity 0.8.20;

////import {DOMAIN_SEPARATOR_TYPEHASH, ALLOWANCE_TRANSFER_TYPEHASH} from "./modules/AllowanceSignerModule.sol";

////import {IAllowanceModule} from "./interfaces/IAllowanceModule.sol";
////import {AllowanceMeta} from "./modules/AllowanceMeta.sol";
////import {AllowanceDatabase} from "./modules/AllowanceDatabase.sol";
////import {IOperations, IGnosisSafe} from "./interfaces/IGnosisSafe.sol";
////import {AllowanceModifier, Allowance} from "./modules/AllowanceModifier.sol";

contract AllowanceGovernor is
    IAllowanceModule,
    AllowanceMeta,
    AllowanceDatabase
{
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
    }

    function updateAllowanceAmount(
        address _delegate,
        address _token,
        uint96 _amount
    ) external {
        _allowances.updateAllowanceAmount(_delegate, _token, _amount);
    }

    function updateAllowanceExpiration(
        address _delegate,
        address _token,
        uint64 _expiration
    ) external {
        _allowances.updateAllowanceExpiration(_delegate, _token, _expiration);
    }

    function removeAllowanceDelegate(
        address _delegate,
        address _token
    ) external {
        _allowances.removeAllowanceDelegate(_delegate, _token);
    }

    function getAllowance(
        bytes32 _allowanceKey
    ) external view returns (Allowance memory) {
        return _allowances[_allowanceKey];
    }
}
