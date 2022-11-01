// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// AGB Token based on ERC-20 standard
contract AGB is ERC20 {
    uint256 private _cap;
    uint256 public allowTransferOn;

    function __AGBToken_init(uint256 allowTransferOn_, address dev_) public initializer{
        _cap = 1000000000e18;
        allowTransferOn = allowTransferOn_; 

        __ERC20_init("AGB Finance", "AGB");
        __ERC20Capped_init(_cap);
        __Ownable_init();
    }

    /**
     * @dev See {ERC20-_mint}.
     * Can only be called by the current owner.
     */
    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
    }

}