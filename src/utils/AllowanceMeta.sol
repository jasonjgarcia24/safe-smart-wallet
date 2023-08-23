// SPDX-License-Identifier: MIT
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
