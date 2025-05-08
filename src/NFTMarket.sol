// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

/**
 * @title NFTMarket
 * @dev 实现一个支持使用 ERC20 代币买卖 NFT 的市场合约
 */
contract NFTMarket is Ownable {
    /**
     * @dev 定义 NFT 列表项结构体
     * @param seller 卖家地址
     * @param erc20Token 支付使用的 ERC20 代币合约地址
     * @param price NFT 价格
     */
    struct Listing {
        address seller;
        address erc20Token;
        uint256 price;
    }

    // 存储 NFT 上架信息，键为 NFT 合约地址和 tokenId
    mapping(address => mapping(uint256 => Listing)) public listings;

    // 定义事件
    event NFTListed(address indexed nftContract, uint256 indexed tokenId, address indexed seller, address erc20Token, uint256 price);
    event NFTBought(address indexed nftContract, uint256 indexed tokenId, address indexed buyer, address erc20Token, uint256 price);
    event NFTDelisted(address indexed nftContract, uint256 indexed tokenId, address indexed seller);

    /**
     * @dev 构造函数，初始化合约所有者为部署者
     */
    constructor() Ownable(msg.sender) {}

    /**
     * @dev 上架 NFT
     * @param nftContract NFT 合约地址
     * @param tokenId NFT 的 tokenId
     * @param erc20Token 支付使用的 ERC20 代币合约地址
     * @param price 设定的 ERC20 价格
     */
    function listNFT(address nftContract, uint256 tokenId, address erc20Token, uint256 price) external {
        IERC721 nft = IERC721(nftContract);
        require(nft.ownerOf(tokenId) == msg.sender, "Not the owner of the NFT");
        require(price > 0, "Price must be greater than 0");
        require(erc20Token != address(0), "ERC20 token address cannot be zero");

        nft.approve(address(this), tokenId);

        listings[nftContract][tokenId] = Listing({
            seller: msg.sender,
            erc20Token: erc20Token,
            price: price
        });

        emit NFTListed(nftContract, tokenId, msg.sender, erc20Token, price);
    }

    /**
     * @dev 购买 NFT
     * @param nftContract NFT 合约地址
     * @param tokenId NFT 的 tokenId
     */
    function buyNFT(address nftContract, uint256 tokenId) external {
        Listing storage listing = listings[nftContract][tokenId];
        require(listing.seller != address(0), "NFT not listed");

        IERC721 nft = IERC721(nftContract);
        IERC20 erc20 = IERC20(listing.erc20Token);

        require(erc20.transferFrom(msg.sender, listing.seller, listing.price), "ERC20 transfer failed");
        nft.safeTransferFrom(listing.seller, msg.sender, tokenId);

        delete listings[nftContract][tokenId];

        emit NFTBought(nftContract, tokenId, msg.sender, listing.erc20Token, listing.price);
    }

    /**
     * @dev 下架 NFT
     * @param nftContract NFT 合约地址
     * @param tokenId NFT 的 tokenId
     */
    function delistNFT(address nftContract, uint256 tokenId) external {
        Listing storage listing = listings[nftContract][tokenId];
        require(listing.seller == msg.sender, "Not the seller");

        delete listings[nftContract][tokenId];

        emit NFTDelisted(nftContract, tokenId, msg.sender);
    }
}