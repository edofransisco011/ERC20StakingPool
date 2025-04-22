// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/access/Ownable.sol";

/**
 * @title MyToken
 * @dev Basic ERC20 token with Ownable minting function.
 */
contract MyToken is ERC20, Ownable {
    constructor(string memory _name, string memory _symbol, address initialOwner)
        ERC20(_name, _symbol)
        Ownable(initialOwner)
    {}

    /**
     * @notice Allows the owner to mint new tokens.
     * @param to The address to mint tokens to.
     * @param amount The amount of tokens to mint (in wei).
     */
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}