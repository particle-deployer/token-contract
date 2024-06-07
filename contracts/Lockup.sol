// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Multicall} from "../lib/openzeppelin-contracts/contracts/utils/Multicall.sol";
import {ReentrancyGuard} from "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {Ownable2Step} from "../lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol";
import {IERC20} from "../lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import {SafeERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {BlastManager} from "./libraries/BlastManager.sol";

contract Lockup is Ownable2Step, ReentrancyGuard, Multicall, BlastManager {
    using SafeERC20 for IERC20;

    /* Immutables */
    address public TOKEN;

    /* Constructor */
    constructor(address token, address owner) Ownable(owner) {
        require(token != address(0), "Airdrop: invalid token address");
        TOKEN = token;
    }

    /**
     * @notice Withdraw locked up token
     * @param to The address to send the token to
     * @param amount The amount of tokens to withdraw
     */
    function withdraw(address to, uint256 amount) external onlyOwner nonReentrant {
        IERC20(TOKEN).safeTransfer(to, amount);
    }
}
