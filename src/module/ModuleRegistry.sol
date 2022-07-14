// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity =0.8.13;

/**
 * @title ModuleRegistry
 * @author Haythem Sellami
 */
contract ModuleRegistry {
    error Unauthorized();

    address public owner;

    mapping(address => bool) private _modules;

    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert Unauthorized();
        }

        _;
    }

    function addModule(address _moduleAddr) external onlyOwner {
        _modules[_moduleAddr] = true;
    }

    function removeModule(address _moduleAddr) external onlyOwner {
        _modules[_moduleAddr] = false;
    }

    function isModuleAdded(address _moduleAddr) external view returns (bool) {
        return _modules[_moduleAddr];
    }
}
