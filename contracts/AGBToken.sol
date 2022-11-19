// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.9;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

/// AGB Token based on ERC-20 standard
contract AGBToken is ERC20, ERC20Capped, Ownable {
  /// Token name: AlgoBet
  /// Token symbol: AGB
  /// Max cap: 500.000.000 tokens
  constructor() ERC20('AlgoBet', 'AGB') ERC20Capped(500000000*1e18) {
    mint(msg.sender, 500000000*1e18);
  }

  /**
   * @dev See {ERC20-_mint}.
   * Can only be called by the current owner.
   */
  function mint(address _to, uint256 _amount) public onlyOwner {
    _mint(_to, _amount);
  }

  /**
   * @dev See {ERC20Capped-_mint}.
   */
  function _mint(address account, uint256 amount) internal virtual override(ERC20Capped, ERC20) {
    ERC20Capped._mint(account, amount);
  }
}
