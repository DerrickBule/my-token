// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/TestERC20.sol";

contract DeployTestERC20 is Script {
    function run() external returns (TestERC20) {
        vm.startBroadcast();
        TestERC20 testERC20 = new TestERC20();
        vm.stopBroadcast();
        return testERC20;
    }
}
//forge script script/DeployTestERC20.s.sol:DeployTestERC20 --rpc-url http://127.0.0.1:8545 --broadcast