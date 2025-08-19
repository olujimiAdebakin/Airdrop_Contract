// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/**
 * @title MerkleAirdrop
 * @author Adebakin Olujimi
 * @notice This contract allows for a gasless airdrop of ERC20 tokens using Merkle trees.
 * Users can prove their eligibility off-chain and a third party can pay for the gas
 * to submit the transaction.
 *
 * @dev The claiming process is split into two main checks:
 * 1. An EIP-712 signature verification to ensure the claim request is valid and authorized.
 * 2. A Merkle proof verification to confirm the account is on the allowlist.
 *
 * @custom:flow
 * - Deployment: The contract is deployed with a pre-calculated Merkle root and the ERC20 token address.
 * - Claiming: A user calls the `claim` function with a valid Merkle proof and an EIP-712 signature.
 * - Verification: The contract verifies the signature and the Merkle proof.
 * - Transfer: Upon successful verification, tokens are transferred to the user.
 * - Events: An event is emitted for successful claims.
 */
contract MerkleAirdrop is EIP712 {
    using SafeERC20 for IERC20;

    /**
     * @dev Thrown when the provided Merkle proof is invalid.
     */
    error MerkleAirdrop_InvalidProof();
    /**
     * @dev Thrown when an account attempts to claim more than once.
     */
    error MerkleAirdrop_AlreadyClaimed();
    /**
     * @dev Thrown when the provided signature is invalid.
     */
    error MerkleAirdrop_InvalidSignature();

    address[] public airdropRecipients;
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;
    uint256 private i_deployTime;

    mapping(address => bool) private s_hasClaimed;

    bytes32 public constant MESSAGE_TYPEHASH = keccak256("AirdropClaim(address account, uint256 amount)");
    
    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    /**
     * @dev Emitted when an account successfully claims airdrop tokens.
     * @param account The address that claimed the tokens.
     * @param amount The amount of tokens claimed.
     */
    event AirdropClaimed(address indexed account, uint256 amount);

    /**
     * @notice Constructs the MerkleAirdrop contract.
     * @dev Initializes the contract with the Merkle root of the claimable addresses and the ERC20 token.
     * @param merkleRoot The root of the Merkle tree containing the claimable addresses and amounts.
     * @param airdropToken The address of the ERC20 token to be airdropped.
     */
    constructor(bytes32 merkleRoot, IERC20 airdropToken) EIP712("MerkleAirdrop", "1") {
        i_merkleRoot = merkleRoot;
        i_airdropToken = airdropToken;
        i_deployTime = block.timestamp;
    }

    /**
     * @notice Allows an account to claim their airdrop tokens.
     * @dev The function verifies a Merkle proof and an EIP-712 signature before transferring tokens.
     * This is designed to be called by a gas payer, so the message sender (`msg.sender`) is not checked against `account`.
     * @param account The address that is claiming the tokens.
     * @param amount The amount of tokens to claim, as specified in the Merkle tree.
     * @param merkleProof The Merkle proof required to verify the claim.
     * @param v The 'v' component of the ECDSA signature.
     * @param r The 'r' component of the ECDSA signature.
     * @param s The 's' component of the ECDSA signature.
     */
    function claim(address account, uint256 amount, bytes32[] calldata merkleProof, uint8 v, bytes32 r, bytes32 s) external {
        if (!_isValidSignature(account, getMessageHash(account, amount), v, r, s)) {
            revert MerkleAirdrop_InvalidSignature();
        }

        // 1️⃣ Check if the account has already claimed to prevent double-claiming.
        if (s_hasClaimed[account]) {
            revert MerkleAirdrop_AlreadyClaimed();
        }

        // 2️⃣ Verify the Merkle proof to ensure the account is on the allowlist.
        bytes32 leaf = keccak256(abi.encodePacked(account, amount)); // Correct leaf calculation
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop_InvalidProof();
        }

        s_hasClaimed[account] = true;

        // 3️⃣ Transfer tokens to the recipient.
        i_airdropToken.safeTransfer(account, amount);

        // 4️⃣ Store the recipient and emit an event.
        airdropRecipients.push(account);
        emit AirdropClaimed(account, amount);
    }

    /**
     * @notice Gets the unique hash of the claim message for EIP-712 signing.
     * @dev This function is `public view` to allow off-chain applications to prepare the message for signing.
     * @param account The address of the claimer.
     * @param amount The amount of tokens to claim.
     * @return bytes32 The EIP-712 compliant hash of the claim message.
     */
    function getMessageHash(address account, uint256 amount) public view returns (bytes32) {
        return _hashTypedDataV4(
            keccak256(
                abi.encode(
                    MESSAGE_TYPEHASH,
                    account,
                    amount
                )
            )
        );
    }

    /**
     * @notice Gets the address of the airdrop token.
     * @return The address of the IERC20 token.
     */
    function getAirdropToken() external view returns (IERC20) {
        return i_airdropToken;
    }

    /**
     * @notice Gets the Merkle root used for verification.
     * @return bytes32 The Merkle root.
     */
    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    /**
     * @notice Gets the list of addresses that have claimed tokens.
     * @return address[] A dynamic array of addresses.
     */
    function getAirdropRecipients() external view returns (address[] memory) {
        return airdropRecipients;
    }

    /**
     * @notice Gets the time since the contract was deployed.
     * @return uint256 The time in seconds since deployment.
     */
    function getTimeSinceDeployment() external view returns (uint256) {
        return block.timestamp - i_deployTime;
    }

    /**
     * @dev Internal function to verify the EIP-712 signature.
     * @param account The address of the expected signer.
     * @param digest The hash of the signed message.
     * @param v The 'v' component of the signature.
     * @param r The 'r' component of the signature.
     * @param s The 's' component of the signature.
     * @return bool True if the signature is valid and matches the account, otherwise false.
     */
    function _isValidSignature(address account, bytes32 digest, uint8 v, bytes32 r, bytes32 s) internal pure returns (bool) {
        address actualSigner = ECDSA.recover(digest, v, r, s);
        return actualSigner == account;
    }
}
