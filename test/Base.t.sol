// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Test} from "../lib/forge-std/src/Test.sol";
import {ParticleToken} from "../contracts/Token.sol";

contract BaseTest is Test {
    address public constant DEV = address(0x42);

    ParticleToken public particleToken;

    function setUp() public virtual {
        vm.startPrank(DEV);
        particleToken = new ParticleToken();
        vm.stopPrank();
    }
}
