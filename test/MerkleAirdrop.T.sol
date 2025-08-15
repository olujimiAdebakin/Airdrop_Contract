
// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;


import {Test, console} from "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {AirBucksToken} from "../src/AirBucksToken.sol";

contract MerkleAirdropTest is Test {
   
   MerkleAirdrop public merkleAirdrop;
   AirBucksToken public airBucksToken;

   bytes32 public ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
   address recipient;
   uint256 recipientProveKey;

   function setUp() public {
      airBucksToken = new AirBucksToken();
      //  merkleAirdrop = new MerkleAirdrop(ROOT, IERC20(address(airBucksToken)));
       merkleAirdrop = new MerkleAirdrop(ROOT, airBucksToken);
       (recipient, recipientProveKey) = makeAddrAndKey("recipient");
   }

   function testRecipientCanClaim() public{
      console.log("Recipient address:", recipient);
      console.log("Recipient prove key:", recipientProveKey);
      airBucksToken.mint(recipient, 1000 ether);
      console.log("Recipient balance:", airBucksToken.balanceOf(recipient));
   }

}