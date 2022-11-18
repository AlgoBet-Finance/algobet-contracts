// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// AGB Token based on ERC-20 standard
contract AGBToken is ERC20, Ownable {
    constructor() ERC20("AlgoBet", "AGB"){}

    /**
     * @dev See {ERC20-_mint}.
     * Can only be called by the current owner.
     */
    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
    }

}