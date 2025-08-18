// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {AirBucksToken} from "../src/AirBucksToken.sol";
import {ZkSyncChainChecker} from "lib/foundry-devops/src/ZkSyncChainChecker.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol";

contract MerkleAirdropTest is ZkSyncChainChecker, Test {
    MerkleAirdrop public merkleAirdrop;
    AirBucksToken public airBucksToken;

    bytes32 public ROOT = 0x92a46fa0e0d41a01edeb47fab747b02eb9c46456edb0d12871fa5a6dd976867d;
    uint256 public AMOUNT = 25 * 1e18;
    bytes32[] public MERKLE_PROOF = [
        bytes32(0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a),
        bytes32(0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576)
    ];

      address recipient = 0x006217c47ffA5Eb3F3c92247ffFE22AD998242c5;

      address gasPayer;
      address user;

    // address recipient;
    uint256 recipientProveKey;

    uint256 amountToCollect = (100 * 1e18);
    uint256 amountToSend = amountToCollect * 4;

    function setUp() public {
        if (!isZkSyncChain()) {
            airBucksToken = new AirBucksToken();
            //  merkleAirdrop = new MerkleAirdrop(ROOT, IERC20(address(airBucksToken)));
            merkleAirdrop = new MerkleAirdrop(ROOT, airBucksToken);
            //  (recipient, recipientProveKey) = makeAddrAndKey("recipient");
        } else {
            airBucksToken = new AirBucksToken();
            merkleAirdrop = new MerkleAirdrop(ROOT, IERC20(address(airBucksToken)));
            airBucksToken.mint(airBucksToken.owner(), amountToSend);
            airBucksToken.transfer(address(merkleAirdrop), amountToSend);
        }
         gasPayer = makeAddr("gasPayer");
        (recipient, recipientProveKey) = makeAddrAndKey("recipient");
       
    }

    //  function signMessage(uint256 recipientProveKey, address account) public view returns (uint8 v, bytes32 r, bytes32 s) {
    //     bytes32 hashedMessage = merkleAirdrop.getMessageHash(account, amountToCollect);
    //     (v, r, s) = vm.sign(recipientProveKey, hashedMessage);
    // }

    function testRecipientCanClaim() public {
        // console.log("Recipient address:", recipient);
        // console.log("Recipient prove key:", recipientProveKey);
        airBucksToken.mint(address(merkleAirdrop), 1000 ether);
        // console.log("Recipient balance:", airBucksToken.balanceOf(recipient));

        uint256 initialBalance = airBucksToken.balanceOf(recipient);
        console.log("Initial balance:", initialBalance);

        bytes32 digest = merkleAirdrop.getMessageHash(recipient, AMOUNT);

        // vm.prank(user);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(recipientProveKey, digest);
        console.log("Signature v:", v);
        console.log("Signature r:", r);
        console.log("Signature s:", s);

        vm.prank(gasPayer);
        // Simulate gas payer sending the claim transaction
         merkleAirdrop.claim(recipient, AMOUNT, MERKLE_PROOF, v, r, s);

        // vm.startPrank(recipient);
        // merkleAirdrop.claim(recipient, AMOUNT, MERKLE_PROOF);
        assertEq(airBucksToken.balanceOf(recipient), AMOUNT);
        vm.stopPrank();

        uint256 finalBalance = airBucksToken.balanceOf(recipient);
        console.log("Final balance:", finalBalance);
        if (finalBalance != initialBalance + AMOUNT) {
            console.log("Initial balance: ", initialBalance);
            console.log("Expected final balance: ", initialBalance + AMOUNT);
            console.log("Actual final balance: ", finalBalance);
        }
        assertEq(finalBalance, initialBalance + AMOUNT, "Recipient should have received the correct amount of tokens");
    }

    // function _getMerkleProof() internal pure returns (bytes32[] memory) {
    //     bytes32[] memory proof = new bytes32[](2);
    //     proof[0] = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    //     proof[1] = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    //     return proof;
    // }
}
