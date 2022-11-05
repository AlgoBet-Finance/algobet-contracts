// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import '@openzeppelin/contracts/token/ERC1155/IERC1155.sol';

interface IStarTicket is IERC1155 {
    function getBonusProfit(address to, uint8 _ticketId) external view returns (uint16);
}