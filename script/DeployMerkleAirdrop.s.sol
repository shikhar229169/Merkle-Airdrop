// SPDX-License-Identifier: MIT

pragma solidity 0.8.27;

import { Script } from "forge-std/Script.sol";
import { MerkleAirdrop } from "src/MerkleAirdrop.sol";
import { KittyToken } from "src/KittyToken.sol";

contract DeployMerkleAirdrop is Script {
    bytes32 private constant MERKLE_ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;

    function run() external returns (KittyToken kittyToken, MerkleAirdrop airdrop) {
        vm.startBroadcast();

        kittyToken = new KittyToken();
        airdrop = new MerkleAirdrop(address(kittyToken), MERKLE_ROOT);

        vm.stopBroadcast();
    }
}