// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract WAVEToken is ERC20("WAVEToken", "WAVE"), Ownable {
    uint256 public constant MAX_SUPPLY = 10_000_000e18; // 10 million WAVE

    /// @notice Creates `_amount` token to `_to`. Must only be called by the owner (MasterChef).
    function mint(address _to, uint256 _amount) public onlyOwner {
        require(totalSupply() + _amount <= MAX_SUPPLY, "WAVE::mint: cannot exceed max supply");
        _mint(_to, _amount);
    }
}
