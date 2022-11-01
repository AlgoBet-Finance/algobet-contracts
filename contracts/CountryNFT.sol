// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import '@openzeppelin/contracts/token/ERC1155/ERC1155.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract CountryNFT is ERC1155, Ownable {
    constructor(string memory _uri) ERC1155(_uri) {}

    function mint(address _to, uint256 _tokenId, uint256 _amount, bytes memory _data) public onlyOwner {
        _mint(_to, _tokenId, _amount, _data);
    }
}
