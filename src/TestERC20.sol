// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract TestERC20 is ERC20 {
    constructor() ERC20("Test Token", "TTK") {
        // 铸造 1000 个代币到合约部署者账户
        _mint(msg.sender, 1000 * 10 ** decimals());
    }
}
