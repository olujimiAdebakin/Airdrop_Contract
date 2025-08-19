// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {AirBucksToken} from "../src/AirBucksToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title DeployMerkleAirdrop
 * @author Adebakin OLujimi
 * @notice This script deploys the MerkleAirdrop and AirBucksToken contracts and funds the airdrop contract.
 * @dev The script uses Foundry's `vm` cheatcodes for broadcasting transactions. It first deploys the token,
 * then the airdrop contract, and finally mints and transfers the tokens to the airdrop contract.
 *
 * @custom:flow
 * 1. Deploy the `AirBucksToken` contract.
 * 2. Deploy the `MerkleAirdrop` contract, passing the Merkle root and the token address.
 * 3. Mint the specified amount of tokens to the token contract's owner.
 * 4. Approve the `MerkleAirdrop` contract to spend the tokens.
 * 5. Transfer the tokens to the `MerkleAirdrop` contract.
 */
contract DeployMerkleAirdrop is Script {
    // The pre-calculated Merkle root from the off-chain script.
    bytes32 private s_merkleRoot = 0x92a46fa0e0d41a01edeb47fab747b02eb9c46456edb0d12871fa5a6dd976867d;

    // The total amount of AirBucks tokens to be airdropped.
    uint256 private s_airBucksAmount = 4 * 25 * 1e18; // Corrected amount: 4 recipients * 25 tokens each

    /**
     * @notice Deploys the MerkleAirdrop and AirBucksToken contracts.
     * @dev This function handles the entire deployment process, including token transfer to the airdrop contract.
     * It uses `vm.startBroadcast()` and `vm.stopBroadcast()` to sign and send transactions.
     * @return A tuple containing the deployed MerkleAirdrop and AirBucksToken contract instances.
     */
    function deployMerkleAirdrop() public returns (MerkleAirdrop, AirBucksToken) {
        vm.startBroadcast();

        // Deploy the ERC20 token contract.
        AirBucksToken airBucksToken = new AirBucksToken();
        console.log("AirBucksToken deployed at:", address(airBucksToken));

        // Deploy the MerkleAirdrop contract with the pre-calculated root and the token.
        MerkleAirdrop merkleAirdrop = new MerkleAirdrop(s_merkleRoot, IERC20(address(airBucksToken)));
        console.log("MerkleAirdrop deployed at:", address(merkleAirdrop));

        // Mint the total airdrop amount to the token contract owner.
        airBucksToken.mint(airBucksToken.owner(), s_airBucksAmount);
        console.log("Minted", s_airBucksAmount, "to token owner:", airBucksToken.owner());

        // Approve the MerkleAirdrop contract to spend the minted tokens.
        airBucksToken.approve(address(merkleAirdrop), s_airBucksAmount);
        console.log("Approved MerkleAirdrop to spend", s_airBucksAmount, "tokens");

        // Transfer the airdrop amount from the owner to the airdrop contract.
        airBucksToken.transfer(address(merkleAirdrop), s_airBucksAmount);
        console.log("Transferred", s_airBucksAmount, "tokens to MerkleAirdrop at:", address(merkleAirdrop));
        vm.stopBroadcast();

        return (merkleAirdrop, airBucksToken);
    }

    /**
     * @notice The main entry point for the script.
     * @dev It simply calls the `deployMerkleAirdrop` function to execute the deployment.
     * @return A tuple containing the deployed contract instances.
     */
    function run() external returns (MerkleAirdrop, AirBucksToken) {
        return deployMerkleAirdrop();
    }
}
