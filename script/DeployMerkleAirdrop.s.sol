// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {AirBucksToken} from "../src/AirBucksToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployMerkleAirdrop is Script {
    bytes32 private s_merkleRoot = 0x92a46fa0e0d41a01edeb47fab747b02eb9c46456edb0d12871fa5a6dd976867d;

    uint256 private s_airBucksAmount = 4 * 100 * 1e18; // 100 AirBucks tokens

    function deployMerkleAirdrop() public returns (MerkleAirdrop, AirBucksToken) {
        vm.startBroadcast();

        AirBucksToken airBucksToken = new AirBucksToken();
        console.log("AirBucksToken deployed at:", address(airBucksToken));

        MerkleAirdrop merkleAirdrop = new MerkleAirdrop(s_merkleRoot, IERC20(address(airBucksToken)));
        console.log("MerkleAirdrop deployed at:", address(merkleAirdrop));

        // Mint to token owner first (just like reference repo)
        airBucksToken.mint(airBucksToken.owner(), s_airBucksAmount);
        console.log("Minted", s_airBucksAmount, "to token owner:", airBucksToken.owner());

        // First approve the transfer (if needed)
        airBucksToken.approve(address(merkleAirdrop), s_airBucksAmount);
        console.log("Approved MerkleAirdrop to spend", s_airBucksAmount, "tokens");

        // Then execute the transfer
        airBucksToken.transfer(address(merkleAirdrop), s_airBucksAmount);
        console.log("Transferred", s_airBucksAmount, "tokens to MerkleAirdrop at:", address(merkleAirdrop));
        vm.stopBroadcast();

        return (merkleAirdrop, airBucksToken);
    }

    function run() external returns (MerkleAirdrop, AirBucksToken) {
        return deployMerkleAirdrop();
    }
}
