// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {KnowledgeKingToken} from "../src/Token.sol";
import {KnowledgeKingGame} from "../src/Knowking.sol";

contract TokenTest is Test {
    KnowledgeKingToken token;
    KnowledgeKingGame game;
    address owner = address(0xabc);
    address alice = address(0x123);

    function setUp() public {
        vm.prank(owner);
        token = new KnowledgeKingToken();
        vm.prank(owner);
        game = new KnowledgeKingGame(token);
        vm.prank(owner);
        token.approve(address(game), type(uint256).max);
    }

    // get total supply of KnowledgeKingToken
    function testKnowledgeKingTokenTotalSupply() public view {
        // count unit: wei
        assertEq(token.totalSupply(), 100000000 * 10 ** 18, "Total supply should be 100,000,000");
        assertEq(token.balanceOf(owner), 100000000 * 10 ** 18, "Owner should have all tokens");
    }

    // test Owner call initPlayer and player should receive 5 tokens
    function testInitPlayer() public {
        assertEq(token.balanceOf(alice), 0, "Alice should have 0 token at start");
        vm.prank(owner);
        game.initPlayer(alice);

        assertEq(token.balanceOf(alice), 5 * 10 ** 18, "Alice should have 5 tokens");
    }

    // test Player call play and should pay 1 token
    function testPlay() public {
        vm.prank(owner);
        game.initPlayer(alice);
        assertEq(token.balanceOf(alice), 5 * 10 ** 18, "Alice should have 5 tokens");
        vm.prank(alice);
        token.approve(address(game), 1 * 10 ** 18);
        vm.prank(alice);
        game.play();
        assertEq(token.balanceOf(alice), 4 * 10 ** 18, "Alice should have 4 tokens after playing");
    }

    // test player call play when not initialized
    function testPlayNotInitialized() public {
        assertEq(token.balanceOf(alice), 0, "Alice should have 0 token at start");
        vm.expectRevert("Player not initialized");
        vm.prank(alice);
        game.play();
    }

    // test player call again play when previous game is not finished
    function testPlayAgain() public {
        vm.prank(owner);
        game.initPlayer(alice);
        assertEq(token.balanceOf(alice), 5 * 10 ** 18, "Alice should have 5 tokens");
        vm.prank(alice);
        token.approve(address(game), 1 * 10 ** 18);
        vm.prank(alice);
        game.play();
        assertEq(token.balanceOf(alice), 4 * 10 ** 18, "Alice should have 4 tokens after playing");
        vm.expectRevert("Previous game not finished");
        vm.prank(alice);
        game.play();
    }

    // test player call end again when no game in progress
    function testEndAgain() public {
        vm.prank(owner);
        game.initPlayer(alice);
        assertEq(token.balanceOf(alice), 5 * 10 ** 18, "Alice should have 5 tokens");
        vm.prank(alice);
        token.approve(address(game), 1 * 10 ** 18);
        vm.prank(alice);
        game.play();
        assertEq(token.balanceOf(alice), 4 * 10 ** 18, "Alice should have 4 tokens after playing");
        vm.prank(alice);
        game.end(alice);
        vm.expectRevert("No game in progress");
        vm.prank(alice);
        game.end(alice);
    }

    // test player play again after end
    function testPlayAfterEnd() public {
        vm.prank(owner);
        game.initPlayer(alice);
        assertEq(token.balanceOf(alice), 5 * 10 ** 18, "Alice should have 5 tokens");
        vm.prank(alice);
        token.approve(address(game), 1 * 10 ** 18);
        vm.prank(alice);
        game.play();
        assertEq(token.balanceOf(alice), 4 * 10 ** 18, "Alice should have 4 tokens after playing");
        vm.prank(alice);
        game.end(alice);
        vm.prank(alice);
        token.approve(address(game), 1 * 10 ** 18);
        vm.prank(alice);
        game.play();
    }

    // test Player win
    function testWin() public {
        vm.prank(owner);
        game.initPlayer(alice);
        assertEq(token.balanceOf(alice), 5 * 10 ** 18, "Alice should have 5 tokens");
        vm.prank(alice);
        token.approve(address(game), 1 * 10 ** 18);
        vm.prank(alice);
        game.play();
        assertEq(token.balanceOf(alice), 4 * 10 ** 18, "Alice should have 4 tokens after playing");
        vm.prank(owner);
        game.win(alice);
        assertEq(token.balanceOf(alice), 6 * 10 ** 18, "Alice should have 6 tokens after winning");
    }
}
