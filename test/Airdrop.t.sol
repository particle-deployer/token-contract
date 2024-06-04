// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {BaseTest} from "./Base.t.sol";
import {Airdrop} from "../contracts/Airdrop.sol";

contract AirdropTest is BaseTest {
    Airdrop public airdrop;

    address USER1 = address(0xa1);
    address USER2 = address(0xb2);
    address USER3 = address(0xc3);
    address USER4 = address(0xd4);
    address USER5 = address(0xe5);

    uint256 AMOUNT1 = 100 ether;
    uint256 AMOUNT2 = 200 ether;
    uint256 AMOUNT3 = 4269 ether;
    uint256 AMOUNT4 = 1 wei;
    uint256 AMOUNT5 = 2 wei;

    bytes32 ROOT = 0x73f0e8997fbd249362167fa8c1d472188d0171aa52658ff3ec7b3b4999ada6c0;

    bytes32[] public PROOF1;
    bytes32[] public PROOF2;
    bytes32[] public PROOF3;
    bytes32[] public PROOF4;
    bytes32[] public PROOF5;

    function setUp() public override {
        super.setUp();

        vm.startPrank(DEV);
        airdrop = new Airdrop(address(particleToken));
        airdrop.updateMerkleRoot(ROOT);
        vm.stopPrank();

        PROOF1 = new bytes32[](2);
        PROOF1[0] = 0xaf48180240a5850f6da4315bbdd5cd82f4b5800957f963e72bf48e273f3d4a13;
        PROOF1[1] = 0xef61eb3facf4fb77200747f2224e11c139bb6fc4ec4c605597b3690728332626;

        PROOF2 = new bytes32[](2);
        PROOF2[0] = 0x5d13d7741d7d99014cd24431f232ffb2c5ef90dd8b1b4f1adca98302c1b96a6c;
        PROOF2[1] = 0x4c76660e585049630cbcb52011fe33680b12628e10eac098178d725f31bb7cd8;

        PROOF3 = new bytes32[](3);
        PROOF3[0] = 0x1b3339dcbe167a36a23be985df1b88f085c58cbd99da9409bb4c26cb5f8c80ff;
        PROOF3[1] = 0xdc4d1c8173ca92c9c67fae7074e9f5c3569dd410fc89cbd1e0a651ad4f0e03cf;
        PROOF3[2] = 0xef61eb3facf4fb77200747f2224e11c139bb6fc4ec4c605597b3690728332626;

        PROOF4 = new bytes32[](3);
        PROOF4[0] = 0x0a691d392c3a9c54492510fa1ca62d080d8778487e9a7c76d29294ff04dc08db;
        PROOF4[1] = 0xdc4d1c8173ca92c9c67fae7074e9f5c3569dd410fc89cbd1e0a651ad4f0e03cf;
        PROOF4[2] = 0xef61eb3facf4fb77200747f2224e11c139bb6fc4ec4c605597b3690728332626;

        PROOF5 = new bytes32[](2);
        PROOF5[0] = 0xb414b77f69cca9722deb5902fe2ac6fec9786c8249812f7328657960786d5d4f;
        PROOF5[1] = 0x4c76660e585049630cbcb52011fe33680b12628e10eac098178d725f31bb7cd8;
    }

    function testUserCanClaimCorrectAmount() public {
        vm.startPrank(DEV);
        particleToken.transfer(address(airdrop), AMOUNT1 + AMOUNT2 + AMOUNT3 + AMOUNT4 + AMOUNT5);
        vm.stopPrank();

        vm.startPrank(USER1);
        airdrop.claim(AMOUNT1, PROOF1);
        assertEq(particleToken.balanceOf(USER1), AMOUNT1);
        vm.stopPrank();

        vm.startPrank(USER2);
        airdrop.claim(AMOUNT2, PROOF2);
        assertEq(particleToken.balanceOf(USER2), AMOUNT2);
        vm.stopPrank();

        vm.startPrank(USER3);
        airdrop.claim(AMOUNT3, PROOF3);
        assertEq(particleToken.balanceOf(USER3), AMOUNT3);
        vm.stopPrank();

        vm.startPrank(USER4);
        airdrop.claim(AMOUNT4, PROOF4);
        assertEq(particleToken.balanceOf(USER4), AMOUNT4);
        vm.stopPrank();

        vm.startPrank(USER5);
        airdrop.claim(AMOUNT5, PROOF5);
        assertEq(particleToken.balanceOf(USER5), AMOUNT5);
        vm.stopPrank();
    }

    function testUserCannotOverclaim() public {
        vm.startPrank(DEV);
        particleToken.transfer(address(airdrop), AMOUNT1);
        vm.stopPrank();

        vm.startPrank(USER1);
        vm.expectRevert("Airdrop: invalid proof");
        airdrop.claim(AMOUNT1 + 1, PROOF1);
        vm.stopPrank();
    }

    function testCannotClaimOthers() public {
        vm.startPrank(DEV);
        particleToken.transfer(address(airdrop), AMOUNT1);
        vm.stopPrank();

        vm.startPrank(USER2);
        vm.expectRevert("Airdrop: invalid proof");
        airdrop.claim(AMOUNT1, PROOF1);
        vm.stopPrank();
    }

    function testContractCannotOverclaim() public {
        vm.startPrank(DEV);
        particleToken.transfer(address(airdrop), AMOUNT1 - 1 wei);
        vm.stopPrank();

        vm.startPrank(USER1);
        vm.expectRevert();
        airdrop.claim(AMOUNT1, PROOF1);
        vm.stopPrank();
    }

    function testAdminCanUpdateMerkleRoot() public {
        vm.startPrank(DEV);
        airdrop.updateMerkleRoot(0x0);
        vm.stopPrank();
    }

    function testNonAdminCannotUpdateMerkleRoot() public {
        vm.startPrank(USER1);
        vm.expectRevert();
        airdrop.updateMerkleRoot(0x0);
        vm.stopPrank();
    }

    function testCannotUseWrongProof() public {
        vm.startPrank(DEV);
        particleToken.transfer(address(airdrop), AMOUNT1);
        vm.stopPrank();

        vm.startPrank(USER1);
        vm.expectRevert("Airdrop: invalid proof");
        airdrop.claim(AMOUNT1, PROOF2);
        vm.stopPrank();
    }

    function testCannotDoubleClaim() public {
        vm.startPrank(DEV);
        particleToken.transfer(address(airdrop), AMOUNT1 * 2);
        vm.stopPrank();

        vm.startPrank(USER1);
        airdrop.claim(AMOUNT1, PROOF1);

        vm.expectRevert("Airdrop: already claimed all");
        airdrop.claim(AMOUNT1, PROOF1);
        vm.stopPrank();
    }
}
