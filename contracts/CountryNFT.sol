// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import '@openzeppelin/contracts/token/ERC1155/ERC1155.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract CountryNFT is ERC1155, Ownable {
    // Group A
    uint8 constant QATAR = 0;
    uint8 constant ECUADOR = 1;
    uint8 constant SENEGAL = 2;
    uint8 constant NETHERLANDS = 3;
    // Group B
    uint8 constant ENGLAND = 4;
    uint8 constant IRAN = 5;
    uint8 constant UNITED_STATES = 6;
    uint8 constant WALES = 7;
    // Group C
    uint8 constant ARGENTINA = 8;
    uint8 constant SAUDI_ARABIA = 9;
    uint8 constant MEXICO = 10;
    uint8 constant POLAND = 11;
    // Group D
    uint8 constant FRANCE = 12;
    uint8 constant AUSTRALIA = 13;
    uint8 constant DENMARK = 14;
    uint8 constant TUNISIA = 15;
    // Group E
    uint8 constant SPAIN = 16;
    uint8 constant COSTA_RICA = 17;
    uint8 constant GERMANY = 18;
    uint8 constant JAPAN = 19;
    // Group F
    uint8 constant BELGIUM = 20;
    uint8 constant CANADA = 21;
    uint8 constant MOROCCO = 22;
    uint8 constant CROATIA = 23;
    // Group G
    uint8 constant BRAZIL = 24;
    uint8 constant SERBIA = 25;
    uint8 constant SWITZERLAND = 26;
    uint8 constant CAMEROON = 27;
    // Group H
    uint8 constant PORTUGAL = 28;
    uint8 constant GHANA = 29;
    uint8 constant URUGUAY = 30;
    uint8 constant SOUTH_KOREA = 31;

    uint256 constant USDTDecimal = 10**18;
    address usdtToken;

    address treasury;

    constructor(
        string memory _uri,
        address _usdtToken,
        address _treasury
    ) ERC1155(_uri) {
        usdtToken = _usdtToken;
        treasury = _treasury;
    }

    function mint(
        address _to,
        uint256 _tokenId,
        uint256 _amount,
        bytes memory _data
    ) public onlyOwner {
        _mint(_to, _tokenId, _amount, _data);
    }

    function mintCountryNft(uint8 _countryId, uint256 _USDTAmount) public {
        require(_countryId < 32, 'Country id is invalid');
        uint256 nftAmount = _USDTAmount / USDTDecimal;
        require(nftAmount > 0, "USDT amount is invalid");
        _mint(msg.sender, _countryId, nftAmount, "");
        IERC20(usdtToken).transferFrom(msg.sender, treasury, _USDTAmount);
    }

    function burnCountryNft(uint8 _countryId, uint256 _nftAmount) public {
        require(_countryId < 32, 'Country id is invalid');
        require(balanceOf(msg.sender, _countryId) >= _nftAmount, "You do not have enough nft");
        _burn(msg.sender, _countryId, _nftAmount);
        IERC20(usdtToken).transferFrom(treasury, msg.sender, _nftAmount * USDTDecimal);
    }
}
