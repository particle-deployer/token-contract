// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {BaseTest} from "./Base.t.sol";
import {Airdrop} from "../contracts/Airdrop.sol";

contract AirdropTest is BaseTest {
    Airdrop public airdrop;

    address USER1 = address(0x4242);
    address USER2 = address(0x6969);
    uint256 AMOUNT1 = 100 ether;
    uint256 AMOUNT2 = 4269 ether;
    bytes32 ROOT = 0x64cb7ef94bf2080cf24f82d41c4ee3cbfdcc7618fd445707a3e19033b6e6967d;
    bytes32 PROOF1 = 0xae962cd7d8c6796258ffb107e282ed493a95645031ec3c0171ad327739816cf1;
    bytes32 PROOF2 = 0x53f30b04e0f9951f60fcdf6b8eba6b531532478123670ce3a5f702f634307b1f;

    function setUp() public override {
        super.setUp();

        vm.startPrank(DEV);
        airdrop = new Airdrop(address(particleToken));
        airdrop.updateMerkleRoot(ROOT);
        vm.stopPrank();
    }

    function testUserCanClaimCorrectAmount() public {
        vm.startPrank(USER1);
        bytes32[] memory merkleProof = new bytes32[](1);
        merkleProof[0] = PROOF1;
        airdrop.claim(AMOUNT1, merkleProof);
    }

    function testUserCannotOverclaim() public {}

    function testCannotClaimOthers() public {}

    function testContractCannotOverclaim() public {}

    function testAdminCanUpdateMerkleRoot() public {}

    function testNonAdminCannotUpdateMerkleRoot() public {}

    function testCannotUseWrongProof() public {}

    function testCannotDoubleClaim() public {}
}
