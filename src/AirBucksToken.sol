// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title AirBucksToken
 * @author Olujimi
 * @dev This is an ERC20 token contract that can be minted only by the contract owner.
 * The contract inherits from OpenZeppelin's ERC20 and Ownable contracts.
 */
contract AirBucksToken is ERC20, Ownable {

    /**
     * @notice Constructs the AirBucksToken contract.
     * @dev Initializes the ERC20 token with the name "AirBucks" and symbol "ABUCKS".
     * It also sets the deployer of the contract as the initial owner using the Ownable contract's constructor.
     */
    constructor() ERC20("AirBucks", "ABUCKS") Ownable(msg.sender) {}

    /**
     * @notice Mints new tokens and transfers them to a specified address.
     * @dev This function is restricted to the contract owner via the `onlyOwner` modifier.
     * It uses the internal `_mint` function from the ERC20 standard to create new tokens.
     * @param to The address that will receive the newly minted tokens.
     * @param amount The number of tokens to mint, in the smallest unit (e.g., wei).
     */
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
