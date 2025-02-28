//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract devUSDC is ERC20 {
    address owner;
    uint256 initialSupply;

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner can call this function");
        _;
    }

    constructor(uint256 _initialSupply) ERC20("devUSDC", "dUSDC") {
        owner = msg.sender;
        initialSupply = _initialSupply;
        _mint(msg.sender, _initialSupply);
        approve(msg.sender, initialSupply);
    }
}
