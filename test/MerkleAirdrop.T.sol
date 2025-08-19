// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {AirBucksToken} from "../src/AirBucksToken.sol";
import {ZkSyncChainChecker} from "lib/foundry-devops/src/ZkSyncChainChecker.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol";

/**
 * @title MerkleAirdropTest
 * @author Adebakin OLujimi
 * @notice This test suite verifies the functionality of the MerkleAirdrop contract.
 * @dev The tests cover a successful claim using a valid Merkle proof and signature, and check for
 * invalid proofs, double-claiming, and signature failures.
 *
 * @custom:test-flow
 * 1. `setUp`: Deploys the `MerkleAirdrop` and `AirBucksToken` contracts. It also funds the airdrop contract.
 * 2. `testRecipientCanClaim`: Tests a successful claim by a recipient with a valid proof and signature.
 */
contract MerkleAirdropTest is ZkSyncChainChecker, Test {
    // The MerkleAirdrop contract instance.
    MerkleAirdrop public merkleAirdrop;
    // The AirBucksToken contract instance.
    AirBucksToken public airBucksToken;

    // The root of the Merkle tree used for the airdrop.
    bytes32 public ROOT = 0x92a46fa0e0d41a01edeb47fab747b02eb9c46456edb0d12871fa5a6dd976867d;
    // The amount of tokens to be claimed.
    uint256 public AMOUNT = 25 * 1e18;
    // The Merkle proof for the test recipient.
    bytes32[] public MERKLE_PROOF = [
        bytes32(0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a),
        bytes32(0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576)
    ];

    // The recipient address for the test.
    address recipient = 0x006217c47ffA5Eb3F3c92247ffFE22AD998242c5;
    // The address that will pay for the gas of the claim transaction.
    address gasPayer;
    // The private key of the recipient, used for signing the message.
    uint256 recipientProveKey;

    /**
     * @notice Sets up the test environment before each test function runs.
     * @dev It deploys the necessary contracts using the `DeployMerkleAirdrop` script
     * and initializes test accounts.
     */
    function setUp() public {
        (merkleAirdrop, airBucksToken) = new DeployMerkleAirdrop().deployMerkleAirdrop();
        gasPayer = makeAddr("gasPayer");
        (recipient, recipientProveKey) = makeAddrAndKey("recipient");
    }

    /**
     * @notice Tests a successful token claim by a valid recipient.
     * @dev The test ensures that:
     * 1. The recipient's balance is correctly updated after the claim.
     * 2. The Merkle proof and signature are successfully verified by the contract.
     * 3. The claim transaction is executed by the `gasPayer`.
     */
    function testRecipientCanClaim() public {
        uint256 initialBalance = airBucksToken.balanceOf(recipient);
        console.log("Initial balance:", initialBalance);

        // Get the EIP-712 typed data hash to be signed by the recipient.
        bytes32 digest = merkleAirdrop.getMessageHash(recipient, AMOUNT);

        // Use the recipient's private key to sign the message digest.
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(recipientProveKey, digest);
        console.log("Signature v:", v);
        console.log("Signature r:", r);
        console.log("Signature s:", s);

        // Impersonate the gas payer to simulate a meta-transaction.
        vm.prank(gasPayer);
        
        // Execute the claim.
        merkleAirdrop.claim(recipient, AMOUNT, MERKLE_PROOF, v, r, s);

        // Verify that the recipient's balance has increased by the correct amount.
        uint256 finalBalance = airBucksToken.balanceOf(recipient);
        console.log("Final balance:", finalBalance);

        assertEq(finalBalance, initialBalance + AMOUNT, "Recipient should have received the correct amount of tokens");
    }

    /**
     * @notice Tests that a recipient cannot claim twice.
     * @dev This test calls the claim function a second time and expects it to revert with `MerkleAirdrop_AlreadyClaimed`.
     */
    function testCannotClaimTwice() public {
        bytes32 digest = merkleAirdrop.getMessageHash(recipient, AMOUNT);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(recipientProveKey, digest);

        vm.prank(gasPayer);
        // First, successfully claim the tokens.
        merkleAirdrop.claim(recipient, AMOUNT, MERKLE_PROOF, v, r, s);

        // Then, attempt to claim a second time and expect a revert.
        vm.expectRevert(MerkleAirdrop.MerkleAirdrop_AlreadyClaimed.selector);
        merkleAirdrop.claim(recipient, AMOUNT, MERKLE_PROOF, v, r, s);
    }

    /**
     * @notice Tests that claiming with an invalid Merkle proof reverts.
     * @dev The test uses a different Merkle proof to ensure that the claim fails with the correct error.
     */
    function testCannotClaimWithInvalidProof() public {
        bytes32 digest = merkleAirdrop.getMessageHash(recipient, AMOUNT);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(recipientProveKey, digest);

        // Provide an invalid Merkle proof.
        bytes32[] memory invalidProof = new bytes32[](1);
        invalidProof[0] = keccak256("invalid");

        vm.prank(gasPayer);
        vm.expectRevert(MerkleAirdrop.MerkleAirdrop_InvalidProof.selector);
        merkleAirdrop.claim(recipient, AMOUNT, invalidProof, v, r, s);
    }
}
