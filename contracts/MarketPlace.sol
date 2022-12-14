// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import '@openzeppelin/contracts/utils/Counters.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import '@openzeppelin/contracts/token/ERC1155/ERC1155.sol';
import '@openzeppelin/contracts/token/ERC1155/IERC1155.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol';

contract MarketPlace is ReentrancyGuard, ERC1155Holder {
    using Counters for Counters.Counter;
    Counters.Counter public itemIds;
    address public agbToken;

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

    constructor(address _agbToken) {
        agbToken = _agbToken;
    }

    /// @notice Sell nft
    /// @param nftContract nft contact for sell
    /// @param tokenId nft token id for sell
    /// @param amount amount sell
    /// @param price price sell
    function sell(
        address nftContract,
        uint256 tokenId,
        uint256 amount,
        uint256 price
    ) public nonReentrant {
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
        IERC1155(nftContract).safeTransferFrom(
            msg.sender,
            address(this),
            tokenId,
            amount,
            ''
        );
        itemIds.increment();
        emit MarketItemStatus(itemId, price, false, false);
    }

    /// @notice Buy nft
    /// @param _itemId id of market item
    function buy(uint256 _itemId) public nonReentrant {
        require(!idToMarketItem[_itemId].isSold, 'Item has been sold');
        require(!idToMarketItem[_itemId].isCanceled, 'Item has been cancelled');
        require(idToMarketItem[_itemId].seller != msg.sender, 'Buyer is invalid');
        IERC20(agbToken).transferFrom(
            msg.sender,
            idToMarketItem[_itemId].seller,
            idToMarketItem[_itemId].price
        );
        IERC1155(idToMarketItem[_itemId].nftContract).safeTransferFrom(
            address(this),
            msg.sender,
            idToMarketItem[_itemId].tokenId,
            idToMarketItem[_itemId].amount,
            ''
        );
        idToMarketItem[_itemId].buyer = payable(msg.sender);
        idToMarketItem[_itemId].isSold = true;
        emit MarketItemStatus(
            _itemId,
            idToMarketItem[_itemId].price,
            true,
            false
        );
    }

    function cancel(uint256 _itemId) public nonReentrant {
        require(
            idToMarketItem[_itemId].seller == msg.sender,
            'Sender must be the seller'
        );
        require(!idToMarketItem[_itemId].isCanceled, 'Item has been cancelled');
        require(
            idToMarketItem[_itemId].buyer == address(0),
            'Item has been sold'
        );
        idToMarketItem[_itemId].isCanceled = true;
        IERC1155(idToMarketItem[_itemId].nftContract).safeTransferFrom(
            address(this),
            msg.sender,
            idToMarketItem[_itemId].tokenId,
            idToMarketItem[_itemId].amount,
            ''
        );
        emit MarketItemStatus(
            _itemId,
            idToMarketItem[_itemId].price,
            false,
            true
        );
    }
}
