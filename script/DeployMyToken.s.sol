// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "../lib/forge-std/src/Script.sol";
import "../src/MyToken.sol";

contract DeployMyToken is Script {
    function run() external returns (MyToken) {
        string memory tokenName = "MyToken";
        string memory tokenSymbol = "MTK";
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        MyToken myToken = new MyToken(tokenName, tokenSymbol);
        vm.stopBroadcast();
        return myToken;
    }
}
