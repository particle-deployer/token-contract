// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {Multicall} from "../lib/openzeppelin-contracts/contracts/utils/Multicall.sol";
import {BlastManager} from "./libraries/BlastManager.sol";

string constant NAME = "Particle";
string constant SYMBOL = "PTC";
uint256 constant DECIMALS = 18;
uint256 constant MAX_SUPPLY = 200_000_000;

contract ParticleToken is ERC20, Multicall, BlastManager {
    constructor() ERC20(NAME, SYMBOL) {
        _mint(msg.sender, MAX_SUPPLY * 10 ** DECIMALS);
    }
}
