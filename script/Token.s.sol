// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Script} from "../lib/forge-std/src/Script.sol";
import {ParticleToken} from "../contracts/Token.sol";

address constant BLAST_POINT_CONTRACT = 0x2536FE9ab3F511540F2f9e2eC2A805005C3Dd800;
address constant BLAST_POINT_ADMIN = 0x2d7Dc8B7Cc4Cc7E714034dc666E17577a0a28177;
address constant MULTISIG = 0xF60849FFe3CbF162d614D5f87bB5E20C074b5B91;

contract CounterScript is Script {
    event Deployed(address token);

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        ParticleToken particleToken = new ParticleToken();
        particleToken.setPointsOperator(BLAST_POINT_CONTRACT, BLAST_POINT_ADMIN);
        particleToken.setManager(MULTISIG);

        emit Deployed(address(particleToken));
        vm.stopBroadcast();
    }
}
