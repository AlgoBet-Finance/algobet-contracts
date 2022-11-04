// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// AGB Token based on ERC-20 standard
contract USDT is ERC20 {
    constructor() ERC20("USD Tether", "USDT"){}

    function mint(address _to, uint256 _amount) public {
        _mint(_to, _amount);
    }

}