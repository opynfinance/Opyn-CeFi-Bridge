// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity =0.8.13;

/**
 * @title IModuleRegistry
 * @author Haythem Sellami
 */
interface IModuleRegistry {
    function isModuleAdded(address _moduleAddr) external view returns (bool);
}