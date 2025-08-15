# ✨ Decentralized Merkle Airdrop System

## Overview
This project implements a secure and efficient decentralized token airdrop mechanism on the Ethereum Virtual Machine (EVM) using Merkle trees. It features a custom ERC-20 token and a smart contract for distributing these tokens, leveraging cryptographic proofs for claim verification. The system is built with Solidity and extensively tested and managed using Foundry.

## Features
- **Merkle Tree Verification**: Utilizes OpenZeppelin's `MerkleProof` library for efficient and secure on-chain verification of airdrop eligibility.
- **Custom ERC-20 Token**: Implements `AirBucksToken`, a standard ERC-20 compliant token with an owner-controlled minting function, built upon OpenZeppelin contracts.
- **Automated Merkle Proof Generation**: Includes Foundry scripts (`GenerateInput.s.sol` and `MakeMerkle.s.sol`) to automate the generation of whitelist data and corresponding Merkle proofs, simplifying the setup process.
- **Secure Token Distribution**: Employs `SafeERC20` from OpenZeppelin for robust and secure token transfers, mitigating common ERC-20 vulnerabilities.
- **On-chain Claim Tracking**: Prevents multiple claims by maintaining a record of addresses that have successfully received their airdrop.
- **Foundry Toolchain**: Developed and managed with Foundry, providing a complete framework for smart contract development, testing, and deployment.

## Getting Started

### Installation
To get this project up and running locally, follow these steps:

1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/olujimiAdebakin/Airdrop_Contract.git
    cd Airdrop_Contract
    ```

2.  **Initialize Submodules**:
    This project relies on several external libraries managed as Git submodules.
    ```bash
    git submodule update --init --recursive
    ```

3.  **Install Foundry**:
    If you don't have Foundry installed, you can do so by running the following command:
    ```bash
    curl -L https://foundry.paradigm.xyz | bash
    foundryup
    ```

4.  **Build the Project**:
    Compile the smart contracts using Foundry.
    ```bash
    forge build
    ```

### Environment Variables
The project uses environment variables for deployment and interaction with a blockchain network. These should be set in your shell or in a `.env` file (and sourced).

-   `RPC_URL`: The URL of the Ethereum RPC endpoint (e.g., Alchemy, Infura).
    *   Example: `export RPC_URL="https://eth-sepolia.g.alchemy.com/v2/YOUR_API_KEY"`
-   `PRIVATE_KEY`: The private key of the account used for deployment and signing transactions. **Handle with extreme care and never commit directly.**
    *   Example: `export PRIVATE_KEY="0x................................................................"`

## Usage

This project provides a robust framework for managing token airdrops using Merkle trees. Here's how to use its core functionalities:

1.  **Generate Airdrop Input Data**:
    The `GenerateInput.s.sol` script creates a JSON file (`input.json`) containing the whitelist of addresses and their corresponding airdrop amounts. This file serves as the basis for building the Merkle tree.

    To run the script and generate the input file:
    ```bash
    forge script script/GenerateInput.s.sol
    ```
    The generated file will be located at `script/target/input.json`.

2.  **Generate Merkle Root and Proofs**:
    The `MakeMerkle.s.sol` script reads the `input.json` file, computes the Merkle root, and generates individual Merkle proofs for each whitelisted recipient. The output, including the Merkle root and proofs, is stored in `output.json`.

    To run the script:
    ```bash
    forge script script/MakeMerkle.s.sol
    ```
    The generated file will be located at `script/target/output.json`.

3.  **Deploy Contracts**:
    Deploy the `AirBucksToken` and `MerkleAirdrop` contracts to your desired EVM network. You will need to provide the `RPC_URL` and `PRIVATE_KEY` environment variables.

    First, deploy the `AirBucksToken`:
    ```bash
    # Example deployment command (adjust chain-id and verify as needed)
    forge create src/AirBucksToken.sol:AirBucksToken --rpc-url $RPC_URL --private-key $PRIVATE_KEY --chain-id 11155111 --verify --optimizer-runs 800
    ```
    Note down the deployed `AirBucksToken` address.

    Next, deploy the `MerkleAirdrop` contract, passing the generated `i_merkleRoot` (from `script/target/output.json`) and the deployed `AirBucksToken` address as constructor arguments.
    ```bash
    # Example deployment command
    # Replace <MERKLE_ROOT> with the actual root from output.json
    # Replace <AIRBUCKS_TOKEN_ADDRESS> with the deployed AirBucksToken address
    forge create src/MerkleAirdrop.sol:MerkleAirdrop --rpc-url $RPC_URL --private-key $PRIVATE_KEY --chain-id 11155111 --constructor-args <MERKLE_ROOT> <AIRBUCKS_TOKEN_ADDRESS> --verify --optimizer-runs 800
    ```

4.  **Fund the Airdrop Contract**:
    After deploying both contracts, the owner of the `AirBucksToken` (which is the deployer of the `AirBucksToken` contract) must mint tokens to the `MerkleAirdrop` contract so it has the necessary tokens to distribute.

    Use `cast` to call the `mint` function on your deployed `AirBucksToken`:
    ```bash
    # Example command to mint tokens to the MerkleAirdrop contract
    # Replace <AIRBUCKS_TOKEN_ADDRESS> with the deployed AirBucksToken address
    # Replace <MERKLE_AIRDROP_CONTRACT_ADDRESS> with the deployed MerkleAirdrop address
    # Replace <AMOUNT_TO_MINT> with the total amount of tokens for the airdrop (e.g., 100 * 1e18 for 100 tokens with 18 decimals)
    cast send <AIRBUCKS_TOKEN_ADDRESS> "mint(address,uint256)" <MERKLE_AIRDROP_CONTRACT_ADDRESS> <AMOUNT_TO_MINT> --rpc-url $RPC_URL --private-key $PRIVATE_KEY
    ```

5.  **Claim Airdrop**:
    Whitelisted recipients can then call the `claim` function on the `MerkleAirdrop` contract, providing their address, the expected amount, and their specific Merkle proof. The Merkle proof for each recipient is available in the `script/target/output.json` file.

    ```bash
    # Example command for a recipient to claim their airdrop
    # Replace <MERKLE_AIRDROP_CONTRACT_ADDRESS> with the deployed MerkleAirdrop address
    # Replace <RECIPIENT_ADDRESS> with the address claiming
    # Replace <AMOUNT_TO_CLAIM> with the amount they are eligible for (from input.json/output.json)
    # Replace <MERKLE_PROOF_ARRAY> with the comma-separated bytes32 proof from output.json, e.g., "[bytes32_1,bytes32_2,bytes32_3]"
    cast send <MERKLE_AIRDROP_CONTRACT_ADDRESS> "claim(address,uint256,bytes32[])" <RECIPIENT_ADDRESS> <AMOUNT_TO_CLAIM> <MERKLE_PROOF_ARRAY> --rpc-url $RPC_URL --private-key $PRIVATE_KEY
    ```

## Contract Interfaces

### Deployed Contracts
-   `AirBucksToken`: The ERC-20 token issued for the airdrop.
-   `MerkleAirdrop`: The contract responsible for managing and distributing the airdrop based on Merkle proofs.

### Functions

#### `AirBucksToken` Contract
This contract represents the `AirBucks` ERC-20 token, allowing the owner to mint new tokens.

##### `constructor()`
**Description**: Initializes the ERC-20 token with "AirBucks" as its name and "ABUCKS" as its symbol, setting the deployer as the initial owner.
**Parameters**: None
**Returns**: None

##### `mint(address to, uint256 amount)`
**Description**: Mints a specified `amount` of `AirBucks` tokens to a designated `to` address. This function is restricted to the contract owner.
**Parameters**:
-   `to` (`address`): The address to which tokens will be minted.
-   `amount` (`uint256`): The amount of tokens to mint.
**Returns**: None
**Errors**:
-   `OwnableUnauthorizedAccount`: Reverts if called by an address other than the contract owner.

#### `MerkleAirdrop` Contract
This contract manages the distribution of tokens via a Merkle tree, allowing whitelisted users to claim their allocation.

##### `constructor(bytes32 merkleRoot, IERC20 airdropToken)`
**Description**: Initializes the airdrop contract with the Merkle root that verifies eligibility and the ERC-20 token to be distributed.
**Parameters**:
-   `merkleRoot` (`bytes32`): The root hash of the Merkle tree containing the eligible recipients and their amounts.
-   `airdropToken` (`IERC20`): The address of the ERC-20 token contract to be used for the airdrop.
**Returns**: None

##### `claim(address account, uint256 amount, bytes32[] calldata merkleProof)`
**Description**: Allows an eligible `account` to claim a specified `amount` of tokens by providing a valid `merkleProof`.
**Parameters**:
-   `account` (`address`): The address attempting to claim the airdrop.
-   `amount` (`uint256`): The amount of tokens the `account` is eligible to claim.
-   `merkleProof` (`bytes32[] calldata`): The Merkle proof required to verify the `account` and `amount` against the stored Merkle root.
**Returns**: None
**Emits**:
-   `AirdropClaimed(address indexed account, uint256 amount)`: Emitted when an airdrop is successfully claimed.
**Errors**:
-   `MerkleAirdrop_InvalidProof()`: Reverts if the provided Merkle proof is invalid or does not match the stored Merkle root.
-   `MerkleAirdrop_AlreadyClaimed()`: Reverts if the `account` has already claimed their airdrop.

##### `getAirdropToken() external view returns (IERC20)`
**Description**: Returns the address of the ERC-20 token contract being used for the airdrop.
**Parameters**: None
**Returns**:
-   `IERC20`: The address of the airdrop token.

##### `getMerkleRoot() external view returns (bytes32)`
**Description**: Returns the immutable Merkle root used for airdrop verification.
**Parameters**: None
**Returns**:
-   `bytes32`: The Merkle root.

##### `getAirdropRecipients() external view returns (address[] memory)`
**Description**: Returns an array of addresses that have successfully claimed their airdrop.
**Parameters**: None
**Returns**:
-   `address[] memory`: An array of addresses that have claimed tokens.

##### `getTimeSinceDeployment() external view returns (uint256)`
**Description**: Returns the time elapsed in seconds since the contract was deployed.
**Parameters**: None
**Returns**:
-   `uint256`: The time in seconds since deployment.

## Technologies Used

| Technology         | Description                                        | Link                                             |
| :----------------- | :------------------------------------------------- | :----------------------------------------------- |
| **Solidity**       | Smart Contract Language                            | [soliditylang.org](https://soliditylang.org/)    |
| **Foundry**        | EVM Development Toolkit                            | [book.getfoundry.sh](https://book.getfoundry.sh/) |
| **OpenZeppelin**   | Secure Smart Contract Libraries                    | [openzeppelin.com](https://openzeppelin.com/)    |
| **Murky**          | Merkle Tree Library for Solidity/Foundry           | [github.com/dmfxyz/murky](https://github.com/dmfxyz/murky) |

## Contributing

We welcome contributions to enhance this project! To contribute:

-   ⭐ Fork the repository and clone it to your local machine.
-   🌿 Create a new branch for your feature or bug fix: `git checkout -b feature/your-feature-name`.
-   🛠️ Make your changes, ensuring code quality and adherence to existing patterns.
-   🧪 Write or update tests to cover your changes.
-   ✅ Ensure all existing tests pass: `forge test`.
-   📝 Commit your changes with a clear and concise message.
-   ⬆️ Push your branch to your forked repository.
-   🤝 Open a pull request to the main branch, detailing your changes.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

## Author Info

Connect with the author for more insights and updates!

-   **Adebakin Olujimi**
    -   LinkedIn: [linkedin.com/in/your_linkedin_username](https://www.linkedin.com/in/your_linkedin_username)
    -   Twitter: [twitter.com/your_twitter_handle](https://twitter.com/your_twitter_handle)

---

[![Readme was generated by Dokugen](https://img.shields.io/badge/Readme%20was%20generated%20by-Dokugen-brightgreen)](https://www.npmjs.com/package/dokugen)