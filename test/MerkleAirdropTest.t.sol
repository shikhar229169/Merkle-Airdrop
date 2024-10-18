// SPDX-License-Identifier: MIT

pragma solidity 0.8.27;

import { Test } from "forge-std/Test.sol";
import { MerkleAirdrop } from "src/MerkleAirdrop.sol";
import { KittyToken } from "src/KittyToken.sol";
import { ZkSyncChainChecker } from "@foundry-devops/src/ZkSyncChainChecker.sol";

contract MerkleAirdropTest is Test {
    MerkleAirdrop airdrop;
    KittyToken kittyToken;
    address kitty;
    address user;
    uint256 userPvtKey;
    uint256 constant PER_AMOUNT = 25e18;
    uint256 constant TOTAL_AMOUNT = 100e18;
    bytes32 constant MERKLE_ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;

    function setUp() external {
        kitty = makeAddr("kitty");
        (user, userPvtKey) = makeAddrAndKey("user");

        vm.startPrank(kitty);
        kittyToken = new KittyToken();
        airdrop = new MerkleAirdrop(address(kittyToken), MERKLE_ROOT);
        kittyToken.mint(address(kitty), TOTAL_AMOUNT);
        kittyToken.transfer(address(airdrop), TOTAL_AMOUNT);
        vm.stopPrank();
    }

    function test_UserClaimsWithCorrectMerkleProof() public {
        bytes32[] memory userProof = new bytes32[](2);
        userProof[0] = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
        userProof[1] = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;

        uint256 kittyTokenBalanceBefore = kittyToken.balanceOf(user);

        vm.prank(user);
        airdrop.claim(PER_AMOUNT, userProof);

        uint256 kittyTokenBalanceAfter = kittyToken.balanceOf(user);

        assertEq(kittyTokenBalanceAfter, kittyTokenBalanceBefore + PER_AMOUNT);

        vm.expectRevert(MerkleAirdrop.MerkleAirdrop__AlreadyClaimed.selector);
        vm.prank(user);
        airdrop.claim(PER_AMOUNT, userProof);
    }

    function test_userSignsTxnAndKittySendsTxnForUser() public {
        bytes32[] memory userProof = new bytes32[](2);
        userProof[0] = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
        userProof[1] = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;

        bytes32 _userDigest = airdrop.getMessageDigest(user, PER_AMOUNT);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPvtKey, _userDigest);
        bytes memory _signature = abi.encodePacked(r, s, v);

        uint256 kittyTokenBalanceBefore = kittyToken.balanceOf(user);

        vm.prank(kitty);
        airdrop.claimFor(user, PER_AMOUNT, _signature, userProof);

        uint256 kittyTokenBalanceAfter = kittyToken.balanceOf(user);

        assertEq(kittyTokenBalanceAfter, kittyTokenBalanceBefore + PER_AMOUNT);
    }
}