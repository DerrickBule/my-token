// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/TokenBank.sol";

contract DeployTokenBank is Script {
    function run() external returns (TokenBank) {
        // 加载私钥，可通过环境变量设置
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // 部署 TokenBank 合约
        TokenBank tokenBank = new TokenBank();

        vm.stopBroadcast();
        return tokenBank;
    }
}
