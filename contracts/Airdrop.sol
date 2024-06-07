// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Multicall} from "../lib/openzeppelin-contracts/contracts/utils/Multicall.sol";
import {ReentrancyGuard} from "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import {MerkleProof} from "../lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {Ownable2Step} from "../lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol";
import {SafeERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "../lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import {BlastManager} from "./libraries/BlastManager.sol";

contract Airdrop is Ownable2Step, ReentrancyGuard, Multicall, BlastManager {
    using SafeERC20 for IERC20;

    /* Immutables */
    address public TOKEN;

    /* Variable */
    bytes32 private _merkleRoot;
    uint256 public startTime;

    /* Storage */
    mapping(address => uint256) private _claimed;

    /* Events */
    event Claimed(address user, uint256 amount);

    /* Constructor */
    constructor(address token) Ownable(msg.sender) {
        require(token != address(0), "Airdrop: invalid token address");
        TOKEN = token;
    }

    /**
     * @notice Update the merkle root for the airdrop
     * @param root The new merkle root
     */
    function updateMerkleRoot(bytes32 root) external onlyOwner {
        _merkleRoot = root;
    }

    /**
     * @notice Set the start time for the airdrop
     * @param _startTime The new start time
     */
    function setStartTime(uint256 _startTime) external onlyOwner {
        startTime = _startTime;
    }

    /**
     * @notice Claim tokens from the airdrop
     * @param amount The amount of tokens this user can ever claim
     */
    function claim(uint256 amount, bytes32[] calldata proof) external onlyStarted nonReentrant {
        require(amount > _claimed[msg.sender], "Airdrop: already claimed all");

        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(msg.sender, amount))));
        require(MerkleProof.verify(proof, _merkleRoot, leaf), "Airdrop: invalid proof");

        uint256 toClaim = amount - _claimed[msg.sender];
        _claimed[msg.sender] = amount;
        IERC20(TOKEN).safeTransfer(msg.sender, toClaim);

        emit Claimed(msg.sender, toClaim);
    }

    modifier onlyStarted() {
        if (startTime > 0) {
            require(block.timestamp >= startTime, "Airdrop: not started");
        }
        _;
    }
}
