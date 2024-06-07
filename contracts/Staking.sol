// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {ReentrancyGuard} from "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import {Multicall} from "../lib/openzeppelin-contracts/contracts/utils/Multicall.sol";
import {SafeERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "../lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import {BlastManager} from "./libraries/BlastManager.sol";

struct Stake {
    uint256 principal; // the principal amount
    uint256 principalTimespan; // principal amount across time
    uint256 checkpointTimestamp; // the deposit timestamp
}

contract Staking is ReentrancyGuard, Multicall, BlastManager {
    using SafeERC20 for IERC20;

    /* Immutables */
    address public TOKEN;

    /* Storage */
    mapping(address => Stake) public stakes;

    /* Events */
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, address indexed to, uint256 amount);

    constructor(address token) {
        require(token != address(0), "Airdrop: invalid token address");
        TOKEN = token;
    }

    /**
     * @notice Get the current principal timespan of a user
     * @param user The user address
     */
    function getCurrentPrincipalTimespan(address user) public view returns (uint256) {
        Stake memory stake = stakes[user];

        return
            stake.principalTimespan +
            stake.principal * // update principal timespan until now first
            (block.timestamp - stake.checkpointTimestamp);
    }

    /**
     * @notice Sync the current state of the stake of a user
     * @param user The user address
     */
    function _syncStake(address user) internal {
        stakes[user].principalTimespan = getCurrentPrincipalTimespan(user);
        stakes[user].checkpointTimestamp = block.timestamp;
    }

    /**
     * @notice Deposit tokens into the staking contract
     * @param amount The amount of tokens to deposit
     */
    function deposit(uint256 amount) external nonReentrant {
        IERC20(TOKEN).safeTransferFrom(msg.sender, address(this), amount);

        _syncStake(msg.sender);
        stakes[msg.sender].principal += amount;

        emit Deposit(msg.sender, amount);
    }

    /**
     * @notice Withdraw tokens from the staking contract
     * @param to The address to withdraw to
     * @param amount The amount of tokens to withdraw
     */
    function withdraw(address to, uint256 amount) external nonReentrant {
        Stake memory stake = stakes[msg.sender];

        require(stake.principal >= amount, "Staking: insufficient balance");

        _syncStake(msg.sender);
        stakes[msg.sender].principal -= amount;

        IERC20(TOKEN).safeTransfer(to, amount);

        emit Withdraw(msg.sender, to, amount);
    }
}
