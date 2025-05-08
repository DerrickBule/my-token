// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

// 导入 Foundry 标准测试库
import "forge-std/Test.sol";
// 导入要测试的 Bank 合约
import "../src/Bank.sol";

/**
 * @title BankTest
 * @dev 用于测试 Bank 合约功能的测试合约
 */
contract BankTest is Test {
    // 声明 Bank 合约实例
    Bank public bank;
    // 声明管理员地址
    address public admin;
    // 声明用户地址
    address public user1;
    address public user2;
    address public user3;
    address public user4;

    /**
     * @dev 每个测试用例执行前的初始化函数
     */
    function setUp() public {
        // 将当前测试合约地址设为管理员地址
        admin = address(this);
        // 部署 Bank 合约
        bank = new Bank();
        // 使用 makeAddr 函数创建虚拟用户地址
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        user3 = makeAddr("user3");
        user4 = makeAddr("user4");
    }

    /**
     * @dev 测试存款前后用户余额更新是否正确
     */
    function testDepositUpdatesBalance() public {
        // 定义存款金额为 1 ether
        uint256 depositAmount = 1 ether;
        // 使用 vm.deal 为用户 1 分配指定数量的以太币
        vm.deal(user1, depositAmount);
        // 使用 vm.prank 模拟用户 1 调用合约
        vm.prank(user1);
        // 用户 1 执行存款操作
        bank.deposit{value: depositAmount}();
        // 断言用户 1 在银行的余额等于存款金额
        assertEq(bank.balances(user1), depositAmount);
    }

    /**
     * @dev 测试 1 个用户存款时前三名是否正确
     */
    function testTopThreeWithOneUser() public {
        // 定义存款金额为 1 ether
        uint256 depositAmount = 1 ether;
        // 使用 vm.deal 为用户 1 分配指定数量的以太币
        vm.deal(user1, depositAmount);
        // 使用 vm.prank 模拟用户 1 调用合约
        vm.prank(user1);
        // 用户 1 执行存款操作
        bank.deposit{value: depositAmount}();
        // 断言前三名存款用户列表的第一个元素是用户 1
        assertEq(bank.topThreeDepositors(0), user1);
        // 断言前三名存款用户余额列表的第一个元素等于存款金额
        assertEq(bank.topThreeBalances(0), depositAmount);
    }

    /**
     * @dev 测试 2 个用户存款时前三名是否正确
     */
    function testTopThreeWithTwoUsers() public {
        // 定义用户 1 的存款金额为 1 ether
        uint256 depositAmount1 = 1 ether;
        // 定义用户 2 的存款金额为 2 ether
        uint256 depositAmount2 = 2 ether;
        // 使用 vm.deal 为用户 1 分配指定数量的以太币
        vm.deal(user1, depositAmount1);
        // 使用 vm.prank 模拟用户 1 调用合约
        vm.prank(user1);
        // 用户 1 执行存款操作
        bank.deposit{value: depositAmount1}();
        // 使用 vm.deal 为用户 2 分配指定数量的以太币
        vm.deal(user2, depositAmount2);
        // 使用 vm.prank 模拟用户 2 调用合约
        vm.prank(user2);
        // 用户 2 执行存款操作
        bank.deposit{value: depositAmount2}();
        // 断言前三名存款用户列表的第一个元素是用户 2
        assertEq(bank.topThreeDepositors(0), user2);
        // 断言前三名存款用户余额列表的第一个元素等于用户 2 的存款金额
        assertEq(bank.topThreeBalances(0), depositAmount2);
        // 断言前三名存款用户列表的第二个元素是用户 1
        assertEq(bank.topThreeDepositors(1), user1);
        // 断言前三名存款用户余额列表的第二个元素等于用户 1 的存款金额
        assertEq(bank.topThreeBalances(1), depositAmount1);
    }

    /**
     * @dev 测试 3 个用户存款时前三名是否正确
     */
    function testTopThreeWithThreeUsers() public {
        // 定义用户 1 的存款金额为 1 ether
        uint256 depositAmount1 = 1 ether;
        // 定义用户 2 的存款金额为 2 ether
        uint256 depositAmount2 = 2 ether;
        // 定义用户 3 的存款金额为 3 ether
        uint256 depositAmount3 = 3 ether;
        // 使用 vm.deal 为用户 1 分配指定数量的以太币
        vm.deal(user1, depositAmount1);
        // 使用 vm.prank 模拟用户 1 调用合约
        vm.prank(user1);
        // 用户 1 执行存款操作
        bank.deposit{value: depositAmount1}();
        // 使用 vm.deal 为用户 2 分配指定数量的以太币
        vm.deal(user2, depositAmount2);
        // 使用 vm.prank 模拟用户 2 调用合约
        vm.prank(user2);
        // 用户 2 执行存款操作
        bank.deposit{value: depositAmount2}();
        // 使用 vm.deal 为用户 3 分配指定数量的以太币
        vm.deal(user3, depositAmount3);
        // 使用 vm.prank 模拟用户 3 调用合约
        vm.prank(user3);
        // 用户 3 执行存款操作
        bank.deposit{value: depositAmount3}();
        // 断言前三名存款用户列表的第一个元素是用户 3
        assertEq(bank.topThreeDepositors(0), user3);
        // 断言前三名存款用户余额列表的第一个元素等于用户 3 的存款金额
        assertEq(bank.topThreeBalances(0), depositAmount3);
        // 断言前三名存款用户列表的第二个元素是用户 2
        assertEq(bank.topThreeDepositors(1), user2);
        // 断言前三名存款用户余额列表的第二个元素等于用户 2 的存款金额
        assertEq(bank.topThreeBalances(1), depositAmount2);
        // 断言前三名存款用户列表的第三个元素是用户 1
        assertEq(bank.topThreeDepositors(2), user1);
        // 断言前三名存款用户余额列表的第三个元素等于用户 1 的存款金额
        assertEq(bank.topThreeBalances(2), depositAmount1);
    }

    /**
     * @dev 测试 4 个用户存款时前三名是否正确
     */
    function testTopThreeWithFourUsers() public {
        // 定义用户 1 的存款金额为 1 ether
        uint256 depositAmount1 = 1 ether;
        // 定义用户 2 的存款金额为 2 ether
        uint256 depositAmount2 = 2 ether;
        // 定义用户 3 的存款金额为 3 ether
        uint256 depositAmount3 = 3 ether;
        // 定义用户 4 的存款金额为 4 ether
        uint256 depositAmount4 = 4 ether;
        // 使用 vm.deal 为用户 1 分配指定数量的以太币
        vm.deal(user1, depositAmount1);
        // 使用 vm.prank 模拟用户 1 调用合约
        vm.prank(user1);
        // 用户 1 执行存款操作
        bank.deposit{value: depositAmount1}();
        // 使用 vm.deal 为用户 2 分配指定数量的以太币
        vm.deal(user2, depositAmount2);
        // 使用 vm.prank 模拟用户 2 调用合约
        vm.prank(user2);
        // 用户 2 执行存款操作
        bank.deposit{value: depositAmount2}();
        // 使用 vm.deal 为用户 3 分配指定数量的以太币
        vm.deal(user3, depositAmount3);
        // 使用 vm.prank 模拟用户 3 调用合约
        vm.prank(user3);
        // 用户 3 执行存款操作
        bank.deposit{value: depositAmount3}();
        // 使用 vm.deal 为用户 4 分配指定数量的以太币
        vm.deal(user4, depositAmount4);
        // 使用 vm.prank 模拟用户 4 调用合约
        vm.prank(user4);
        // 用户 4 执行存款操作
        bank.deposit{value: depositAmount4}();
        // 断言前三名存款用户列表的第一个元素是用户 4
        assertEq(bank.topThreeDepositors(0), user4);
        // 断言前三名存款用户余额列表的第一个元素等于用户 4 的存款金额
        assertEq(bank.topThreeBalances(0), depositAmount4);
        // 断言前三名存款用户列表的第二个元素是用户 3
        assertEq(bank.topThreeDepositors(1), user3);
        // 断言前三名存款用户余额列表的第二个元素等于用户 3 的存款金额
        assertEq(bank.topThreeBalances(1), depositAmount3);
        // 断言前三名存款用户列表的第三个元素是用户 2
        assertEq(bank.topThreeDepositors(2), user2);
        // 断言前三名存款用户余额列表的第三个元素等于用户 2 的存款金额
        assertEq(bank.topThreeBalances(2), depositAmount2);
    }

    /**
     * @dev 测试同一个用户多次存款时前三名是否正确
     */
    function testTopThreeWithSameUserMultipleDeposits() public {
        // 定义用户 1 第一次的存款金额为 1 ether
        uint256 depositAmount1 = 1 ether;
        // 定义用户 1 第二次的存款金额为 2 ether
        uint256 depositAmount2 = 2 ether;
        // 使用 vm.deal 为用户 1 分配两次存款所需的以太币
        vm.deal(user1, depositAmount1 + depositAmount2);
        // 使用 vm.prank 模拟用户 1 调用合约
        vm.prank(user1);
        // 用户 1 执行第一次存款操作
        bank.deposit{value: depositAmount1}();
        // 使用 vm.prank 模拟用户 1 调用合约
        vm.prank(user1);
        // 用户 1 执行第二次存款操作
        bank.deposit{value: depositAmount2}();
        // 断言前三名存款用户列表的第一个元素是用户 1
        assertEq(bank.topThreeDepositors(0), user1);
        // 断言前三名存款用户余额列表的第一个元素等于用户 1 两次存款金额之和
        assertEq(bank.topThreeBalances(0), depositAmount1 + depositAmount2);
    }

    /**
     * @dev 测试只有管理员可取款，其他人不可取款
     */
    function testOnlyAdminCanWithdraw() public {
        // 定义存款金额为 1 ether
        uint256 depositAmount = 1 ether;
        // 使用 vm.deal 为管理员分配指定数量的以太币
        vm.deal(admin, depositAmount);
        // 使用 vm.prank 模拟管理员调用合约
        vm.prank(admin);
        // 管理员执行存款操作
        bank.deposit{value: depositAmount}();

        // 使用 vm.prank 模拟用户 1 调用合约
        vm.prank(user1);
        // 使用 vm.expectRevert 期望用户 1 取款时抛出指定错误
        vm.expectRevert("Only admin can withdraw");
        // 用户 1 尝试执行取款操作
        bank.withdraw(1);

        // 使用 vm.prank 模拟管理员调用合约
        vm.prank(admin);
        // 管理员执行取款操作
        bank.withdraw(depositAmount);
        // 断言管理员在银行的余额为 0
        assertEq(bank.balances(admin), 0);
    }
}