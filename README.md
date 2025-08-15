# Secure Merkle Airdrop Contracts

This project presents a robust, decentralized token distribution system leveraging Solidity smart contracts and the Foundry development framework. It enables efficient and verifiable token airdrops using Merkle trees, ensuring fair and secure distribution to whitelisted recipients. 🌳✨

## Features

-   **Token Issuance**: Introduces `AirBucksToken`, a custom ERC-20 compliant token, serving as the asset for distribution.
-   **Merkle Proof Verification**: Employs Merkle trees to establish a whitelist, allowing claimants to verify their eligibility on-chain with cryptographic proofs.
-   **Anti-Sybil Mechanism**: Implements a claim tracking system to prevent multiple claims from the same address, ensuring equitable token distribution.
-   **Safe Token Transfers**: Utilizes OpenZeppelin's `SafeERC20` library for secure and reliable token interactions, mitigating common ERC-20 vulnerabilities.
-   **Foundry Toolchain**: Developed and tested using the Foundry toolkit, providing a high-performance environment for smart contract development, testing, and deployment scripting.

## Getting Started

To set up and run this project locally, follow these steps:

### Installation

1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/olujimiAdebakin/Airdrop_Contract.git
    cd Airdrop_Contract
    ```

2.  **Install Foundry**:
    If you haven't installed Foundry, run the following commands:
    ```bash
    curl -L https://foundry.paradigm.xyz | bash
    foundryup
    ```

3.  **Install Project Dependencies**:
    Navigate to the project directory and install the required OpenZeppelin and Forge-Std libraries using `forge`:
    ```bash
    forge install
    ```

4.  **Build the Contracts**:
    Compile the smart contracts:
    ```bash
    forge build
    ```

## Usage

This project includes scripts to help you generate the Merkle input, deploy contracts, and interact with the airdrop system.

1.  **Generate Merkle Tree Input**:
    The `script/GenerateInput.s.sol` script is used to create the `input.json` file, which contains the whitelisted addresses and their respective airdrop amounts, formatted for Merkle tree generation.

    To run this script:
    ```bash
    forge script script/GenerateInput.s.sol --broadcast --rpc-url <YOUR_RPC_URL>
    ```
    This will generate an `input.json` file in the `script/target/` directory containing the `types`, `count`, and `values` for the whitelist.

2.  **Deploy Contracts**:
    You would typically have another script (e.g., `Deploy.s.sol`) to deploy `AirBucksToken` and `MerkleAirdrop` to a blockchain network. The `MerkleAirdrop` constructor requires the computed Merkle root and the address of the `AirBucksToken`.

    *Example (conceptual) deployment via script:*
    ```solidity
    // script/Deploy.s.sol (conceptual)
    import {Script} from "forge-std/Script.sol";
    import {AirBucksToken} from "../src/AirBucksToken.sol";
    import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";

    contract DeployScript is Script {
        function run() public returns (AirBucksToken airbucks, MerkleAirdrop airdrop) {
            vm.startBroadcast();

            airbucks = new AirBucksToken();
            // In a real scenario, you'd calculate the merkleRoot dynamically or load it
            // For example, from the output of GenerateInput.s.sol
            bytes32 hardcodedMerkleRoot = 0x...; // Placeholder: Replace with actual root
            airdrop = new MerkleAirdrop(hardcodedMerkleRoot, airbucks);

            vm.stopBroadcast();
        }
    }
    ```
    You would then deploy using:
    ```bash
    forge script script/Deploy.s.sol --rpc-url <YOUR_RPC_URL> --private-key <YOUR_PRIVATE_KEY> --broadcast --verify --etherscan-api-key <YOUR_ETHERSCAN_API_KEY>
    ```

3.  **Claiming Tokens**:
    Once deployed, users can interact with the `MerkleAirdrop` contract's `claim` function, providing their address, the amount to claim, and their Merkle proof.

    *Example interaction (using `cast` for a simple case):*
    ```bash
    # Assuming MerkleAirdropAddress is the deployed address of the MerkleAirdrop contract
    # and you have the Merkle proof for your address and amount
    cast send <MerkleAirdropAddress> "claim(address,uint256,bytes32[])" <YOUR_ADDRESS> <CLAIM_AMOUNT> "[<PROOF_HASH_1>, <PROOF_HASH_2>, ...]" --rpc-url <YOUR_RPC_URL> --private-key <YOUR_PRIVATE_KEY>
    ```

4.  **Running Tests**:
    The project includes comprehensive tests written in Solidity using Foundry. To execute the test suite:
    ```bash
    forge test
    ```

## Technologies Used

This project harnesses the power of leading blockchain development technologies.

| Technology      | Description                                                                 | Link                                                             |
| :-------------- | :-------------------------------------------------------------------------- | :--------------------------------------------------------------- |
| Solidity        | An object-oriented, high-level language for implementing smart contracts.   | [Solidity](https://soliditylang.org/)                            |
| Foundry         | A blazing-fast, portable, and modular toolkit for Ethereum application development. | [Foundry](https://getfoundry.sh/)                                |
| OpenZeppelin Contracts | A library of battle-tested smart contracts for secure development on Ethereum and other EVM blockchains. | [OpenZeppelin](https://docs.openzeppelin.com/contracts/4.x/) |
| Merkle Trees    | A tree in which every leaf node is labelled with the cryptographic hash of a data block, and every non-leaf node is labelled with the cryptographic hash of its child nodes. | [Merkle Tree (Wikipedia)](https://en.wikipedia.org/wiki/Merkle_tree) |

## Contract Interface

### Deployed Addresses

Contract addresses will be provided upon successful deployment to a blockchain network.

### Contracts

#### `AirBucksToken`

An ERC-20 compliant token contract that implements ownership controls, allowing the designated owner to mint new tokens.

**Functions**:

-   `constructor()`
    Initializes the token with the name "AirBucks" and symbol "ABUCKS", and designates the deployer as the initial owner.

-   `mint(address to, uint256 amount) external onlyOwner`
    Mints a specified `amount` of new `AirBucksToken` tokens and transfers them to the `to` address. This function is restricted to be called only by the contract's owner.
    **Parameters**:
    -   `to`: `address` - The address of the recipient who will receive the minted tokens.
    -   `amount`: `uint256` - The quantity of tokens to be minted and transferred.

#### `MerkleAirdrop`

Manages the secure distribution of ERC-20 tokens to a predefined set of recipients using a Merkle tree whitelist.

**Functions**:

-   `constructor(bytes32 merkleRoot, IERC20 airdropToken)`
    Initializes the Merkle airdrop contract. It sets the immutable Merkle root (representing the whitelisted claims) and the address of the ERC-20 token contract that will be distributed.
    **Parameters**:
    -   `merkleRoot`: `bytes32` - The cryptographic root of the Merkle tree, which encodes all valid recipient addresses and their corresponding claimable amounts.
    -   `airdropToken`: `IERC20` - The interface of the ERC-20 token contract that this airdrop will distribute.

-   `claim(address account, uint256 amount, bytes32[] calldata merkleProof) external`
    Allows a whitelisted `account` to claim a specific `amount` of tokens by providing a valid `merkleProof`. The function verifies the proof against the stored Merkle root and ensures that the account has not previously claimed.
    **Parameters**:
    -   `account`: `address` - The address attempting to claim the tokens.
    -   `amount`: `uint256` - The specific amount of tokens that this `account` is eligible to claim according to the whitelist.
    -   `merkleProof`: `bytes32[]` - The cryptographic proof (array of Merkle tree sibling hashes) required to validate the claim.
    **Events Emitted**:
    -   `AirdropClaimed(address indexed account, uint256 amount)`: Emitted upon a successful claim, indicating the `account` that claimed and the `amount` received.
    **Errors Thrown**:
    -   `MerkleAirdrop_InvalidProof()`: Thrown if the provided `merkleProof` does not validate against the `i_merkleRoot` for the given `account` and `amount`.
    -   `MerkleAirdrop_AlreadyClaimed()`: Thrown if the `account` attempting to claim has already successfully claimed their tokens.

-   `getAirdropToken() external view returns (IERC20)`
    Returns the address of the ERC-20 token contract that is being distributed by this airdrop.

-   `getMerkleRoot() external view returns (bytes32)`
    Returns the immutable Merkle root hash that was set during the contract's deployment.

-   `getAirdropRecipients() external view returns (address[] memory)`
    Returns a dynamic array containing all addresses that have successfully claimed tokens through this airdrop contract.

-   `getTimeSinceDeployment() external view returns (uint256)`
    Calculates and returns the time elapsed in seconds since the `MerkleAirdrop` contract was deployed.

## Contributing

We welcome contributions to enhance the Merkle Airdrop project! Please follow these guidelines:

-   **Fork the Repository**: Start by forking this repository to your GitHub account.
-   **Create a New Branch**: Create a descriptive branch for your feature or bug fix (e.g., `feat/add-new-feature` or `fix/resolve-bug`).
-   **Make Your Changes**: Implement your changes and ensure they adhere to the existing code style.
-   **Write Tests**: For any new features or bug fixes, write comprehensive unit tests using Foundry to ensure correctness.
-   **Run Tests**: Before submitting, ensure all existing and new tests pass successfully by running `forge test`.
-   **Open a Pull Request**: Submit a pull request to the `main` branch of this repository, clearly describing your changes and their purpose.

## Author Info

-   Your Name Here
-   LinkedIn: [Your LinkedIn Profile]
-   Twitter: [Your Twitter Handle]

---

![Solidity](https://img.shields.io/badge/Solidity-%23363636.svg?style=for-the-badge&logo=solidity&logoColor=white)
![Foundry](https://img.shields.io/badge/Foundry-black?style=for-the-badge&logo=data:image/svg+xml;base64,PHN2ZyB2aWV3Qm94PSIwIDAgNzU2IDc1NiIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48Y2lyY2xlIGN4PSIzNzguMDI1IiBjeT0iMzc4LjAyNCIgcj0iMzQ3Ljc4IiBmaWxsPSIjRkZGRkZGIi8+PHBhdGggZmlsbC1ydWxlPSJldmVub2RkIiBjbGlwLXJ1bGU9ImV2ZW5vZGQiIGQ9Ik0zNzguMDI1IDBMNzI1LjgwNSAyMTkuMzM5VjUzNi43MDhMMzc4LjAyNSA3NTYuMDQ2TDMwLjI0NiA1MzYuNzA4VjIxOS4zMzlMMzc4LjAyNSAwWk0xMzEuMDUzIDU0NS4yMDlMMzU1LjIzIDcxNy45MTZMNDAyLjk1NCA3MDcuNjM1VjQ3My45MzFMMzU1LjIzIDQ1MC4wODZMMTgxLjk1NiA0ODcuNDVMMTMxLjA1MyA1NDUuMjA5Wk01NDkuOTk1IDQ1MC4wODZMMzcyLjYwNCA0NzMuOTMxVjcwNy42MzVMMzkwLjE2IDcxNy45MTZMNjI0Ljk5NiA1NDUuMjA5TDU5NS44NTQgNTExLjQ0Nkw1NDkuOTk1IDQ1MC4wODZaTTI4MS43MDkgNDIxLjc0MkwyMjQuNTcgMzcyLjcxVjE5Mi44NzNMMjgyLjY3IDEzNC41ODNMIDQ0My44MzkgMjAwLjk2Nkw0OTEuMTA4IDE2OS40NjhMMzI1LjYwMyAxMTUuMjgyTDI4MS43MDkgNDIxLjc0MlpNNzYuMjIgMjMyLjc2N0wzNTUuMjMgNDQ4LjgyNlY3MS43NzVMMTc5LjI2NiAxNjguOTExTDc2LjIyIDIzMi43NjdaTTY3OS44MjEgMjMyLjc2N0w0MDEuMTE1IDcxLjc3NXYzNzcuMDUgTDgyMy4wMjQgMTY4LjkxMUw2NzkuODIxIDIzMi43NjdaTTM1NS4yMjkgNDU2LjMwMlYyNjQuMzU3SDM1Ny41NTlDMzYxLjM0MyAyNjQuMzU3IDM2NC40OTggMjY3LjUxMSAzNjQuNDk4IDI3MS4yOTZMMzYxLjg0NiA0MjEuNDA2QzM2MS40MjMgNDI1LjYzOSAzNTcuODM1IDQyOC4zNDIgMzUzLjU3NyA0MjguMzQyQzM1MC43MjggNDI4LjM0MiAzNDguMTc3IDQyNi44MTUgMzQ2Ljc2NSA0MjQuMTMyTDM0Mi4zNSAyMjAuMzQ3QzMzOC41MzYgNDU2LjMwMiAzMzguMDY4IDQxMi45MDIgMzQwLjI2NSA0MDkuMDI0QzM0Mi40NjIgMzA1LjE0NiAzNDYuODgyIDI5OS45ODggMzUwLjgzIDI5NC42MzFDMzU1LjcwOSAyODcuNTA0IDM1Ny40ODMgMjc5LjYzMyAzNTcuNTU5IDI3MS4xNzVIzNTUuMjI5VjQ1Ni4zMDJaIiBmaWxsPSIjMDAwMDAwIi8+PC9zdmc+)
![OpenZeppelin](https://img.shields.io/badge/OpenZeppelin-336699?style=for-the-badge&logo=openzeppelin&logoColor=white)
![Build Status](https://img.shields.io/badge/Build%20Status-Passing-brightgreen?style=for-the-badge)

[![Readme was generated by Dokugen](https://img.shields.io/badge/Readme%20was%20generated%20by-Dokugen-brightgreen)](https://www.npmjs.com/package/dokugen)