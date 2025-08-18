// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract MerkleAirdrop is EIP712 {
    // This contract is intentionally left empty as a placeholder for future implementation.
    // It can be used to manage Merkle tree-based airdrops in the future.
    using SafeERC20 for IERC20;

    error MerkleAirdrop_InvalidProof();
    error MerkleAirdrop_AlreadyClaimed();
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

    event AirdropClaimed(address indexed account, uint256 amount);

    constructor(bytes32 merkleRoot, IERC20 airdropToken)EIP712("MerkleAirdrop", "1") {
        i_merkleRoot = merkleRoot;
        i_airdropToken = airdropToken;
        i_deployTime = block.timestamp;
    }

    function claim(address account, uint256 amount, bytes32[] calldata merkleProof, uint8 v, bytes32 r, bytes32 s) external {

        if (!_isValidSignature(account, getMessageHash(account, amount), v, r, s)) {
            revert MerkleAirdrop_InvalidSignature();
        }
        // 1️⃣ Check proof
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop_InvalidProof();
        }

        // 2️⃣ Prevent multiple claims
        if (s_hasClaimed[account]) {
            revert MerkleAirdrop_AlreadyClaimed();
        }

        s_hasClaimed[account] = true;

        // 3️⃣ Transfer tokens safely
        i_airdropToken.safeTransfer(account, amount);

        // 4️⃣ Store recipient & emit event
        airdropRecipients.push(account);
        emit AirdropClaimed(account, amount);
    }

    function _isValidSignature(address account, bytes32 digest, uint8 v, bytes32 r, bytes32 s) internal pure returns (bool) {
        (address actualSigner, ,) = ECDSA.tryRecover(digest, v, r, s);
        return actualSigner == account;
    }

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


    function getAirdropToken() external view returns (IERC20) {
        return i_airdropToken;
    }

    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    function getAirdropRecipients() external view returns (address[] memory) {
        return airdropRecipients;
    }

    function getTimeSinceDeployment() external view returns (uint256) {
        return block.timestamp - i_deployTime;
    }
}
