// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Script} from "../lib/forge-std/src/Script.sol";
import {Staking} from "../contracts/Staking.sol";

address constant BLAST_POINT_CONTRACT = 0x2536FE9ab3F511540F2f9e2eC2A805005C3Dd800;
address constant BLAST_POINT_ADMIN = 0x2d7Dc8B7Cc4Cc7E714034dc666E17577a0a28177;
address constant MULTISIG = 0x7c8b9E2De6FfA465c6f717f349B3Ab13AB46481d;
address constant PARTICLE_TOKEN = address(0x42); // Placeholder

contract CounterScript is Script {
    event Deployed(address staking);

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        Staking staking = new Staking(PARTICLE_TOKEN);
        staking.setPointsOperator(BLAST_POINT_CONTRACT, BLAST_POINT_ADMIN);
        staking.setManager(MULTISIG);

        emit Deployed(address(staking));
        vm.stopBroadcast();
    }
}
