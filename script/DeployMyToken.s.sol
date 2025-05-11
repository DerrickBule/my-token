// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Script.sol";
import "../src/MyToken.sol";

contract DeployMyToken is Script {
    function run() external returns (MyToken) {
        vm.startBroadcast();
        // 定义代币名称和符号
        string memory tokenName = "MyToken";
        string memory tokenSymbol = "MTK";
        // 部署 MyToken 合约
        MyToken myToken = new MyToken(tokenName, tokenSymbol);
        vm.stopBroadcast();
        return myToken;
    }
}
//forge script script/DeployMyToken.s.sol:DeployMyToken \
//--rpc-url http://127.0.0.1:8545 \
//--broadcast \
//--sender 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 \
//--private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80