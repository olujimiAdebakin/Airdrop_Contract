// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

/**
 * @title ClaimAirdrop
 * @author Adebakin Olujimi
 * @notice A Foundry script to execute an airdrop claim on-chain.
 * @dev This script reads the most recently deployed `MerkleAirdrop` contract and calls the `claim` function.
 * The signature and Merkle proof must be generated off-chain for this script to work.
 *
 * @custom:flow
 * 1. The script retrieves the address of the most recently deployed `MerkleAirdrop` contract.
 * 2. It then calls the `claimAirdrop` function to execute the claim.
 * 3. The `claimAirdrop` function broadcasts the transaction, passing the required parameters.
 * 4. The `splitSignature` function is used to convert the hex signature into its `v`, `r`, and `s` components.
 */
contract ClaimAirdrop is Script {

    error ClaimAirdropScript_InvalidSignatureLength();

    // The address for which the claim is being executed.
    address public constant CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    // The amount of tokens to claim, which must match the amount in the Merkle tree.
    uint256 public constant CLAIMING_AMOUNT = 25 * 1e18;
    // The Merkle proof for the CLAIMING_ADDRESS. This must be the correct proof generated off-chain.
    bytes32[] public MERKLE_PROOF = [
        bytes32(0xc365e92ad4696ccdae6ae76aa75277b8c630a5a8b8939775341b9c1cb48e613d),
        bytes32(0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576)
    ];

    // Placeholder for the signature. You MUST replace "0x..." with a valid off-chain signature.
    // The signature must be for the `CLAIMING_ADDRESS` and `CLAIMING_AMOUNT`.
    bytes public SIGNATURE = hex"0x...";

    /**
     * @notice Executes the airdrop claim on the given contract address.
     * @dev This function performs the actual on-chain transaction.
     * @param airdrop The address of the deployed MerkleAirdrop contract.
     */
    function claimAirdrop(address airdrop) public {
        // Deconstruct the signature into its v, r, and s components.
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(SIGNATURE);

        // Start broadcasting the transaction to the network.
        vm.startBroadcast();
        // Call the `claim` function on the MerkleAirdrop contract.
        MerkleAirdrop(airdrop).claim(CLAIMING_ADDRESS, CLAIMING_AMOUNT, MERKLE_PROOF, v, r, s);
        // Stop broadcasting.
        vm.stopBroadcast();
    }

    /**
     * @notice Splits a 65-byte ECDSA signature into its v, r, and s components.
     * @dev This is a common utility function for parsing signatures on-chain.
     * @param sig The 65-byte signature.
     * @return v The recovery ID of the signature.
     * @return r The r component of the signature.
     * @return s The s component of the signature.
     */
    function splitSignature(bytes memory sig) public pure returns (uint8 v, bytes32 r, bytes32 s) {
        if (sig.length != 65) {
            revert ClaimAirdropScript_InvalidSignatureLength();
        }

        assembly {
            // Get the r component (first 32 bytes) of the signature.
            r := mload(add(sig, 32))
            // Get the s component (next 32 bytes).
            s := mload(add(sig, 64))
            // Get the v component (final byte).
            v := byte(0, mload(add(sig, 96)))
        }
        return (v, r, s);
    }

    /**
     * @notice The main entry point for the script.
     * @dev This function retrieves the most recently deployed MerkleAirdrop contract
     * using DevOpsTools and then calls `claimAirdrop`.
     */
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);
        claimAirdrop(mostRecentlyDeployed);
    }
}
