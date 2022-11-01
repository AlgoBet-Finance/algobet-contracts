// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import '@openzeppelin/contracts/utils/Counters.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import '@openzeppelin/contracts/token/ERC1155/ERC1155.sol';
import './interface/INFT.sol';

contract NFTMarket is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;
    Counters.Counter private _itemsLent;
    Counters.Counter private _isCancelLent;
    Counters.Counter private _itemLendIds;
    Counters.Counter private _itemsCancelled;
    address payable owner;
    uint256 listingPrice = 0.0025 ether;
    //address of erc1155 nft contract
    //address nftContract;

    event MarketItemCreated(
        address nftContract,
        uint256 itemId,
        uint256 tokenId,
        address seller,
        uint256 minPrice,
        uint256 maxPrice,
        uint256 endBlock
    );

    event ItemCanceled(
        address nftContract,
        uint256 itemId,
        uint256 tokenId,
        address sender
    );
    event ItemBuyDirectly(
        address nftContract,
        uint256 itemId,
        uint256 tokenId,
        address sender,
        uint256 currentPrice
    );
    event RetrieveItem(
        address nftContract,
        uint256 itemId,
        uint256 tokenId,
        uint256 blockTime,
        uint256 timestamp,
        address sender
    );
    //store a sell market item of a token
    struct MarketItem {
        address nftContract;
        uint256 itemId;
        uint256 tokenId;
        address payable seller;
        address payable buyer; //buyer
        uint256 minPrice;
        uint256 maxPrice;
        bool sold;
        bool isCanceled;
        Counters.Counter offerCount;
    }
    struct SellHistory {
        uint256 id;
        uint256 itemMarketId;
        uint256 tokenId;
        address payable seller;
        address payable buyer;
        uint256 price;
        uint256 blockNumber;
    }

    //use itemIdToMarketItem[itemId] to get Item
    mapping(uint256 => MarketItem) private idToMarketItem;
    //use itemIdToOffer[itemId][offerId] to get offer
    mapping(uint256 => mapping(uint256 => Offer)) private itemIdToOffer;
    //use tokenSellCount[tokenId] to get how many time token was sold
    mapping(uint256 => Counters.Counter) private tokenSellCount;
    //use tokenIdToSellHistory[tokenId][sellHistoryId] to get sell history
    mapping(uint256 => Counters.Counter) private tokenLendCount;

    mapping(uint256 => LendItem) private lendItems;

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

    /// @notice Make an market item for sell token. Token must be approved first
    /// @param tokenId id of token
    /// @param minPrice minimum price to make offer
    /// @param maxPrice maximum price to make offer
    /// @param endBlock block that item stops receiving offer
    function createMarketItem(
        address nftContract,
        uint256 tokenId,
        uint256 minPrice,
        uint256 maxPrice
    ) public payable nonReentrant {
        require(
            msg.value == listingPrice,
            'Order fee must be equal to listing price'
        );
        require(
            minPrice <= maxPrice,
            'max price must be greater than min price'
        );
        require(minPrice > 0);
        uint256 itemId = _itemIds.current();
        Counters.Counter memory offercount;
        idToMarketItem[itemId] = MarketItem(
            nftContract,
            itemId,
            tokenId,
            payable(msg.sender),
            payable(address(0)),
            minPrice,
            maxPrice,
            0,
            endBlock,
            false,
            false,
            offercount
        );
        IERC1155(nftContract).transferFrom(msg.sender, address(this), tokenId);
        _itemIds.increment();
        emit MarketItemCreated(
            nftContract,
            itemId,
            tokenId,
            msg.sender,
            minPrice,
            maxPrice,
            endBlock
        );
    }

    /// @notice Directly buy an token from market item. value must be set by item maximum price
    /// @param itemId id of market item
    function buyDirectly(uint256 itemId) public payable nonReentrant {
        uint256 currentBlock = block.number;
        uint256 tokenId = idToMarketItem[itemId].tokenId;
        require(
            msg.sender != idToMarketItem[itemId].seller,
            'asker must not be owner'
        );

        require(idToMarketItem[itemId].sold == false, 'item has been sold');
        require(!idToMarketItem[itemId].isCanceled, 'Item has been cancelled');
        require(
            idToMarketItem[itemId].maxPrice == msg.value,
            'Price must equal to max price to buy directly'
        );

        idToMarketItem[itemId].buyer = payable(msg.sender);
        idToMarketItem[itemId].sold = true;
        idToMarketItem[itemId].currentPrice = msg.value;
        uint256 newSellHistoryId = tokenSellCount[tokenId].current();
        _itemsSold.increment();
        SellHistory memory sellHistory = SellHistory(
            newSellHistoryId,
            itemId,
            tokenId,
            idToMarketItem[itemId].seller,
            idToMarketItem[itemId].buyer,
            msg.value,
            currentBlock
        );
        tokenIdToSellHistory[tokenId][newSellHistoryId] = sellHistory;
        tokenSellCount[tokenId].increment();
        idToMarketItem[itemId].seller.transfer(msg.value);
        IERC1155(idToMarketItem[itemId].nftContract).transferFrom(
            address(this),
            msg.sender,
            tokenId
        );
        payable(owner).transfer(listingPrice);
        //idToMarketItem[itemId].seller.transfer(listingPrice);
        emit ItemBuyDirectly(
            idToMarketItem[itemId].nftContract,
            itemId,
            tokenId,
            msg.sender,
            idToMarketItem[itemId].currentPrice
        );
    }

    function cancelMarketItem(uint256 _itemId) public nonReentrant {
        require(
            idToMarketItem[_itemId].seller == msg.sender,
            'sender must be the seller'
        );
        require(!idToMarketItem[_itemId].isCanceled, 'item has been cancelled');
        require(
            idToMarketItem[_itemId].buyer == address(0),
            'item has been sold'
        );
        IERC1155(idToMarketItem[_itemId].nftContract).transferFrom(
            address(this),
            idToMarketItem[_itemId].seller,
            idToMarketItem[_itemId].tokenId
        );
        idToMarketItem[_itemId].isCanceled = true;
        idToMarketItem[_itemId].seller.transfer(listingPrice);
        _itemsCancelled.increment();
        emit ItemCanceled(
            idToMarketItem[_itemId].nftContract,
            _itemId,
            idToMarketItem[_itemId].tokenId,
            msg.sender
        );
    }

    function retrieve(uint256 itemId) public {
        uint256 tokenId = lendItems[itemId].tokenId;
        require(!lendItems[itemId].paid);
        require(block.number >= lendItems[itemId].lendBlockDuration);
        require(msg.sender == lendItems[itemId].lender);
        INFT(lendItems[itemId].nftContract).unlock(tokenId);
        IERC1155(lendItems[itemId].nftContract).transferFrom(
            lendItems[itemId].borrower,
            msg.sender,
            tokenId
        );
        lendItems[itemId].paid = true;
        emit RetrieveItem(
            lendItems[itemId].nftContract,
            itemId,
            tokenId,
            block.number,
            block.timestamp,
            msg.sender
        );
    }
}
