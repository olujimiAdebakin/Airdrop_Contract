# Merkle Airdrop Smart Contract 💎

## Overview
This project implements a secure and efficient gasless airdrop mechanism on the Ethereum blockchain using Solidity. It leverages Merkle trees for efficient whitelist management and EIP-712 signatures for delegated transaction execution, ensuring users can claim tokens without directly paying gas fees. Developed with Foundry, it includes a custom ERC20 token and comprehensive scripting for deployment, Merkle tree generation, and user interaction.

## Features
- **Gasless Airdrop**: Allows third parties (relay servers or designated accounts) to pay for transaction fees on behalf of recipients.
- **Merkle Tree Verification**: Utilizes a Merkle tree to efficiently verify recipient eligibility against a whitelist, minimizing on-chain data storage.
- **EIP-712 Signature Authentication**: Incorporates EIP-712 typed data signatures for secure, off-chain authorization of claim requests, preventing unauthorized claims.
- **Custom ERC20 Token**: Includes `AirBucksToken.sol`, a simple ERC20 token that can be minted by its owner.
- **Anti-Double Claiming**: Prevents addresses from claiming more than once through on-chain tracking.
- **Foundry Toolchain Integration**: Full development, testing, and deployment suite built with Foundry, ensuring robust smart contract development.
- **Automated Scripting**: Provides scripts for generating Merkle tree inputs, building the tree and proofs, and deploying and interacting with the contracts.

## Getting Started

### Installation
To set up and run this project locally, you will need to install Foundry.

1.  📥 **Clone the Repository**:
    ```bash
    git clone https://github.com/olujimiAdebakin/Airdrop_Contract.git
    cd Airdrop_Contract
    ```

2.  🛠️ **Install Foundry**:
    If you don't have Foundry installed, follow the official instructions:
    ```bash
    curl -L https://foundry.paradigm.xyz | bash
    foundryup
    ```

3.  📦 **Install Project Dependencies**:
    Navigate to the project directory and install the required Solidity libraries:
    ```bash
    forge install
    ```

4.  ⚙️ **Compile Contracts**:
    Compile the smart contracts to ensure everything is set up correctly:
    ```bash
    forge build
    ```

### Environment Variables
While no specific `.env` file is explicitly required by the provided Solidity code, for deployment and interaction with a live network, you will typically need the following environment variables. Create a `.env` file in your project root if interacting with external networks.

-   `PRIVATE_KEY`: Your wallet's private key (e.g., `0xabcdef123...`). **Warning: Never expose your private keys.**
-   `RPC_URL`: The RPC URL of the blockchain network you wish to deploy to (e.g., `https://sepolia.infura.io/v3/YOUR_API_KEY`).

```dotenv
PRIVATE_KEY="your_private_key_here"
RPC_URL="your_rpc_url_here"
```

## Usage

This project provides a comprehensive set of Foundry scripts to facilitate the entire airdrop process, from preparing the whitelist to deployment and claiming.

### 1. Generating Airdrop Inputs
The `GenerateInput.s.sol` script prepares a JSON file (`input.json`) containing the whitelist of addresses and their respective airdrop amounts. This file serves as the input for generating the Merkle tree.

To run the script:
```bash
forge script script/GenerateInput.s.sol --broadcast
```
This will create a `input.json` file in `script/target/`.

### 2. Building the Merkle Tree & Proofs
The `MakeMerkle.s.sol` script reads the `input.json` generated in the previous step, computes the Merkle root, and generates a Merkle proof for each whitelisted address. The output is saved to `output.json`.

To run the script:
```bash
forge script script/MakeMerkle.s.sol --broadcast
```
This will create an `output.json` file in `script/target/`. This file will contain the Merkle root and individual proofs, essential for users to claim.

### 3. Deploying the Contracts
The `DeployMerkleAirdrop.s.sol` script handles the deployment of both the `AirBucksToken` and `MerkleAirdrop` contracts. It also mints tokens to the deployer and transfers the total airdrop amount to the `MerkleAirdrop` contract, making them available for claiming.

To deploy to a local Anvil instance:
```bash
anvil & # Start an Anvil node in the background
forge script script/DeployMerkleAirdrop.s.sol --broadcast --rpc-url http://127.0.0.1:8545 --private-key 0xac0974... # Use Anvil's default private key
```
To deploy to a testnet (e.g., Sepolia):
```bash
forge script script/DeployMerkleAirdrop.s.sol --broadcast --rpc-url $RPC_URL --private-key $PRIVATE_KEY --verify --etherscan-api-key $ETHERSCAN_API_KEY
```
Replace `$RPC_URL`, `$PRIVATE_KEY`, and `$ETHERSCAN_API_KEY` with your actual environment variables.

### 4. Claiming the Airdrop
The `Interact.s.sol` script demonstrates how a recipient can claim their airdrop tokens. **Crucially, the `SIGNATURE` variable in `script/Interact.s.sol` must be replaced with a valid EIP-712 signature generated off-chain for the `CLAIMING_ADDRESS` and `CLAIMING_AMOUNT`**.

An EIP-712 signature is typically generated by an off-chain application (e.g., a web DApp or a backend service) using the `getMessageHash` function of the `MerkleAirdrop` contract. The signed message digest is then recovered on-chain using `ECDSA.recover` to verify the signer's identity.

**Before running `Interact.s.sol`:**
1.  Identify the `CLAIMING_ADDRESS` and `CLAIMING_AMOUNT` you wish to test.
2.  Obtain the Merkle proof for that address from the `output.json` generated by `MakeMerkle.s.sol`.
3.  Generate an EIP-712 signature off-chain for the specific `account` and `amount` using the `MerkleAirdrop` contract's `domain separator` and `type hash`. This typically involves a user signing a message in their wallet.
4.  Update the `SIGNATURE` variable in `script/Interact.s.sol` with the generated signature.

To run the claim script (assuming contracts are deployed and `SIGNATURE` is updated):
```bash
forge script script/Interact.s.sol --broadcast --rpc-url http://127.0.0.1:8545 --private-key 0xac0974... # Use Anvil's default private key
```

### 5. Running Tests
All smart contract tests are written using Foundry's `forge test` framework.
To run the tests:
```bash
forge test
```

## Smart Contract Interface

### Deployed Contracts
After deployment, the `AirBucksToken` and `MerkleAirdrop` contracts will reside at specific addresses on the blockchain. You can find these addresses in the console output of the `DeployMerkleAirdrop.s.sol` script.

### Public Functions

#### `AirBucksToken.constructor()`
Initializes the ERC20 token with "AirBucks" as its name and "ABUCKS" as its symbol, setting the deployer as the contract owner.

-   **Parameters**: None
-   **Returns**: None

#### `AirBucksToken.mint(address to, uint256 amount)`
Mints new `amount` of AirBucks tokens and transfers them to the `to` address. Only callable by the contract owner.

-   **Parameters**:
    -   `to` (address): The address to receive the minted tokens.
    -   `amount` (uint256): The amount of tokens to mint (in smallest unit, e.g., wei).
-   **Returns**: None (transaction)
-   **Errors**:
    -   `Ownable: caller is not the owner`: If a non-owner attempts to call this function.

#### `MerkleAirdrop.constructor(bytes32 merkleRoot, IERC20 airdropToken)`
Initializes the Merkle Airdrop contract with the pre-calculated Merkle root and the ERC20 token to be airdropped.

-   **Parameters**:
    -   `merkleRoot` (bytes32): The root hash of the Merkle tree containing whitelisted addresses and amounts.
    -   `airdropToken` (IERC20): The address of the ERC20 token contract to distribute.
-   **Returns**: None

#### `MerkleAirdrop.claim(address account, uint256 amount, bytes32[] calldata merkleProof, uint8 v, bytes32 r, bytes32 s)`
Allows an `account` to claim `amount` of airdrop tokens, provided a valid `merkleProof` and an `EIP-712` signature (`v`, `r`, `s`). This function is designed to be called by a gas payer on behalf of the recipient.

-   **Parameters**:
    -   `account` (address): The address of the recipient claiming the tokens.
    -   `amount` (uint256): The amount of tokens the recipient is claiming.
    -   `merkleProof` (bytes32[]): The Merkle proof validating `account` and `amount` against the Merkle root.
    -   `v` (uint8): The recovery ID of the ECDSA signature.
    -   `r` (bytes32): The R component of the ECDSA signature.
    -   `s` (bytes32): The S component of the ECDSA signature.
-   **Returns**: None (transaction)
-   **Errors**:
    -   `MerkleAirdrop_InvalidSignature`: If the provided EIP-712 signature is invalid or doesn't match the `account`.
    -   `MerkleAirdrop_AlreadyClaimed`: If the `account` has already successfully claimed.
    -   `MerkleAirdrop_InvalidProof`: If the provided Merkle proof does not verify against the contract's Merkle root.

#### `MerkleAirdrop.getMessageHash(address account, uint256 amount)`
Calculates the EIP-712 typed data hash for an airdrop claim message. This hash should be signed off-chain by the `account`.

-   **Parameters**:
    -   `account` (address): The address for which the message hash is generated.
    -   `amount` (uint256): The amount of tokens associated with the claim.
-   **Returns**: `bytes32`: The EIP-712 compliant hash of the claim message.

#### `MerkleAirdrop.getAirdropToken()`
Returns the address of the ERC20 token being airdropped.

-   **Parameters**: None
-   **Returns**: `IERC20`: The address of the airdrop token.

#### `MerkleAirdrop.getMerkleRoot()`
Returns the Merkle root used for verifying claims.

-   **Parameters**: None
-   **Returns**: `bytes32`: The Merkle root.

#### `MerkleAirdrop.getAirdropRecipients()`
Returns a list of addresses that have successfully claimed tokens.

-   **Parameters**: None
-   **Returns**: `address[]`: A dynamic array of addresses that have claimed.

#### `MerkleAirdrop.getTimeSinceDeployment()`
Returns the time in seconds that has passed since the contract was deployed.

-   **Parameters**: None
-   **Returns**: `uint256`: The time elapsed in seconds.

## Technologies Used
| Technology             | Description                                                                 | Link                                                      |
| :--------------------- | :-------------------------------------------------------------------------- | :-------------------------------------------------------- |
| 🛡️ **Solidity**        | Smart contract programming language.                                        | [Solidity Lang](https://docs.soliditylang.org/)           |
| ⚙️ **Foundry**         | Fast, portable, and modular toolkit for Ethereum application development.   | [Foundry Docs](https://book.getfoundry.sh/)               |
| 🔗 **OpenZeppelin**    | Secure and battle-tested smart contract libraries.                          | [OpenZeppelin Contracts](https://docs.openzeppelin.com/)  |
| 🌳 **Murky**           | Solidity library for Merkle tree implementations.                           | [Murky GitHub](https://github.com/dmfxyz/murky)           |
| ✨ **EIP-712**         | Standard for hashing and signing of typed structured data.                  | [EIP-712](https://eips.ethereum.org/EIPS/eip-712)         |
| 🔑 **ECDSA**           | Elliptic Curve Digital Signature Algorithm for signature verification.      | [ECDSA (Wikipedia)](https://en.wikipedia.org/wiki/Elliptic_Curve_Digital_Signature_Algorithm) |

## Contributing
Contributions are welcome! If you have suggestions for improvements or find any issues, please feel free to:

-   ⭐ **Fork the repository**.
-   🐛 **Report bugs** or suggest new features by opening an issue.
-   🚀 **Submit a pull request** with your changes.

Please ensure your code adheres to the existing style and that all tests pass.

## License
This project is licensed under the MIT License. You are free to use, modify, and distribute this code, provided the original copyright and license notice are included.

## Author Info
**Adebakin Olujimi**
Blockchain Engineer | Smart Contract Developer

-   [LinkedIn](https://www.linkedin.com/in/your_linkedin_username)
-   [Twitter](https://twitter.com/your_twitter_username)
-   [Personal Website](https://www.your_website.com)

---
[![Foundry Build Status](https://github.com/olujimiAdebakin/Airdrop_Contract/actions/workflows/ci.yml/badge.svg)](https://github.com/olujimiAdebakin/Airdrop_Contract/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Solidity Version](https://img.shields.io/badge/Solidity-0.8.26-blue.svg)](https://docs.soliditylang.org/en/v0.8.26/)
[![Made with Foundry](https://img.shields.io/badge/Made%20with-Foundry-lightgrey.svg)](https://getfoundry.sh/)

[![Readme was generated by Dokugen](https://img.shields.io/badge/Readme%20was%20generated%20by-Dokugen-brightgreen)](https://www.npmjs.com/package/dokugen)