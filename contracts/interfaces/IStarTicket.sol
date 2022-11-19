// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import '@openzeppelin/contracts/token/ERC1155/IERC1155.sol';

interface IStarTicket is IERC1155 {
    function getBonusProfit(uint8 _ticketId) external view returns (uint16);
}