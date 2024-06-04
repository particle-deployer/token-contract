// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ParticleToken} from "../contracts/Token.sol";

contract TokenTest is Test {
    ParticleToken public particleToken;

    function setUp() public {
        particleToken = new ParticleToken();
    }
}
