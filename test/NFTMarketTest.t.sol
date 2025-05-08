// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Test.sol";
import "../src/NFTMarket.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

/**
 * @title MockERC20
 * @dev 模拟 ERC20 代币合约，用于测试
 */
contract MockERC20 is ERC20 {
    constructor() ERC20("MockERC20", "MERC20") {}

    /**
     * @dev 铸造 ERC20 代币到指定地址
     * @param to 接收地址
     * @param amount 铸造数量
     */
    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

/**
 * @title MockERC721
 * @dev 模拟 ERC721 NFT 合约，用于测试
 */
contract MockERC721 is ERC721 {
    constructor() ERC721("MockERC721", "MERC721") {}

    /**
     * @dev 铸造 NFT 到指定地址
     * @param to 接收地址
     * @param tokenId NFT 的 tokenId
     */
    function mint(address to, uint256 tokenId) external {
        _mint(to, tokenId);
    }
}

/**
 * @title NFTMarketTest
 * @dev 测试 NFTMarket 合约的功能
 */
contract NFTMarketTest is Test {
    NFTMarket market;
    MockERC20 erc20;
    MockERC721 nft;
    address seller;
    address buyer;

    /**
     * @dev 测试前置函数，初始化测试环境
     */
    function setUp() public {
        market = new NFTMarket();
        erc20 = new MockERC20();
        nft = new MockERC721();
        seller = makeAddr("seller");
        buyer = makeAddr("buyer");

        vm.deal(seller, 1 ether);
        vm.deal(buyer, 1 ether);
        nft.mint(seller, 1);
        erc20.mint(buyer, 10000 ether);
        vm.prank(buyer);
        erc20.approve(address(market), type(uint256).max);
    }

    /**
     * @dev 测试 NFT 上架成功
     */
    function testListNFT_Success() public {
        vm.prank(seller);
        vm.expectEmit(true, true, true, true);
        emit NFTMarket.NFTListed(address(nft), 1, seller, address(erc20), 100);
        market.listNFT(address(nft), 1, address(erc20), 100);

        (address _seller, address _erc20Token, uint256 _price) = market.listings(address(nft), 1);
        NFTMarket.Listing memory listing = NFTMarket.Listing({
            seller: _seller,
            erc20Token: _erc20Token,
            price: _price
        });
        assertEq(listing.seller, seller);
        assertEq(listing.erc20Token, address(erc20));
        assertEq(listing.price, 100);
    }

    /**
     * @dev 测试非所有者上架失败
     */
    function testListNFT_NotOwner() public {
        vm.prank(buyer);
        vm.expectRevert("Not the owner of the NFT");
        market.listNFT(address(nft), 1, address(erc20), 100);
    }

    /**
     * @dev 测试以价格为 0 上架失败
     */
    function testListNFT_PriceZero() public {
        vm.prank(seller);
        vm.expectRevert("Price must be greater than 0");
        market.listNFT(address(nft), 1, address(erc20), 0);
    }

    /**
     * @dev 测试以 ERC20 地址为 0 上架失败
     */
    function testListNFT_ZeroERC20Address() public {
        vm.prank(seller);
        vm.expectRevert("ERC20 token address cannot be zero");
        market.listNFT(address(nft), 1, address(0), 100);
    }

    /**
     * @dev 测试 NFT 购买成功
     */
    function testBuyNFT_Success() public {
        vm.prank(seller);
        market.listNFT(address(nft), 1, address(erc20), 100);

        vm.prank(buyer);
        vm.expectEmit(true, true, true, true);
        emit NFTMarket.NFTBought(address(nft), 1, buyer, address(erc20), 100);
        market.buyNFT(address(nft), 1);

        assertEq(nft.ownerOf(1), buyer);
        assertEq(erc20.balanceOf(seller), 100);
    }

    /**
     * @dev 测试卖家自己购买失败
     */
    function testBuyNFT_SelfBuy() public {
        vm.prank(seller);
        market.listNFT(address(nft), 1, address(erc20), 100);

        vm.prank(seller);
        vm.expectRevert("ERC20: insufficient allowance");
        market.buyNFT(address(nft), 1);
    }

    /**
     * @dev 测试重复购买失败
     */
    function testBuyNFT_AlreadyBought() public {
        // 模拟卖家调用合约，上架 NFT
        vm.prank(seller);
        market.listNFT(address(nft), 1, address(erc20), 100);

        // 模拟买家调用合约，购买 NFT
        vm.prank(buyer);
        market.buyNFT(address(nft), 1);

        // 模拟买家再次调用合约
        vm.prank(buyer);
        // 期望接下来的操作会抛出 "NFT not listed" 错误
        vm.expectRevert("NFT not listed");
        // 调用 buyNFT 函数尝试再次购买该 NFT
        market.buyNFT(address(nft), 1);
    }
    /**
     * @dev 测试支付不足失败
     */
    function testBuyNFT_InsufficientTokens() public {
        vm.prank(seller);
        market.listNFT(address(nft), 1, address(erc20), 100);

        vm.prank(buyer);
        erc20.approve(address(market), 99);
        vm.expectRevert("ERC20: insufficient allowance");
        market.buyNFT(address(nft), 1);
    }

    /**
     * @dev 模糊测试，随机使用 0.01 - 10000 Token 价格上架 NFT，并随机使用任意地址购买 NFT。
     * @param price 随机生成的 NFT 价格
     */
    function testFuzz_ListAndBuyNFT(uint256 price) public {
        price = bound(price, 0.01 ether, 10000 ether);
        address randomBuyer = makeAddr("randomBuyer");
        vm.deal(randomBuyer, 1 ether);
        erc20.mint(randomBuyer, 10000 ether);
        vm.prank(randomBuyer);
        erc20.approve(address(market), type(uint256).max);

        vm.prank(seller);
        market.listNFT(address(nft), 1, address(erc20), price);

        vm.prank(randomBuyer);
        market.buyNFT(address(nft), 1);

        assertEq(nft.ownerOf(1), randomBuyer);
        assertEq(erc20.balanceOf(seller), price);
    }

    /**
     * @dev 不可变测试，测试无论如何买卖，NFTMarket 合约中都不可能有 Token 持仓。
     */
    function testInvariant_MarketNoTokenBalance() public {
        for (uint256 i = 0; i < 10; i++) {
            uint256 price = bound(i, 0.01 ether, 10000 ether);
            address randomBuyer = makeAddr("randomBuyer");
            vm.deal(randomBuyer, 1 ether);
            erc20.mint(randomBuyer, 10000 ether);
            vm.prank(randomBuyer);
            erc20.approve(address(market), type(uint256).max);

            vm.prank(seller);
            market.listNFT(address(nft), 1, address(erc20), price);

            vm.prank(randomBuyer);
            market.buyNFT(address(nft), 1);
        }

        assertEq(erc20.balanceOf(address(market)), 0);
    }

    /**
     * @dev 测试 NFT 下架成功
     */
    function testDelistNFT_Success() public {
        vm.prank(seller);
        market.listNFT(address(nft), 1, address(erc20), 100);

        vm.prank(seller);
        vm.expectEmit(true, true, true, true);
        emit NFTMarket.NFTDelisted(address(nft), 1, seller);
        market.delistNFT(address(nft), 1);

        (address _seller, address _erc20Token, uint256 _price) = market.listings(address(nft), 1);
        NFTMarket.Listing memory listing = NFTMarket.Listing({
            seller: _seller,
            erc20Token: _erc20Token,
            price: _price
        });
        assertEq(listing.seller, address(0));
    }
}