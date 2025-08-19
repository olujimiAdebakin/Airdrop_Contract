// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {console} from "forge-std/console.sol";

/**
 * @title GenerateInput
 * @author YourName
 * @notice This script generates a JSON file that serves as input for building a Merkle tree.
 * The JSON file contains a list of addresses and their corresponding airdrop amounts,
 * which can be used by an off-chain application to create the Merkle tree.
 * @dev This script uses Foundry's `vm` cheatcodes to write the output to a file
 * within the project directory.
 */
contract GenerateInput is Script {
    // The amount of tokens each recipient will receive in the airdrop.
    uint256 private constant AMOUNT = 25 * 1e18;
    // An array to store the data types for each Merkle tree leaf.
    string[] types = new string[](2);
    // The total count of addresses in the whitelist.
    uint256 count;
    // The list of recipient addresses for the airdrop.
    string[] whitelist = new string[](4);
    // The file path where the generated JSON will be saved.
    string private constant INPUT_PATH = "/script/target/input.json";

    /**
     * @notice The main function of the script.
     * @dev It populates the whitelist and then calls `_createJSON` to generate the
     * JSON string. Finally, it writes the string to the specified file path.
     */
    function run() public {
        types[0] = "address";
        types[1] = "uint";
        whitelist[0] = "0x006217c47ffA5Eb3F3c92247ffFE22AD998242c5";
        whitelist[1] = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
        whitelist[2] = "0x2ea3970Ed82D5b35be821FAAD4a731D35964F7dd";
        whitelist[3] = "0xf6dBa02C01AF48Cf926579F77C9f874Ca640D91D";
        count = whitelist.length;
        string memory input = _createJSON();
        
        // Write the stringified JSON output to the file.
        vm.writeFile(string.concat(vm.projectRoot(), INPUT_PATH), input);

        console.log("DONE: The output is found at %s", INPUT_PATH);
    }

    /**
     * @notice Creates the JSON string for the Merkle tree input.
     * @dev This function iterates through the `whitelist` and constructs a JSON object
     * with the addresses and airdrop amounts. The output format is compatible with
     * most Merkle tree generation libraries.
     * @return A JSON string formatted for Merkle tree input.
     */
    function _createJSON() internal view returns (string memory) {
        string memory countString = vm.toString(count);
        string memory amountString = vm.toString(AMOUNT);

        string memory json = string.concat('{ "types": ["address", "uint"], "count":', countString, ',"values": {');
        for (uint256 i = 0; i < whitelist.length; i++) {
            if (i == whitelist.length - 1) {
                json = string.concat(
                    json,
                    '"',
                    vm.toString(i),
                    '"',
                    ': { "0":',
                    '"',
                    whitelist[i],
                    '"',
                    ', "1":',
                    '"',
                    amountString,
                    '"',
                    " }"
                );
            } else {
                json = string.concat(
                    json,
                    '"',
                    vm.toString(i),
                    '"',
                    ': { "0":',
                    '"',
                    whitelist[i],
                    '"',
                    ', "1":',
                    '"',
                    amountString,
                    '"',
                    " },"
                );
            }
        }
        json = string.concat(json, "} }");

        return json;
    }
}
