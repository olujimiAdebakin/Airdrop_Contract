# AirBucks Airdrop Contracts

## Overview
This project comprises a foundational ERC-20 token, `AirBucksToken`, and a secure `MerkleAirdrop` smart contract designed for efficient and verifiable token distribution on the Ethereum Virtual Machine (EVM). Developed with Solidity and leveraging the Foundry development toolkit, it ensures robust, standard-compliant, and auditable on-chain operations.

## Features
- ✨ **ERC-20 Compliant Token**: Implements the widely adopted ERC-20 standard, ensuring compatibility with wallets and exchanges.
- 💰 **Owner-Controlled Minting**: The `AirBucksToken` features a secure, owner-restricted minting function for precise token supply management.
- 🌳 **Merkle Tree-based Airdrop**: Utilizes Merkle proofs for distributing tokens, enabling efficient verification of eligible recipients off-chain and secure claims on-chain.
- 🔐 **One-Time Claim Mechanism**: Prevents double-claiming by tracking addresses that have successfully received their airdrop.
- 🛡️ **Secure Token Transfers**: Integrates OpenZeppelin's `SafeERC20` library to mitigate common ERC-20 token transfer pitfalls and enhance security.
- 🔗 **OpenZeppelin Integration**: Leverages battle-tested OpenZeppelin contracts for foundational components like `ERC20`, `Ownable`, and `MerkleProof`, enhancing security and reliability.

## Getting Started

To get a copy of this project up and running on your local machine, follow these steps.

### Installation

Before you begin, ensure you have [Foundry](https://getfoundry.sh/) installed. Foundry is a blazing fast, portable, and modular toolkit for Ethereum application development.

1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/your-username/Airdrop_contract.git
    cd Airdrop_contract
    ```

2.  **Install Foundry Dependencies**:
    ```bash
    forge install
    ```
    This command will fetch the required OpenZeppelin and Forge Standard Library dependencies specified in `.gitmodules`.

3.  **Build the Contracts**:
    ```bash
    forge build
    ```
    This compiles the smart contracts, generating their ABI and bytecode in the `out/` directory.

### Environment Variables

This project does not require any specific environment variables for local development or compilation. However, for deployment or interaction with live networks, you would typically configure network RPC URLs and private keys.

## Usage

The project consists of two core smart contracts: `AirBucksToken.sol` and `MerkleAirdrop.sol`.

### AirBucksToken

This is a standard ERC-20 token with an owner-only minting function.

-   **Deployment**: Deploy the `AirBucksToken` contract. The deployer will automatically become the `owner` of the token.
-   **Minting**: The owner can mint new `ABUCKS` tokens to any specified address. For example, to fund the airdrop contract:
    ```solidity
    function mint(address to, uint256 amount) external onlyOwner
    ```
    _Example call (via a script or direct interaction after deployment):_
    ```solidity
    // Assuming 'airbucksToken' is your deployed contract instance
    // And 'airdropContractAddress' is the address of your deployed MerkleAirdrop contract
    // And 'totalAirdropAmount' is the total amount of ABUCKS tokens to be distributed
    airbucksToken.mint(airdropContractAddress, totalAirdropAmount);
    ```

### MerkleAirdrop

This contract facilitates the distribution of `AirBucks` tokens using a Merkle tree. Eligible recipients and their claimable amounts are embedded into a Merkle tree, and users claim by providing a valid Merkle proof.

1.  **Prepare Airdrop Data (Off-chain)**:
    -   Create a list of eligible recipients and their respective `AirBucks` amounts.
    -   Generate a Merkle tree from this data (e.g., using a JavaScript or Python script). Each "leaf" in the tree should be `keccak256(abi.encode(account, amount))`.
    -   Obtain the final `merkleRoot` from the generated Merkle tree.

2.  **Deploy `MerkleAirdrop`**:
    -   Deploy the `MerkleAirdrop` contract, passing the calculated `merkleRoot` and the address of the deployed `AirBucksToken` (IERC20) contract as constructor arguments.
    ```solidity
    constructor(bytes32 merkleRoot, IERC20 airdropToken)
    ```

3.  **Fund the Airdrop Contract**:
    -   Transfer the total amount of `AirBucks` tokens designated for the airdrop from the `AirBucksToken` owner to the deployed `MerkleAirdrop` contract. This ensures the airdrop contract has enough tokens to distribute.

4.  **Claim Tokens (On-chain)**:
    -   An eligible recipient calls the `claim` function, providing their `account` address, the `amount` they are claiming, and the `merkleProof` (an array of hashes) generated off-chain.
    ```solidity
    function claim(address account, uint256 amount, bytes32[] calldata merkleProof) external
    ```
    -   The contract verifies the proof against the stored `merkleRoot` and checks if the `account` has already claimed.
    -   Upon successful verification, the specified `amount` of `AirBucks` tokens is transferred to the `account`.
    -   An `AirdropClaimed` event is emitted.

### Example Claim Flow (Conceptual)

1.  A user's off-chain application provides `userAddress`, `claimAmount`, and `merkleProof`.
2.  The user connects their wallet and triggers a transaction to the `MerkleAirdrop` contract's `claim` function with these parameters.
3.  The `MerkleAirdrop` contract executes the claim logic, transfers tokens, and updates its state.

## Technologies Used

| Technology              | Description                                                                 |
| :---------------------- | :-------------------------------------------------------------------------- |
| **Solidity**            | Primary language for writing smart contracts on the EVM.                    |
| **Foundry**             | Fast, robust, and modern toolkit for smart contract development and testing. |
| **Forge**               | Foundry's command-line tool for compiling, testing, and deploying contracts. |
| **OpenZeppelin Contracts** | Secure and community-audited smart contract libraries.                      |

## Contributing

We welcome contributions to enhance this project! To contribute:

1.  🍴 Fork the repository.
2.  🌿 Create a new branch (`git checkout -b feature/your-feature-name`).
3.  ✏️ Make your changes and commit them with clear, concise messages.
4.  🧪 Write tests for your changes to ensure functionality and prevent regressions.
5.  ⬆️ Push your branch to your forked repository.
6.  🤝 Open a pull request against the `main` branch of this repository.

Please ensure your code adheres to existing coding standards and passes all tests.

## License

This project is licensed under the MIT License. See the `SPDX-License-Identifier` in the source code for details.

## Author Info

Connect with me and see my other projects!

-   **LinkedIn**: [Your LinkedIn Profile](https://linkedin.com/in/your-username)
-   **Twitter**: [Your Twitter Handle](https://twitter.com/your-username)
-   **Portfolio**: [Your Personal Website/Portfolio](https://your-portfolio.com)

---

![Solidity](https://img.shields.io/badge/Solidity-e6e6e6?style=for-the-badge&logo=solidity&logoColor=black)
![Foundry](https://img.shields.io/badge/Foundry-black?style=for-the-badge&logo=foundry&logoColor=white)
![OpenZeppelin](https://img.shields.io/badge/OpenZeppelin-4E5257?style=for-the-badge&logo=openzeppelin&logoColor=white)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)

[![Readme was generated by Dokugen](https://img.shields.io/badge/Readme%20was%20generated%20by-Dokugen-brightgreen)](https://www.npmjs.com/package/dokugen)