// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {KnowledgeKingToken} from "../src/Token.sol";
import {KnowledgeKingGame} from "../src/Knowking.sol";

contract CounterScript is Script {
    function run() public {
        vm.startBroadcast();

        // Deploy the KnowledgeKingToken contract
        KnowledgeKingToken token = new KnowledgeKingToken();
        console.log("KnowledgeKingToken deployed at:", address(token));

        // Deploy the KnowledgeKingGame contract
        KnowledgeKingGame game = new KnowledgeKingGame(token);
        console.log("KnowledgeKingGame deployed at:", address(game));

        token.approve(address(game), type(uint256).max);

        vm.stopBroadcast();
    }
}
