// SPDX-License-Identifier: MIT

pragma solidity 0.8.27;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract KittyToken is ERC20, Ownable {
    constructor() ERC20("KittyToken", "KT") Ownable(msg.sender) {

    }

    function mint(address _to, uint256 _ameownt) external onlyOwner {
        _mint(_to, _ameownt);
    }
}