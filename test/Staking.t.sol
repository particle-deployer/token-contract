// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IERC20} from "../lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import {BaseTest} from "./Base.t.sol";
import {Staking} from "../contracts/Staking.sol";

contract StakingTest is BaseTest {
    Staking public staking;

    address USER1 = address(0xa1);
    address USER2 = address(0xb2);

    uint256 AMOUNT1 = 100 ether;
    uint256 AMOUNT2 = 200 ether;

    function setUp() public override {
        super.setUp();
        staking = new Staking(address(particleToken));
    }

    function _deal(address user, uint256 amount) internal {
        vm.startPrank(DEV);
        IERC20(address(particleToken)).transfer(user, amount);
        vm.stopPrank();
    }

    function testDepositWithdraw() public {
        _deal(USER1, AMOUNT1);
        vm.startPrank(USER1);
        IERC20(address(particleToken)).approve(address(staking), AMOUNT1);
        staking.deposit(AMOUNT1);
        assertEq(particleToken.balanceOf(address(staking)), AMOUNT1);
        (uint256 principal, , ) = staking.stakes(USER1);
        assertEq(principal, AMOUNT1);
        assertEq(particleToken.balanceOf(address(USER1)), 0);

        staking.withdraw(USER2, AMOUNT1);
        assertEq(particleToken.balanceOf(address(staking)), 0);
        (principal, , ) = staking.stakes(USER1);
        assertEq(principal, 0);
        assertEq(particleToken.balanceOf(address(USER1)), 0);
        assertEq(particleToken.balanceOf(address(USER2)), AMOUNT1);
        vm.stopPrank();
    }

    function testCannotDepositMoreThanBalance() public {
        _deal(USER1, AMOUNT1);
        vm.startPrank(USER1);
        IERC20(address(particleToken)).approve(address(staking), AMOUNT1 + 1 wei);
        vm.expectRevert();
        staking.deposit(AMOUNT1 + 1 wei);
        vm.stopPrank();
    }

    function testCannotWithdrawMoreThanBalance() public {
        _deal(USER1, AMOUNT1);
        vm.startPrank(USER1);
        IERC20(address(particleToken)).approve(address(staking), AMOUNT1);
        staking.deposit(AMOUNT1);
        vm.stopPrank();

        _deal(USER2, AMOUNT2);
        vm.startPrank(USER2);
        IERC20(address(particleToken)).approve(address(staking), AMOUNT2);
        staking.deposit(AMOUNT2);
        vm.stopPrank();

        (uint256 principal, , ) = staking.stakes(USER1);
        assertEq(principal, AMOUNT1);
        (principal, , ) = staking.stakes(USER2);
        assertEq(principal, AMOUNT2);
        assertEq(particleToken.balanceOf(address(staking)), AMOUNT1 + AMOUNT2);

        vm.startPrank(USER1);
        vm.expectRevert("Staking: insufficient balance");
        staking.withdraw(USER1, AMOUNT1 + 1 wei);
        vm.stopPrank();
    }

    function testCannotWithdrawOthers() public {
        _deal(USER1, AMOUNT1);
        vm.startPrank(USER1);
        IERC20(address(particleToken)).approve(address(staking), AMOUNT1);
        staking.deposit(AMOUNT1);
        vm.stopPrank();

        vm.startPrank(USER2);
        vm.expectRevert("Staking: insufficient balance");
        staking.withdraw(USER1, AMOUNT1);
        vm.stopPrank();
    }

    function testPrincipalTimespan() public {
        _deal(USER1, 300 ether);
        vm.startPrank(USER1);
        IERC20(particleToken).approve(address(staking), 300 ether);

        staking.deposit(100 ether);
        vm.warp(block.timestamp + 5 days);
        uint256 principalTimespan = staking.getCurrentPrincipalTimespan(USER1);
        assertEq(principalTimespan, 100 ether * 5 days);

        staking.deposit(200 ether);
        vm.warp(block.timestamp + 10 days);
        principalTimespan = staking.getCurrentPrincipalTimespan(USER1);
        assertEq(principalTimespan, 100 ether * 5 days + 300 ether * 10 days);

        staking.withdraw(USER1, 50 ether);
        vm.warp(block.timestamp + 5 days);
        principalTimespan = staking.getCurrentPrincipalTimespan(USER1);
        assertEq(principalTimespan, 100 ether * 5 days + 300 ether * 10 days + 250 ether * 5 days);

        staking.withdraw(USER1, 250 ether);
        vm.warp(block.timestamp + 5 days);
        principalTimespan = staking.getCurrentPrincipalTimespan(USER1);
        assertEq(principalTimespan, 100 ether * 5 days + 300 ether * 10 days + 250 ether * 5 days);
        vm.stopPrank();
    }
}
