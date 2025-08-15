

// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;


import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";



contract MerkleAirdrop {
    // This contract is intentionally left empty as a placeholder for future implementation.
    // It can be used to manage Merkle tree-based airdrops in the future.
    using SafeERC20 for IERC20;

    error MerkleAirdrop_InvalidProof();
      error MerkleAirdrop_AlreadyClaimed();

    address[] public airdropRecipients;
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;
   uint256 private i_deployTime;

     mapping(address => bool) private s_hasClaimed;

    event AirdropClaimed(address indexed account, uint256 amount);
    
    constructor(bytes32 merkleRoot, IERC20 airdropToken){
            i_merkleRoot = merkleRoot;
            i_airdropToken = airdropToken;
            i_deployTime = block.timestamp;
    }

    function claim(address account, uint256 amount, bytes32[] calldata merkleProof) external {
 
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


      function getAirdropToken() external view returns (IERC20) {
            return i_airdropToken;
      }

      function getMerkleRoot() external view returns (bytes32) {
            return i_merkleRoot;
      }

      function getAirdropRecipients() external view returns (address[] memory) {
            return airdropRecipients;
      }

}