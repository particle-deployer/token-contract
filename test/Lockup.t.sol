// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {BaseTest} from "./Base.t.sol";
import {Lockup} from "../contracts/Lockup.sol";
import {Timelock} from "../contracts/Timelock.sol";

contract AirdropTest is BaseTest {
    address ADMIN = 0xF60849FFe3CbF162d614D5f87bB5E20C074b5B91;
    uint256 MIN_DELAY = 3 days;
    uint256 LOCKED_AMOUNT = 180_000_000 ether;

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

    function testNonTimelockCannotWithdraw() public {}

    function testAdminCanProposeToTimelock() public {}

    function testAdminCannotProposeOverWithdraw() public {}

    function testNonAdminCannotProposeToTimelock() public {}

    function testAdminCanExcuteToTimelockAfterDelay() public {}

    function testAdminCannotExcuteToTimelockBeforeDelay() public {}

    function testNonAdminCannotExecute() public {}
}
