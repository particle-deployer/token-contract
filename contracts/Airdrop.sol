// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Multicall} from "../lib/openzeppelin-contracts/contracts/utils/Multicall.sol";
import {ReentrancyGuard} from "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import {MerkleProof} from "../lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {Ownable2Step} from "../lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol";
import {IERC20} from "../lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import {BlastManager} from "./libraries/BlastManager.sol";

contract Airdrop is Ownable2Step, ReentrancyGuard, Multicall, BlastManager {
    /* Immutables */
    address public TOKEN;

    /* Storage */
    bytes32 public merkleRoot;

    /* Storage */
    mapping(address => bool) public claimed;

    /* Constructor */
    constructor(address token) Ownable(msg.sender) {
        TOKEN = token;
    }

    /**
     * @notice Update the merkle root for the airdrop
     * @param root The new merkle root
     */
    function updateMerkleRoot(bytes32 root) external onlyOwner {
        merkleRoot = root;
    }

    /**
     * @notice Claim tokens from the airdrop
     * @param amount The amount of tokens this user can ever claim
     */
    function claim(
        uint256 amount,
        bytes32[] calldata proof
    ) external nonReentrant {
        require(amount > 0, "Airdrop: amount is 0");
        require(!claimed[msg.sender], "Airdrop: already claimed");

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, amount));
        require(
            MerkleProof.verify(proof, merkleRoot, leaf),
            "Airdrop: invalid proof"
        );

        claimed[msg.sender] = true;

        IERC20(TOKEN).transfer(msg.sender, amount);
    }
}
