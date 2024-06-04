// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

interface IBlastPoints {
    /**
     * @notice Blast standard: configure for blast point operator address
     * @param operator the blast points operator address
     */
    function configurePointsOperator(address operator) external;
}
