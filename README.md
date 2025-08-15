# Decentralized Merkle Airdrop System

## Overview
This project implements a secure and efficient decentralized airdrop mechanism using Merkle trees on the Ethereum Virtual Machine (EVM). It comprises a custom ERC-20 token, `AirBucksToken`, and a `MerkleAirdrop` smart contract, alongside Foundry scripts for streamlined Merkle proof generation.

## Features
- ✨ **Custom ERC-20 Token**: A deployable `AirBucksToken` compliant with the ERC-20 standard, allowing for ownership-controlled minting.
- 🌳 **Merkle Tree Integration**: Leverages Merkle proofs for robust and gas-efficient verification of whitelisted recipients, ensuring only authorized addresses can claim.
- 🛡️ **Claim Prevention**: Implements a mapping to prevent multiple claims by the same address, safeguarding against duplicate distributions.
- 🔗 **Secure Token Transfers**: Utilizes OpenZeppelin's `SafeERC20` library for secure and reliable token interactions, mitigating common ERC-20 vulnerabilities.
- ⚙️ **Automated Proof Generation**: Includes Foundry scripts (`GenerateInput.s.sol`, `MakeMerkle.s.sol`) to automate the creation of Merkle tree inputs and proofs, simplifying deployment and distribution setup.
- 📊 **Recipient Tracking**: Tracks all successfully claimed addresses within the `MerkleAirdrop` contract for transparency and auditing.

## Getting Started

To get a local copy up and running, follow these steps.

### Prerequisites
Ensure you have Foundry installed. If not, follow the official Foundry installation guide:
```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### Installation
1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/olujimiAdebakin/Airdrop_Contract.git
    cd Airdrop_Contract
    ```
2.  **Install Dependencies**:
    The project uses git submodules for its dependencies (OpenZeppelin, Murky, forge-std). Initialize and update them:
    ```bash
    forge install
    ```
3.  **Build the Project**:
    Compile the smart contracts:
    ```bash
    forge build
    ```

## Usage
This project involves generating Merkle proofs off-chain and then interacting with the deployed smart contracts on-chain.

### 1. Generate Merkle Input Data
First, generate the `input.json` file which contains the list of addresses and their respective airdrop amounts. This script uses a hardcoded whitelist for demonstration.
```bash
forge script script/GenerateInput.s.sol --broadcast
```
This command will create a file named `input.json` inside the `script/target/` directory, structured as follows (example):
```json
{
  "types": ["address", "uint"],
  "count": 4,
  "values": {
    "0": { "0": "0x006217c47ffA5Eb3F3c92247ffFE22AD998242c5", "1": "25000000000000000000" },
    "1": { "0": "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266", "1": "25000000000000000000" },
    "2": { "0": "0x2ea3970Ed82D5b30be821FAAD4a731D35964F7dd", "1": "25000000000000000000" },
    "3": { "0": "0xf6dBa02C01AF48Cf926579F77C9f874Ca640D91D", "1": "25000000000000000000" }
  }
}
```

### 2. Generate Merkle Proofs and Root
Next, use the `MakeMerkle.s.sol` script to read the `input.json`, compute the Merkle root, and generate individual Merkle proofs for each whitelisted address.
```bash
forge script script/MakeMerkle.s.sol --broadcast
```
This command will create `output.json` in `script/target/`, which contains the Merkle root and the specific proof required for each address to claim their airdrop. A sample entry from `output.json` looks like this:
```json
[
  {
    "inputs": ["0x006217c47ffA5Eb3F3c92247ffFE22AD998242c5", "25000000000000000000"],
    "proof": [
      "0x..." // bytes32 Merkle proof for this specific leaf
    ],
    "root": "0x...", // The Merkle root for the entire tree
    "leaf": "0x..." // The computed leaf hash for this address and amount
  }
  // ... more entries for other recipients
]
```

### 3. Deploy and Interact with Contracts

#### Deploy `AirBucksToken`
You would typically deploy the `AirBucksToken` first. This contract allows the `owner` to mint tokens.
```solidity
// Example deployment (conceptual, not a Foundry script)
AirBucksToken token = new AirBucksToken();
```

#### Mint Tokens to the Airdrop Contract
After deploying `AirBucksToken`, the owner of the token contract must mint and transfer the total airdrop amount to the `MerkleAirdrop` contract's address. This ensures the airdrop contract holds sufficient tokens for distribution.
```solidity
// Example: owner mints tokens to the MerkleAirdrop contract
token.mint(address(merkleAirdropContract), totalAirdropAmount);
```

#### Deploy `MerkleAirdrop`
Deploy the `MerkleAirdrop` contract by providing the `merkleRoot` obtained from `output.json` and the address of the deployed `AirBucksToken`.
```solidity
// Example deployment (conceptual, not a Foundry script)
bytes32 merkleRoot = /* get from output.json */;
IERC20 airdropToken = /* address of deployed AirBucksToken */;
MerkleAirdrop airdropContract = new MerkleAirdrop(merkleRoot, airdropToken);
```

#### Claim Airdrop
Recipients can then call the `claim` function on the deployed `MerkleAirdrop` contract, providing their address, the expected amount, and their specific `merkleProof` from `output.json`.
```solidity
// Example claim (conceptual transaction)
// Assumes 'recipientAccount', 'amount', and 'merkleProof' are extracted from output.json
airdropContract.claim(recipientAccount, amount, merkleProof);
```
Upon successful claim, the `AirdropClaimed` event will be emitted. If the proof is invalid or the recipient has already claimed, the transaction will revert with specific error messages.

_No screenshots are available for this project._

## Technologies Used

| Technology         | Description                                        | Link                                                                |
| :----------------- | :------------------------------------------------- | :------------------------------------------------------------------ |
| **Solidity**       | Smart contract programming language                | [Solidity](https://soliditylang.org/)                               |
| **Foundry (Forge)**| Ethereum development framework (build, test, deploy) | [Foundry](https://getfoundry.sh/)                                   |
| **OpenZeppelin**   | Secure smart contract libraries                    | [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/4.x/ )|
| **Murky**          | Merkle tree utility library for Solidity and scripts | [Murky](https://github.com/dmfxyz/murky)                            |

## Contributing
Contributions are welcome! If you have suggestions for improvements, new features, or bug fixes, please follow these steps:

1.  🍴 Fork the repository.
2.  🌿 Create a new branch (`git checkout -b feature/AmazingFeature`).
3.  ✏️ Make your changes and commit them (`git commit -m 'Add some AmazingFeature'`).
4.  🚀 Push to the branch (`git push origin feature/AmazingFeature`).
5.  📬 Open a pull request.

Please ensure your code adheres to existing style guidelines and that all tests pass.

## License
This project is licensed under the MIT License.

## Author Info

Connect with me:

- LinkedIn: [Your LinkedIn Profile](https://www.linkedin.com/in/yourusername/)
- Twitter: [Your Twitter Profile](https://twitter.com/yourusername)

---

[![Solidity](https://img.shields.io/badge/Language-Solidity-363636?style=flat-square&logo=solidity)](https://soliditylang.org/)
[![Framework](https://img.shields.io/badge/Framework-Foundry-000000?style=flat-square&logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjQiIGhlaWdodD0iMjQiIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cuc3Rpa2lwLmNvbS9pY29uL3N2ZyI+CjxwYXRoIGQ9Ik02IDhINC41VjExSDYuNlYxNEg0LjVWMTdIMi40VjIwSDRuMC42VjIySDAuM0gxLjRWMjQuNDgySDYuODc1QzcuMTUgMjQuNDgyIDcuMzcgMjQuMzY2IDcuNSAyNC4xNTJDNy42MjUgMjMuOTM4IDcuNjUgMjMuNzI1IDcuNSAyMy40NjhWMTcuOTc4QzcuNiAyMy4zMTIgNy45MiAxOC4xODMgOC4wMiAxNy40MDNDOC4xMiAxNi42MjMgOC41MiAxNi4wMDIgOC43OCAxNS41MzZDOS4wNCAxNS4wNyA5LjMgMTQuNjQyIDkuNTE3IDE0LjMxNkMxMC41ODMgMTQuMzE2IDEwLjg0MiAxNC42NDIgMTEuNzgyIDE1LjUzN0MxMi43NTggMTYuMzcyIDEyLjk4MyAxNy4zNzcgMTMuMzM4IDE3LjcwMkMxMy43MDEgMTcuNDg4IDE0LjU2NyAxNy4yMDggMTQuNzMzIDE2Ljc0NkMxNC44OTkgMTYuMjg1IDE0LjczMiAxNS44NTcgMTQuMTMzIDE1LjY2QzEzLjQ2OCAxNS40NjQgMTIuOTMgMTQuNjkyIDEyLjg3NSAxMy44NTJDMTIuODIgMTMuMDExIDEyLjggMTIuMTgyIDEyLjggMTEuMjQ4QzEyLjggMTAuMzk1IDEyLjgzMyA5LjU4NiAxMy4yNSAyMy42MTJDMzQuMTE2IDExLjczIDE3LjcxMiAxMS40MjIgMTYuNzQ3IDExLjI5QzE2Ljg2MiAxMS4xMzIgMTYuOTc1IDEwLjk0MiAxNi44MiAxMC44NEMxNi43NzkgMTAuNzggMTYuNTA4IDEwLjcwOCAxNi4zMTcgMTAuNTgxQzE2LjA0NiAxMC40NTQgMTUuNzQ3IDEwLjI2OSAxNS42MDcgMTAuMDg3QzE1LjQ2OCAxMC4xMDEgMTUuMjU1IDkuODggMTUuMTE2IDkuNjQ2QzE1LjA3IDkuNjE4IDE0LjkwOCA5LjM3NCAxNC43NDIgOS4yNjdDMTQuNTc1IDkuMTU5IDE0LjQzMiA4Ljk5MiAxNC4yOTIgOC44MjVDMTMuOTA4IDguNjI4IDEzLjQ5MiA4LjU5OCAxMi45MDggOC41OUMxMi4zMjUgOC41ODEgMTEuODczIDguNDc1IDExLjQ4MiA4LjMwMkMxMS4wOSA4LjEyOCAxMC41MjUgNy41ODkgMTAuNDggNi44OThDMTIuNDg1IDYuMzY3IDE1LjU4OCA1LjQ0MiAxNi44MTcgNC43OTRDMTEuMzk2IDMuNzEyIDguMjY5IDYuNDExIDQuMzUyIDQuMTU1QzIuODIgMy4yMTMgMC45NjcgMi41NTEgMC42NDIgMi4wMTZDMC4xNDYgMS4xNTggMC4xNDYgMC4zNTIgMC41NzEgMC4zNTJDMS4xNjggMC4yOTcgMS41NTQgMC42NDcgMS45NTggMS4zMjJDNC42NDYgMi4wNDQgNi42MjggNC4xMzIgOC4xNDYgNS40NDJDNy43IDQuNTY1IDYuOTU4IDMuNzY5IDYuNDU4IDMuMzU4QzYuMDk2IDMuMjEgNS44OTIgMi44ODcgNS41OTYgMi42ODZDNS4yOTYgMi40ODMgNC44MjUgMi4xNTggNC42NDYgMS45NzNDNC4zNjMgMS41ODUgNC4xIDAuOTI2IDMuOTk2IDAuNDIyQzMuODkyIC0wLjA4MiAzLjM2MyAtMC4wMDcgMy4xMTcgMC4yMTdDMi45MDggMC40MTcgMi42NzUgMC42NDMgMi41NTQgMC43MjRDMC44NzUgMi42OCAxLjc3NSAyLjcwMSAyLjQ5NiAzLjExMkMzLjU0MiAzLjM1MiAzLjgyNSAzLjYzIDQuMzEyIDMuODg3QzQuOTg4IDQuNTE4IDUuNTQ2IDUuMzg4IDUuODMzIDUuNzUxQzYgNS45MiA2LjE1IDYuNzkgNi4yNSA3Ljg0TDIuNzUgOS4yNzVDMi43NSA5LjI3NSAyLjc1IDkuMzc2IDIuNzUgOS41TDMuNjI1IDEwLjY5MUM0LjUwOCAxMi42NDYgNC42NjggMTQuNTM4IDUuMzE3IDE1LjcwMUM1LjY5MiAxNi40NjcgNi4zNjcgMTYuOTM4IDcuMDA4IDE3LjE5OUM3LjQ0MiAxNy40MDMgOC43MjUgMTguMzUyIDkuMTQyIDE4Ljc2MUM5LjU1OCAxOS4xNzggMTAuNDY3IDE5LjQ0MiAxMS4xMTcgMTkuNjc3QzExLjU4MiAxOS44MjUgMTIuMDQ2IDIwLjA1IDEyLjQ4MyAyMC4yMDRDMzkuMzEzIDkuMTUgNDAuMTg4IDExLjI1IDM5LjczNyAxMS43MjVDMzcuMDk1IDExLjAzNSAzNC41MjUgMTEuNzc1IDMyLjEgMTIuNTg4QzMxLjYgMTIuNzU4IDMxLjQ1OCAxMi41MDUgMzEuMzQyIDEyLjMxNUMzMS4yMjUgMTIuMjk1IDMwLjY1OCAxMi4zNTggMjkuOTY3IDEyLjU1QzI5LjM5MiAxMi42MTcgMjkuMDg3IDEyLjc1OCAyOC44NDYgMTIuODk2QzI2LjkxNyAxMy45NTkgMjYuNTc1IDE0LjYzNiAyNS45MjUgMTUuMjYxQzI1LjY0NiAxNS41MDUgMjUuMzM4IDE1LjYxMiAyNC44OTIgMTUuNzI2QzIzLjE5MiAxNi4xODQgMjIuMjkyIDE2LjY2NSAyMS44MzcgMTcuMDM5QzIxLjYyNSAxNy4yMDggMjEuMzg3IDE3LjQ1IDIxLjA5MiAxNy43MThDMjAuNjk1IDE4LjA4OSAyMC4yMjUgMTguNDI5IDE5LjU5MiAxOC42NzVDMTguODQ2IDE4Ljk2OSAxOC4wMjUgMTkuMjY3IDE3LjQxNyAxOS40OTJDNTEuNDg4IDE1LjM0NiA0MC4yOTEgMjQuMjQ1IDQ3LjYwNyAyMi40NjRDMzkuNDkyIDIzLjY0NCAzMS41NTQgMjMuNTIyIDI5LjMzOCAyMy40MDJDMjguMzU4IDIzLjI2NCAyNy4yNjMgMjIuNDcgMjYuNzQyIDIyLjEyNUMyNi4yMDggMjEuNzU2IDI1LjU1OCAyMC45NzEgMjUuMTgzIDIwLjE0NkMyNC43MiAxOS4xMTcgMjQuNjU4IDE4LjQzMiAyNC43NzUgMTcuNzMzQzI0LjgyNSAxNy41MjUgMjUuMTUyIDE3LjM4NyAyNS40NzUgMTcuMjkyQzI1Ljc1NCAxNy4xOTkgMjYuMDA0IDE3LjExNyAyNi4zOTYgMTYuOTc1QzI2LjczNyAxNi43MjggMjYuOTY3IDE2LjUwNCAyNy4yMjUgMTYuMTY3QzI3LjQ4MyAxNS44MzMgMjcuNjY4IDE1LjMzMyAyNy43OTIgMTUuMDg2QzI3Ljg2MiAxNC44ODcgMjcuOTI1IDE0LjYzNiAyOC4wNDIgMTQuMzc5QzI4LjM0MiAxMy43MjUgMjguNTQyIDEzLjIxNyAyOC41NDIgMTIuNDg2QzI4LjM1MiAxMi4yNyAyNy45NjcgMTEuNzg2IDI3LjU4MyAxMS4wNDJDMTkuNzQ2IDcuMTQ2IDE1LjU5MiA4LjA4MiAxMy40OTYgOC44NzVDOS42OTYgMTMuNzUzIDYuNiAxOC41NDIgNi41IDIzLjIyNUM2LjQgMjMuNjU1IDYgMjMuNzg2IDYgMjQuMDgyQzYgMjQuMzMyIDUuODIgMjQuNDgyIDUuNzUgMjQuNDgySDQuMDQyQzMuODM2IDI0LjE5MiAzLjcwOCAyNC4wMTkgMy42OTYgMjMuOTU0QzMuNTg3IDIzLjg1MyAzLjQ4MyAyMy43MTMgMy4zNjcgMjMuNjEzQzMuMjM2IDIzLjUxOSAzLjEwOCAyMy40MDMgMi45OTYgMjMuMjk3QzIuODk2IDIzLjE3NSAyLjY3NSAyMi45NTggMi41OTYgMjIuODM2QzIuNTQ2IDIyLjc5MiAyLjU0MiAyMi43MzYgMi41IDIyLjY5NEMyLjU4MyAyMi41NjIgMi42NjcgMjIuMzk2IDIuNzcgMjIuMjQ2QzIuNzkgMjIuMjEgMi43OTYgMjIuMTQ2IDIuNzY3IDIyLjA3NUMyLjY3NSAyMS45MTcgMi42MjUgMjEuODUyIDIuNjI1IDIxLjc0NkMyLjYyNSAyMS41NzkgMi43MDggMjEuMzI1IDIuNzcyIDIxLjA5QzIuNzg3IDIwLjk5NiAyLjg0MiAyMC44MjUgMi45MDggMjAuNjg2QzIuOTk2IDIwLjQ3NSAzLjEyNSAyMC4yMzMgMy4yOTYgMjAuMDE5QzMuMzU4IDE5LjkyMSAzLjUzMyAxOS41NjcgMy43MjUgMTkuMjk2QzMuOTE3IDE5LjAxMiA0LjI0MiAxOC41OTYgNC4zNTggMTguMjk2QzUuNDY3IDE1LjE2NyA1LjQ2NyAxMi41MDUgNS41NTggOS44NzVDNS42NzUgOS4wOTEgNS45MiA4LjU5OCA1Ljk3NSA4LjUwMUw2IDguNTUzTDYgOEg2WiIgZmlsbD0id2hpdGUiLz4KPC9zdmc+)](https://getfoundry.sh/)
[![Repo Size](https://img.shields.io/github/repo-size/olujimiAdebakin/Airdrop_Contract?style=flat-square)](https://github.com/olujimiAdebakin/Airdrop_Contract)
[![Lines of Code](https://img.shields.io/tokei/lines/github/olujimiAdebakin/Airdrop_Contract?style=flat-square)](https://github.com/olujimiAdebakin/Airdrop_Contract)
[![Dokugen](https://img.shields.io/badge/Readme%20was%20generated%20by-Dokugen-brightgreen)](https://www.npmjs.com/package/dokugen)