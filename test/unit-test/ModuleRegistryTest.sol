pragma solidity =0.8.13;

// test dependency
import "@std/Test.sol";
// contract
import {ModuleRegistry} from "../../src/module/ModuleRegistry.sol";

contract MockModule {
    /// @dev just a mock
}

contract ModuleRegistryTest is Test {
    ModuleRegistry internal moduleRegistry;

    uint256 internal ownerPrivateKey;
    uint256 internal randomPrivateKey;
    address internal owner;
    address internal random;

    function setUp() public {
        ownerPrivateKey = 0xA11CE;
        randomPrivateKey = 0xA11DE;
        owner = vm.addr(ownerPrivateKey);
        random = vm.addr(randomPrivateKey);

        moduleRegistry = new ModuleRegistry(owner);

        vm.label(owner, "Owner");
        vm.label(address(moduleRegistry), "ModuleRegistry");
    }

    function testAddModule() public {
        address moduleAddr = address(new MockModule());
        _addModule(moduleAddr);
        assertTrue(moduleRegistry.isModuleAdded(moduleAddr) == true);
    }

    function testRemoveModule() public {
        address moduleAddr = address(new MockModule());
        _addModule(moduleAddr);
        _removeModule(moduleAddr);
        assertTrue(moduleRegistry.isModuleAdded(moduleAddr) == false);
    }

    function testUnauthorizedAddModule() public {
        address moduleAddr = address(new MockModule());
        vm.startPrank(random);
        vm.expectRevert(ModuleRegistry.Unauthorized.selector);
        moduleRegistry.addModule(moduleAddr);
        vm.stopPrank();
    }

    function testUnauthorizedRemoveModule() public {
        address moduleAddr = address(new MockModule());
        _addModule(moduleAddr);

        vm.startPrank(random);
        vm.expectRevert(ModuleRegistry.Unauthorized.selector);
        moduleRegistry.removeModule(moduleAddr);
        vm.stopPrank();
    }

    function testFuzzingAddRemoveModule(address _moduleAddr) public {
        _addModule(_moduleAddr);
        _removeModule(_moduleAddr);
    }

    function _addModule(address _add) private {
        vm.startPrank(owner);
        moduleRegistry.addModule(_add);
        vm.stopPrank();
    }

    function _removeModule(address _add) private {
        vm.startPrank(owner);
        moduleRegistry.removeModule(_add);
        vm.stopPrank();
    }
}
