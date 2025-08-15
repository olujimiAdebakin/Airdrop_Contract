# Merkle Airdrop Protocol 💧

## Overview
This project implements a secure and efficient token distribution system on the Ethereum Virtual Machine (EVM) using Merkle trees. It comprises an ERC-20 compliant token, `AirBucksToken`, and a `MerkleAirdrop` contract designed to facilitate permissionless and verifiable airdrops using Merkle proof validation.

## Features
- **Merkle Tree Verification**: Utilizes Merkle proofs for efficient and secure validation of eligible recipients.
- **ERC-20 Token Standard**: Includes a custom `AirBucksToken` contract adhering to the ERC-20 standard for fungible tokens.
- **Secure Claim Mechanism**: Allows whitelisted addresses to claim their allocated tokens by providing a valid Merkle proof.
- **Single Claim Enforcement**: Prevents multiple claims by the same address through internal state management.
- **Transparent Recipient Tracking**: Stores and provides public access to the list of successfully claimed addresses.
- **Foundry Toolchain Integration**: Developed and tested using the Foundry development framework for robust smart contract engineering.

## Getting Started
To set up and interact with this project locally, follow these steps.

### Installation
Before you begin, ensure you have Foundry installed. If not, follow the official Foundry installation guide.

1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/olujimiAdebakin/Airdrop_Contract.git
    cd Airdrop_Contract
    ```

2.  **Install Foundry Dependencies**:
    Initialize and update the git submodules for project dependencies (OpenZeppelin Contracts, Forge Standard Library, Murky):
    ```bash
    git submodule update --init --recursive
    ```

3.  **Build Contracts**:
    Compile the smart contracts using Forge:
    ```bash
    forge build
    ```

### Environment Variables
While no explicit environment variables are required by the contracts themselves, for deployment and interaction with a blockchain network, you will typically need the following in a `.env` file (e.g., `cp .env.example .env`):

-   `PRIVATE_KEY`: Your wallet's private key for signing transactions (e.g., `0x...`).
-   `RPC_URL`: The URL of the blockchain RPC endpoint you wish to interact with (e.g., `https://sepolia.infura.io/v3/YOUR_API_KEY`).

## Usage

This project leverages Foundry scripts to generate Merkle proofs, deploy contracts, and interact with the system.

1.  **Generate Merkle Input Data**:
    This script (`GenerateInput.s.sol`) creates a `input.json` file in `script/target/` containing the addresses and amounts for the airdrop whitelist.
    ```bash
    forge script script/GenerateInput.s.sol
    ```
    This command reads the predefined whitelist in the script and outputs a JSON file.

2.  **Generate Merkle Tree and Proofs**:
    The `MakeMerkle.s.sol` script reads the `input.json` file, computes the Merkle root, and generates individual Merkle proofs for each whitelisted entry. The output is saved to `output.json` in `script/target/`.
    ```bash
    forge script script/MakeMerkle.s.sol
    ```
    This `output.json` will contain the `inputs`, `proof`, `root`, and `leaf` for each eligible participant.

3.  **Deploy Contracts**:
    The `DeployMerkleAirdrop.s.sol` script is intended for deploying the `AirBucksToken` and `MerkleAirdrop` contracts. You will need to populate this script to deploy properly. An example deployment flow would involve:
    *   Deploy `AirBucksToken`.
    *   Mint a supply of `AirBucksToken` to the `MerkleAirdrop` contract's address.
    *   Deploy `MerkleAirdrop`, passing the `merkleRoot` (obtained from `output.json`) and the `AirBucksToken` contract address to its constructor.

    Example (concept, actual script content is minimal):
    ```solidity
    // Inside script/DeployMerkleAirdrop.s.sol (extended for deployment logic)
    function run() public returns (AirBucksToken airBucks, MerkleAirdrop airdrop) {
        vm.startBroadcast();

        airBucks = new AirBucksToken();
        console.log("AirBucksToken deployed at:", address(airBucks));

        // Assuming you've already run MakeMerkle.s.sol and have the root
        bytes32 merkleRoot = /* get root from output.json or hardcode for testing */; 
        
        airdrop = new MerkleAirdrop(merkleRoot, IERC20(address(airBucks)));
        console.log("MerkleAirdrop deployed at:", address(airdrop));

        // Mint tokens to the airdrop contract
        airBucks.mint(address(airdrop), 1000 * 1e18); // Example: mint 1000 tokens for the airdrop
        console.log("Tokens minted to Airdrop contract.");

        vm.stopBroadcast();
    }
    ```
    To run a deployment, you would typically use:
    ```bash
    forge script script/DeployMerkleAirdrop.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --verify
    ```

4.  **Run Tests**:
    Execute the unit and integration tests to ensure contract functionality and security.
    ```bash
    forge test
    ```

## API Documentation

This section details the publicly accessible functions and data structures of the deployed smart contracts, serving as their interaction interface.

### Contracts

#### `AirBucksToken`
An ERC-20 standard token contract.

-   **Constructor**:
    Initializes the ERC-20 token with a name and symbol, and sets the deployer as the owner.
    -   **Parameters**: None
    -   **Returns**: None

-   **`mint(address to, uint256 amount)`**
    Mints new `AirBucksToken` tokens and assigns them to a specified address. Only the contract owner can call this function.
    -   **Parameters**:
        -   `to` (address): The address to which tokens will be minted.
        -   `amount` (uint256): The amount of tokens to mint.
    -   **Returns**: None

#### `MerkleAirdrop`
A contract for managing token airdrops based on Merkle tree proofs.

-   **Constructor**:
    Initializes the `MerkleAirdrop` contract with the airdrop's Merkle root and the ERC-20 token address to be distributed.
    -   **Parameters**:
        -   `merkleRoot` (bytes32): The root hash of the Merkle tree containing eligible recipients and their amounts.
        -   `airdropToken` (IERC20): The address of the ERC-20 token being airdropped.
    -   **Returns**: None

-   **`claim(address account, uint256 amount, bytes32[] calldata merkleProof)`**
    Allows an eligible recipient to claim their tokens. Verifies the provided Merkle proof against the stored Merkle root and prevents multiple claims.
    -   **Parameters**:
        -   `account` (address): The address attempting to claim (typically `msg.sender`).
        -   `amount` (uint256): The amount of tokens to claim, as specified in the Merkle leaf.
        -   `merkleProof` (bytes32[] calldata): The Merkle proof for the `account` and `amount` combination.
    -   **Returns**: None
    -   **Emits**: `AirdropClaimed(address indexed account, uint256 amount)` upon successful claim.

-   **`getAirdropToken()`**
    Retrieves the address of the ERC-20 token being airdropped by this contract.
    -   **Parameters**: None
    -   **Returns**: `IERC20`: The contract address of the airdrop token.

-   **`getMerkleRoot()`**
    Retrieves the Merkle root hash used by this airdrop contract.
    -   **Parameters**: None
    -   **Returns**: `bytes32`: The immutable Merkle root.

-   **`getAirdropRecipients()`**
    Retrieves the list of addresses that have successfully claimed tokens from this airdrop.
    -   **Parameters**: None
    -   **Returns**: `address[] memory`: An array of addresses that have claimed.

-   **`getTimeSinceDeployment()`**
    Calculates the time elapsed since the contract was deployed.
    -   **Parameters**: None
    -   **Returns**: `uint256`: The time in seconds since deployment.

### Errors
-   **`MerkleAirdrop_InvalidProof()`**: Thrown when the provided `merkleProof` does not successfully verify against the `i_merkleRoot` for the given `account` and `amount`.
-   **`MerkleAirdrop_AlreadyClaimed()`**: Thrown when an `account` attempts to claim tokens that have already been claimed by them.

## Technologies Used

| Technology             | Description                                                   | Link                                                                        |
| :--------------------- | :------------------------------------------------------------ | :-------------------------------------------------------------------------- |
| **Solidity**           | Object-oriented programming language for writing smart contracts. | [Solidity Documentation](https://docs.soliditylang.org/en/latest/)          |
| **Foundry**            | Fast, portable, and modular toolkit for Ethereum application development. | [Foundry Book](https://book.getfoundry.sh/)                                 |
| **OpenZeppelin Contracts** | Secure and battle-tested smart contract libraries.                | [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/4.x/)      |
| **Murky**              | A lightweight Solidity library for Merkle tree operations.        | [Murky GitHub](https://github.com/dmfxyz/murky)                             |

## Contributing
Contributions are welcome! If you find any issues or have suggestions for improvements, please:

1.  🍴 Fork the repository.
2.  ✨ Create a new branch for your feature or bug fix.
3.  ✍️ Make your changes and write clear, concise commit messages.
4.  🧪 Write tests to cover your changes, ensuring no regressions.
5.  ⬆️ Push your branch and open a pull request.

## Author Info

Connect with the project author:

-   **Adebakin Olujimi**
    -   LinkedIn: [Your LinkedIn Profile](https://linkedin.com/in/your-username)
    -   Twitter: [Your Twitter Profile](https://twitter.com/your-username)
    -   Portfolio: [Your Portfolio Link](https://your-portfolio.com)

## Badges
[![Foundry](https://img.shields.io/badge/Made%20with-Foundry-grey.svg?logo=foundry&logoColor=white)](https://getfoundry.sh/)
[![Solidity](https://img.shields.io/badge/Solidity-0.8.26-brightgreen.svg?logo=solidity)](https://docs.soliditylang.org/)
[![OpenZeppelin](https://img.shields.io/badge/Powered%20by-OpenZeppelin-blue.svg?logo=openzeppelin)](https://openzeppelin.com/contracts/)

[![Readme was generated by Dokugen](https://img.shields.io/badge/Readme%20was%20generated%20by-Dokugen-brightgreen)](https://www.npmjs.com/package/dokugen)