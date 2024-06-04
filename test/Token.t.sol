// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {BaseTest} from "./Base.t.sol";

address constant DEV = address(0x42);

contract TokenTest is BaseTest {
    function setUp() public override {
        super.setUp();
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
