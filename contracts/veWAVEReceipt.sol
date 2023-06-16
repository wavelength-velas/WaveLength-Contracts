// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract veWAVEReceipt is ERC20("veWAVEReceipt", "veWAVEReceipt"), Ownable {
    /// @notice Creates `_amount` token to `_to`. Must only be called by the owner (EmissionsDistributor).
    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
    }

    function burn(address _from, uint256 _amount) public onlyOwner {
        _burn(_from, _amount);
    }
}
