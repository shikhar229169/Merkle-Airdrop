// SPDX-License-Identifier: MIT

pragma solidity 0.8.27;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { EIP712 } from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract MerkleAirdrop is EIP712 {
    using SafeERC20 for IERC20;

    // Structs
    struct AirdropClaimParams {
        address account;
        uint256 amount;
    }

    // Errors
    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();
    error MerkleAirdrop__InvalidSignature();

    // Variables
    IERC20 private immutable i_airdropKittyToken;
    bytes32 private immutable i_merkleRoot;
    mapping(address => bool) private s_hasClaimed;
    bytes32 private constant MESSAGE_TYPEHASH = keccak256("AirdropClaimParams(address account,uint256 amount)");

    // Events
    event Claimed(address account, uint256 amount);

    // Constructor
    constructor(address _airdropKittyToken, bytes32 _merkleRoot) EIP712("MerkleAirdrop", "v1") {
        i_airdropKittyToken = IERC20(_airdropKittyToken);
        i_merkleRoot = _merkleRoot;
    }

    function claim(uint256 _amount, bytes32[] calldata _merkleProof) external {
        _claim(msg.sender, _amount, _merkleProof);
    }

    function claimFor(address _account, uint256 _amount, bytes memory _signature, bytes32[] calldata _merkleProof) external {
        bytes32 structHash = keccak256(abi.encode(MESSAGE_TYPEHASH, AirdropClaimParams({account: _account, amount: _amount})));
        bytes32 digest = _hashTypedDataV4(structHash);
        address signer = ECDSA.recover(digest, _signature);
        require(signer == _account, MerkleAirdrop__InvalidSignature());

        _claim(_account, _amount, _merkleProof);
    }

    function _claim(address _account, uint256 _amount, bytes32[] calldata _merkleProof) internal {
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(_account, _amount))));

        require(!s_hasClaimed[_account], MerkleAirdrop__AlreadyClaimed());        
        require(MerkleProof.verify(_merkleProof, i_merkleRoot, leaf), MerkleAirdrop__InvalidProof());

        emit Claimed(_account, _amount);

        s_hasClaimed[_account] = true;
        i_airdropKittyToken.safeTransfer(_account, _amount);
    }

    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    function hasClaimed(address _account) external view returns (bool) {
        return s_hasClaimed[_account];
    }

    function getAirDropKittyToken() external view returns (address) {
        return address(i_airdropKittyToken);
    }

    function getMessageDigest(address _account, uint256 _amount) external view returns (bytes32 _digest) {
        bytes32 _structHash = keccak256(abi.encode(MESSAGE_TYPEHASH, AirdropClaimParams({account: _account, amount: _amount})));
        _digest = _hashTypedDataV4(_structHash);
    }
}