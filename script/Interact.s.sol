

// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;



import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";


contract ClaimAirdrop is Script {

      address CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
      uint256 CLAIMING_AMOUNT = 25 * 1e18;
       bytes32[] public MERKLE_PROOF = [
        bytes32(0xc365e92ad4696ccdae6ae76aa75277b8c630a5a8b8939775341b9c1cb48e613d),
        bytes32(0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576)
    ];
      function claimAirdrop(address airdrop) {
            vm.startBroadcast();
          MerkleAirdrop(airdrop).claim(CLAIMING_ADDRESS, MERKLE_PROOF, v, r, s)
          vm.stopBroadcast();
      }

      function run() external {

            address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainId);
            claimAirdrop(mostRecentlyDeployed);
      }
}