// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ParticleToken} from "../contracts/Token.sol";

address constant DEV = address(0x42);

contract TokenTest is Test {
    ParticleToken public particleToken;

    function setUp() public {
        vm.startPrank(DEV);
        particleToken = new ParticleToken();
        vm.stopPrank();
    }

    function testTotalSupply() public {
        vm.startPrank(DEV);
        assertEq(particleToken.totalSupply(), 200_000_000 * 10 ** 18);
        vm.stopPrank();
    }

    function testDevReceivedInitialSupply() public {
        vm.startPrank(DEV);
        assertEq(particleToken.balanceOf(DEV), 200_000_000 * 10 ** 18);
        vm.stopPrank();
    }

    function testName() public {
        vm.startPrank(DEV);
        assertEq(particleToken.name(), "Particle");
        vm.stopPrank();
    }

    function testSymbol() public {
        vm.startPrank(DEV);
        assertEq(particleToken.symbol(), "PTC");
        vm.stopPrank();
    }
}
