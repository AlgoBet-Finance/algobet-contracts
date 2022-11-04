// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import '@openzeppelin/contracts/token/ERC1155/ERC1155.sol';
import '@openzeppelin/contracts/token/ERC1155/IERC1155.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract StarTicket is ERC1155, Ownable {
    uint8 constant TICKET_1 = 1;
    uint8 constant TICKET_2 = 2;
    uint8 constant TICKET_3 = 3;
    uint8 constant TICKET_4 = 4;
    uint8 constant TICKET_5 = 5;
    uint8 constant TICKET_6 = 6;

    mapping(uint8 => uint16) bonusProfit;

    constructor(string memory _uri) ERC1155(_uri) {
        bonusProfit[TICKET_1] = 3; // 3/100 = 3%
        bonusProfit[TICKET_2] = 5; // 5/100 = 5%
        bonusProfit[TICKET_3] = 10; // 10/100 = 10%
        bonusProfit[TICKET_4] = 15; // 15/100 = 15%
        bonusProfit[TICKET_5] = 20; // 20/100 = 20%
        bonusProfit[TICKET_6] = 0; // random 20<x<=50
    }

    function mint(
        address _to,
        uint256 _tokenId,
        uint256 _amount,
        bytes memory _data
    ) public onlyOwner {
        _mint(_to, _tokenId, _amount, _data);
    }

    function getBonusProfit(uint8 _ticketId) public view returns (uint16) {
        require(
            balanceOf(msg.sender, _ticketId) > 0,
            'User do not have this ticket'
        );
        uint16 bonus = bonusProfit[_ticketId];
        if (bonus == bonusProfit[TICKET_6]) {
            bonus = random();
        }
        return bonus;
    }

    function random() private view returns (uint16) {
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, block.number, block.coinbase)));
        uint16 firstFandom = uint16(randomNumber % 50);
        if (firstFandom < 20) {
            return uint16(firstFandom + (randomNumber % 20));
        }
        return firstFandom;
    }
}
