// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// USDT based on ERC-20 standard
contract USDT is ERC20 {
    constructor() ERC20("USD Tether", "USDT"){}

    function mint(address _to, uint256 _amount) public {
        _mint(_to, _amount);
    }

}