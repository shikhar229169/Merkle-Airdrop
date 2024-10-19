// SPDX-License-Identifier: MIT

pragma solidity 0.8.27;

import { Script, console } from "forge-std/Script.sol";
import { DevOpsTools } from "@foundry-devops/src/DevOpsTools.sol";
import { MerkleAirdrop } from "src/MerkleAirdrop.sol";
import { KittyToken } from "src/KittyToken.sol";

contract Interactions is Script {
    address CLAIMING_ADDR = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 AMOUNT = 25e18;
    
    function claimAirdrop(address _airdrop, address _kittyToken) public {
        MerkleAirdrop airdrop = MerkleAirdrop(_airdrop);
        KittyToken kittyToken = KittyToken(_kittyToken);
        bytes32[] memory proof = new bytes32[](2);
        proof[0] = 0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
        proof[1] = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
        bytes memory signature = hex"052c73d43b52af6f7a1328e51fa3aa4d6802324eddf506a79cbcbc746495c4477762232154becd45c6d4734b0d7fe9a3755c855ed059cdbf7fbcde1dab9d40ef1c";

        console.log("Initial Kitty Token balance:", kittyToken.balanceOf(CLAIMING_ADDR));

        vm.startBroadcast();

        airdrop.claimFor(CLAIMING_ADDR, AMOUNT, signature, proof);

        vm.stopBroadcast();

        console.log("Final Kitty Token balance:", kittyToken.balanceOf(CLAIMING_ADDR));
    }

    function run() external {
        address mostRecentAirdrop = DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);
        address kittyToken = DevOpsTools.get_most_recent_deployment("KittyToken", block.chainid);
        claimAirdrop(mostRecentAirdrop, kittyToken);
    }
}