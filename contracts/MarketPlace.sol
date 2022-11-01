// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import '@openzeppelin/contracts/utils/Counters.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import '@openzeppelin/contracts/token/ERC1155/ERC1155.sol';
import '@openzeppelin/contracts/token/ERC1155/IERC1155.sol';

contract NFTMarket is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter public itemIds;
    address payable owner;
    uint256 listingPrice = 0.0025 ether;

    event MarketItemStatus(
        uint256 itemId,
        uint256 price,
        bool isSold,
        bool isCancel
    );

    struct MarketItem {
        uint256 itemId;
        address nftContract;
        uint256 tokenId;
        uint256 amount;
        address payable seller;
        address payable buyer;
        uint256 price;
        bool isSold;
        bool isCanceled;
    }

    //use itemIdToMarketItem[itemId] to get Item
    mapping(uint256 => MarketItem) public idToMarketItem;

    constructor() {
        owner = payable(msg.sender);
    }

    /* Returns the listing price of the contract */
    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    /* Returns the market item by item id */
    function getMarketItem(uint256 itemId)
        public
        view
        returns (MarketItem memory)
    {
        return idToMarketItem[itemId];
    }

    /// @notice Sell nft
    /// @param nftContract id of token
    /// @param tokenId minimum price to make offer
    /// @param amount maximum price to make offer
    /// @param price block that item stops receiving offer
    function sell(
        address nftContract,
        uint256 tokenId,
        uint256 amount,
        uint256 price
    ) public payable nonReentrant {
        require(
            msg.value == listingPrice,
            'Order fee must be equal to listing price'
        );
        uint256 itemId = itemIds.current();

        idToMarketItem[itemId] = MarketItem(
            itemId,
            nftContract,
            tokenId,
            amount,
            payable(msg.sender),
            payable(address(0)),
            price,
            false,
            false
        );

        IERC1155(nftContract).safeTransferFrom(msg.sender, address(this), tokenId, amount, "");

        itemIds.increment();

        emit MarketItemStatus(
            itemId,
            price,
            false,
            false
        );
    }

    /// @notice Buy nft
    /// @param _itemId id of market item
    function buy(uint256 _itemId) public payable nonReentrant {
        require(
            msg.sender != idToMarketItem[_itemId].seller,
            'Asker must not be owner'
        );
        require(!idToMarketItem[_itemId].isSold, 'Item has been sold');
        require(!idToMarketItem[_itemId].isCanceled, 'Item has been cancelled');
        require(
            idToMarketItem[_itemId].price == msg.value,
            'Price must equal to price to buy'
        );

        idToMarketItem[_itemId].buyer = payable(msg.sender);
        idToMarketItem[_itemId].isSold = true;
        idToMarketItem[_itemId].seller.transfer(msg.value);

        IERC1155(idToMarketItem[_itemId].nftContract).safeTransferFrom(address(this), msg.sender, idToMarketItem[_itemId].tokenId, idToMarketItem[_itemId].amount, "");

        payable(owner).transfer(listingPrice);

        emit MarketItemStatus(
            _itemId,
            idToMarketItem[_itemId].price,
            true,
            false
        );
    }

    function cancelMarketItem(uint256 _itemId) public nonReentrant {
        require(
            idToMarketItem[_itemId].seller == msg.sender,
            'Sender must be the seller'
        );
        require(!idToMarketItem[_itemId].isCanceled, 'Item has been cancelled');
        require(
            idToMarketItem[_itemId].buyer == address(0),
            'Item has been sold'
        );
        IERC1155(idToMarketItem[_itemId].nftContract).safeTransferFrom(address(this), msg.sender, idToMarketItem[_itemId].tokenId, idToMarketItem[_itemId].amount, "");
        idToMarketItem[_itemId].isCanceled = true;
        idToMarketItem[_itemId].seller.transfer(listingPrice);

        emit MarketItemStatus(
            _itemId,
            idToMarketItem[_itemId].price,
            false,
            true
        );
    }
}
