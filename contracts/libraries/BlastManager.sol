// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IBlast} from "../interfaces/IBlast.sol";
import {IBlastPoints} from "../interfaces/IBlastPoints.sol";

contract BlastManager {
    IBlast public constant BLAST =
        IBlast(0x4300000000000000000000000000000000000002);
    address public manager;

    modifier onlyManager() {
        require(msg.sender == manager, "Blast: not manager");
        _;
    }

    constructor() {
        manager = msg.sender;
        BLAST.configureClaimableGas();
    }

    function claimGas(
        address recipient,
        bool isMax
    ) external onlyManager returns (uint256) {
        if (isMax) {
            return BLAST.claimMaxGas(address(this), recipient);
        } else {
            return BLAST.claimAllGas(address(this), recipient);
        }
    }

    function setManager(address _manager) external onlyManager {
        manager = _manager;
    }

    function setGasMode(address blastGas) external onlyManager {
        IBlast(blastGas).configureClaimableGas();
    }

    function setPointsOperator(
        address blastPoints,
        address operator
    ) external onlyManager {
        IBlastPoints(blastPoints).configurePointsOperator(operator);
    }
}
