// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract Bank {
    // 记录每个用户的余额
    mapping(address => uint256) public balances;
    // 存储前三名用户地址
    address[3] public topThreeDepositors;
    // 存储前三名用户余额
    uint256[3] public topThreeBalances;

    // 存款事件
    event Deposit(address indexed account, uint256 amount);
    // 取款事件
    event Withdraw(address indexed account, uint256 amount);

    /// @dev 更新前三名存款用户的函数
    function updateTopThree() internal {
        address currentUser = msg.sender;
        uint256 currentBalance = balances[currentUser];

        // 标记当前用户是否已在前三名中
        bool isInTopThree = false;
        for (uint256 i = 0; i < 3; i++) {
            if (topThreeDepositors[i] == currentUser) {
                topThreeBalances[i] = currentBalance;
                isInTopThree = true;
                break;
            }
        }

        // 如果当前用户不在前三名中，尝试插入
        if (!isInTopThree) {
            for (uint256 i = 0; i < 3; i++) {
                if (currentBalance > topThreeBalances[i]) {
                    // 将后面的元素依次后移
                    for (uint256 j = 2; j > i; j--) {
                        topThreeDepositors[j] = topThreeDepositors[j - 1];
                        topThreeBalances[j] = topThreeBalances[j - 1];
                    }
                    topThreeDepositors[i] = currentUser;
                    topThreeBalances[i] = currentBalance;
                    break;
                }
            }
        }

        // 重新排序
        for (uint256 i = 0; i < 2; i++) {
            for (uint256 j = i + 1; j < 3; j++) {
                if (topThreeBalances[i] < topThreeBalances[j]) {
                    // 交换地址
                    address tempAddr = topThreeDepositors[i];
                    topThreeDepositors[i] = topThreeDepositors[j];
                    topThreeDepositors[j] = tempAddr;
                    // 交换余额
                    uint256 tempBal = topThreeBalances[i];
                    topThreeBalances[i] = topThreeBalances[j];
                    topThreeBalances[j] = tempBal;
                }
            }
        }
    }

    /// @dev 存款函数，用户可以向银行存入以太币
    function deposit() external payable {
        // 更新用户余额
        balances[msg.sender] += msg.value;
        // 更新前三名存款用户
        updateTopThree();
        // 触发存款事件
        emit Deposit(msg.sender, msg.value);
    }

    /// @dev 取款函数，用户可以从银行取出指定数量的以太币
    /// @param amount 要取出的以太币数量
    function withdraw(uint256 amount) external {
        // 检查用户余额是否足够
        require(balances[msg.sender] >= amount, "Insufficient balance");
        // 更新用户余额
        balances[msg.sender] -= amount;
        // 更新前三名存款用户
        updateTopThree();
        // 发送以太币给用户
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");
        // 触发取款事件
        emit Withdraw(msg.sender, amount);
    }

    /// @dev 查询用户余额的函数
    /// @return 用户的当前余额
    function getBalance() external view returns (uint256) {
        return balances[msg.sender];
    }
}