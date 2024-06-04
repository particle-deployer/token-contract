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
    bytes32 ROOT = 0xd05471300fa2eefaadbd9c2a850714b84ccfc72e475dc468f29bcd5dc84010e7;
    bytes32 PROOF1 = 0x6cd23e0029867095eeb87617da1a6803b5170b9ac124b04ad6bf5c5556650e5d;
    bytes32 PROOF2 = 0x529831ca84402eac3b8288da4e38cb6d5504ee4ecd91f7660a9d9ce8848d006a;

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
