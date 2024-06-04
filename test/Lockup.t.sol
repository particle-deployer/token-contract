// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {BaseTest} from "./Base.t.sol";
import {Lockup} from "../contracts/Lockup.sol";
import {Timelock} from "../contracts/Timelock.sol";

contract AirdropTest is BaseTest {
    address ADMIN = 0xF60849FFe3CbF162d614D5f87bB5E20C074b5B91;
    address RECEIVER = address(0x8888);
    uint256 MIN_DELAY = 3 days;
    uint256 LOCKED_AMOUNT = 180_000_000 ether;
    uint256 WITHDRAW_AMOUNT = 1_000_000 ether;

    Lockup public lockup;
    Timelock public timelock;

    function setUp() public override {
        super.setUp();

        vm.startPrank(DEV);
        address[] memory proposers = new address[](1);
        address[] memory executors = new address[](1);
        proposers[0] = ADMIN;
        executors[0] = ADMIN;

        timelock = new Timelock(MIN_DELAY, proposers, executors);
        lockup = new Lockup(address(particleToken), address(timelock));

        particleToken.transfer(address(lockup), LOCKED_AMOUNT);
        vm.stopPrank();
    }

    function testNonTimelockCannotWithdraw() public {
        vm.startPrank(ADMIN);
        vm.expectRevert();
        lockup.withdraw(ADMIN, 1 wei);
        vm.stopPrank();
    }

    function testAdminCanProposeToTimelock() public {
        vm.startPrank(ADMIN);
        bytes memory data = abi.encodeWithSelector(Lockup.withdraw.selector, RECEIVER, WITHDRAW_AMOUNT);
        timelock.schedule(address(lockup), 0, data, bytes32(""), bytes32(""), MIN_DELAY);
        bytes32 id = timelock.hashOperation(address(lockup), 0, data, bytes32(""), bytes32(""));
        assertEq(timelock.getTimestamp(id), block.timestamp + MIN_DELAY);
        vm.stopPrank();
    }

    function testNonAdminCannotProposeToTimelock() public {
        vm.startPrank(RECEIVER);
        vm.expectRevert();
        bytes memory data = abi.encodeWithSelector(Lockup.withdraw.selector, RECEIVER, WITHDRAW_AMOUNT);
        timelock.schedule(address(lockup), 0, data, bytes32(""), bytes32(""), MIN_DELAY);
        vm.stopPrank();
    }

    function testAdminCanExcuteToTimelockAfterDelay() public {
        vm.startPrank(ADMIN);
        bytes memory data = abi.encodeWithSelector(Lockup.withdraw.selector, RECEIVER, WITHDRAW_AMOUNT);
        timelock.schedule(address(lockup), 0, data, bytes32(""), bytes32(""), MIN_DELAY);
        vm.warp(block.timestamp + MIN_DELAY + 1);
        timelock.execute(address(lockup), 0, data, bytes32(""), bytes32(""));
        assertEq(particleToken.balanceOf(RECEIVER), WITHDRAW_AMOUNT);
        vm.stopPrank();
    }

    function testAdminCannotOverWithdrawAfterDelay() public {
        vm.startPrank(ADMIN);
        bytes memory data = abi.encodeWithSelector(Lockup.withdraw.selector, RECEIVER, WITHDRAW_AMOUNT);
        timelock.schedule(address(lockup), 0, data, bytes32(""), bytes32(""), MIN_DELAY);
        vm.warp(block.timestamp + MIN_DELAY + 1);
        data = abi.encodeWithSelector(Lockup.withdraw.selector, RECEIVER, WITHDRAW_AMOUNT + 1);
        vm.expectRevert();
        timelock.execute(address(lockup), 0, data, bytes32(""), bytes32(""));
        vm.stopPrank();
    }

    function testAdminCannotExcuteToTimelockTwice() public {
        vm.startPrank(ADMIN);
        bytes memory data = abi.encodeWithSelector(Lockup.withdraw.selector, RECEIVER, WITHDRAW_AMOUNT);
        timelock.schedule(address(lockup), 0, data, bytes32(""), bytes32(""), MIN_DELAY);
        vm.warp(block.timestamp + MIN_DELAY + 1);
        timelock.execute(address(lockup), 0, data, bytes32(""), bytes32(""));
        vm.expectRevert();
        timelock.execute(address(lockup), 0, data, bytes32(""), bytes32(""));
        vm.stopPrank();
    }

    function testAdminCannotExcuteToTimelockBeforeDelay() public {
        vm.startPrank(ADMIN);
        bytes memory data = abi.encodeWithSelector(Lockup.withdraw.selector, RECEIVER, WITHDRAW_AMOUNT);
        timelock.schedule(address(lockup), 0, data, bytes32(""), bytes32(""), MIN_DELAY);
        vm.warp(block.timestamp + MIN_DELAY - 1);
        data = abi.encodeWithSelector(Lockup.withdraw.selector, RECEIVER, WITHDRAW_AMOUNT + 1);
        vm.expectRevert();
        timelock.execute(address(lockup), 0, data, bytes32(""), bytes32(""));
        vm.stopPrank();
    }

    function testAdminCannotExecuteOverWithdraw() public {
        vm.startPrank(ADMIN);
        bytes memory data = abi.encodeWithSelector(Lockup.withdraw.selector, RECEIVER, LOCKED_AMOUNT + 1 wei);
        timelock.schedule(address(lockup), 0, data, bytes32(""), bytes32(""), MIN_DELAY);
        vm.warp(block.timestamp + MIN_DELAY + 1);
        vm.expectRevert();
        timelock.execute(address(lockup), 0, data, bytes32(""), bytes32(""));
        vm.stopPrank();
    }

    function testNonAdminCannotExecute() public {
        vm.startPrank(ADMIN);
        bytes memory data = abi.encodeWithSelector(Lockup.withdraw.selector, RECEIVER, WITHDRAW_AMOUNT);
        timelock.schedule(address(lockup), 0, data, bytes32(""), bytes32(""), MIN_DELAY);
        vm.warp(block.timestamp + MIN_DELAY + 1);
        vm.stopPrank();
        vm.startPrank(RECEIVER);
        vm.expectRevert();
        timelock.execute(address(lockup), 0, data, bytes32(""), bytes32(""));
        vm.stopPrank();
    }

    function testAdminCanScheduleExecuteMultipleTimes() public {
        vm.startPrank(ADMIN);
        bytes memory data = abi.encodeWithSelector(Lockup.withdraw.selector, RECEIVER, WITHDRAW_AMOUNT);
        timelock.schedule(address(lockup), 0, data, bytes32(""), bytes32(""), MIN_DELAY);
        bytes32 id1 = timelock.hashOperation(address(lockup), 0, data, bytes32(""), bytes32(""));
        vm.warp(block.timestamp + MIN_DELAY + 1);
        timelock.execute(address(lockup), 0, data, bytes32(""), bytes32(""));

        timelock.schedule(address(lockup), 0, data, bytes32(""), bytes32("salt"), MIN_DELAY);
        bytes32 id2 = timelock.hashOperation(address(lockup), 0, data, bytes32(""), bytes32("salt"));
        assertNotEq(id1, id2);
        vm.warp(block.timestamp + MIN_DELAY + 1);
        timelock.execute(address(lockup), 0, data, bytes32(""), bytes32("salt"));

        assertEq(particleToken.balanceOf(RECEIVER), WITHDRAW_AMOUNT * 2);
        vm.stopPrank();
    }
}
