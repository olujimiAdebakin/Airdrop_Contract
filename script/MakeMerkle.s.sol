// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {console} from "forge-std/console.sol";
import {Merkle} from "murky/src/Merkle.sol";
import {ScriptHelper} from "murky/script/common/ScriptHelper.sol";

/**
 * @title MakeMerkle
 * @author Adebakin Olujimi
 * @notice This script generates a Merkle tree and the corresponding proofs for a list of addresses and their airdrop amounts.
 * The script reads a JSON input file, computes the Merkle tree, and then writes the Merkle proofs and root to a new JSON output file.
 *
 * @dev This script depends on a pre-generated input file created by the `GenerateInput` script.
 * It uses the `murky` library for Merkle tree logic and `forge-std` for file I/O and JSON parsing.
 *
 * @custom:flow
 * 1. Read the `input.json` file to get the list of addresses and amounts.
 * 2. Compute the leaf hashes for each address-amount pair.
 * 3. Build the Merkle tree from the computed leaves.
 * 4. Generate the Merkle proof for each leaf.
 * 5. Write all proofs, the Merkle root, and input data to a new `output.json` file.
 */
contract MakeMerkle is Script, ScriptHelper {
    using stdJson for string; // enables us to use the json cheatcodes for strings

    // An instance of the Merkle contract from Murky to perform tree operations.
    Merkle private m = new Merkle();

    // The file path for the input JSON containing the whitelist data.
    string private inputPath = "/script/target/input.json";
    // The file path where the generated Merkle proofs will be saved.
    string private outputPath = "/script/target/output.json";

    // Read the entire contents of the input file into a string.
    string private elements = vm.readFile(string.concat(vm.projectRoot(), inputPath));
    // The data types for the Merkle tree leaves, read from the input JSON.
    string[] private types = elements.readStringArray(".types");
    // The total number of leaf nodes in the tree, read from the input JSON.
    uint256 private count = elements.readUint(".count");

    // Arrays to store the computed leaf hashes, stringified inputs, and JSON outputs.
    bytes32[] private leafs = new bytes32[](count);
    string[] private inputs = new string[](count);
    string[] private outputs = new string[](count);

    // The final JSON string to be written to the output file.
    string private output;

    /**
     * @notice Generates a JSON path for a specific value in the input file.
     * @dev This is a helper function to construct a JSON pointer string for a given index and element.
     * @param i The index of the whitelist entry (e.g., "0", "1", etc.).
     * @param j The index of the element within the entry (0 for address, 1 for amount).
     * @return string The JSON path (e.g., ".values.0.0").
     */
    function getValuesByIndex(uint256 i, uint256 j) internal pure returns (string memory) {
        return string.concat(".values.", vm.toString(i), ".", vm.toString(j));
    }

    /**
     * @notice Formats the output for a single proof into a JSON string.
     * @dev This function takes the stringified inputs, proof, root, and leaf hash, and combines them into a single JSON entry.
     * @param _inputs A string containing the JSON-formatted inputs for this leaf (e.g., `["0x...", "25000000000000000000"]`).
     * @param _proof A string containing the JSON-formatted Merkle proof.
     * @param _root The Merkle root as a string.
     * @param _leaf The leaf hash as a string.
     * @return string A JSON string representing a single Merkle tree entry.
     */
    function generateJsonEntries(string memory _inputs, string memory _proof, string memory _root, string memory _leaf)
        internal
        pure
        returns (string memory)
    {
        string memory result = string.concat(
            "{",
            "\"inputs\":",
            _inputs,
            ",",
            "\"proof\":",
            _proof,
            ",",
            "\"root\":\"",
            _root,
            "\",",
            "\"leaf\":\"",
            _leaf,
            "\"",
            "}"
        );
        return result;
    }

    /**
     * @notice The main function of the script.
     * @dev It orchestrates the entire process: reading the input, computing the leaves, generating the proofs,
     * and writing the final JSON output file.
     */
    function run() public {
        console.log("Generating Merkle Proof for %s", inputPath);

        // First pass: Read the input file and compute the leaf hashes for the entire whitelist.
        for (uint256 i = 0; i < count; ++i) {
            string[] memory input = new string[](types.length); // stringified data (address and string both as strings)
            bytes32[] memory data = new bytes32[](types.length); // actual data as a bytes32

            for (uint256 j = 0; j < types.length; ++j) {
                if (compareStrings(types[j], "address")) {
                    address value = elements.readAddress(getValuesByIndex(i, j));
                    data[j] = bytes32(uint256(uint160(value)));
                    input[j] = vm.toString(value);
                } else if (compareStrings(types[j], "uint")) {
                    uint256 value = vm.parseUint(elements.readString(getValuesByIndex(i, j)));
                    data[j] = bytes32(value);
                    input[j] = vm.toString(value);
                }
            }
            // Compute the leaf hash by encoding and hashing the address and amount.
            // A double hash is used for security (preimage resistance).
            leafs[i] = keccak256(bytes.concat(keccak256(ltrim64(abi.encode(data)))));
            // Store the stringified inputs for later use in the output file.
            inputs[i] = stringArrayToString(input);
        }

        // Second pass: Generate the proof for each leaf and format the output.
        for (uint256 i = 0; i < count; ++i) {
            // Get the proof nodes for the current leaf and stringify them.
            string memory proof = bytes32ArrayToString(m.getProof(leafs, i));
            // Get the Merkle root and convert it to a string.
            string memory root = vm.toString(m.getRoot(leafs));
            // Get the current leaf hash and convert it to a string.
            string memory leaf = vm.toString(leafs[i]);
            // Get the corresponding stringified inputs for this leaf.
            string memory input = inputs[i];

            // Generate the JSON entry for this specific leaf.
            outputs[i] = generateJsonEntries(input, proof, root, leaf);
        }

        // Combine all individual JSON entries into a single array string.
        output = stringArrayToArrayString(outputs);
        // Write the final JSON string to the output file.
        vm.writeFile(string.concat(vm.projectRoot(), outputPath), output);

        console.log("DONE: The output is found at %s", outputPath);
    }
}
