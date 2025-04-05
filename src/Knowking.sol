// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "./Token.sol";

contract KnowledgeKingGame {
    KnowledgeKingToken public token;
    address private _owner;
    mapping(address => bool) private _userExistence;
    uint256 private _quizIdCounter = 1; // starting from 1
    mapping(address => uint256) private _userQuizId;

    constructor(KnowledgeKingToken _token) {
        // specify the pre-deployed token address
        token = _token;
        // deployer of the contract is the owner
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Not the contract owner");
        _;
    }

    function initPlayer(address player) external {
        // Initialize player with 5 tokens
        require(!_userExistence[player], "Player already initialized");
        require(token.balanceOf(_owner) >= 5 * 10 ** 18, "Not enough tokens in contract");
        _userExistence[player] = true;
        token.transferFrom(_owner, player, 5 * 10 ** 18);
    }

    // call this function to start a game
    function play() external {
        require(_userExistence[msg.sender], "Player not initialized");
        // Check if previous game is finished
        require(_userQuizId[msg.sender] == 0, "Previous game not finished");
        // Player transfers 1 token for playing
        require(token.balanceOf(msg.sender) >= 1 * 10 ** 18, "Not enough tokens");
        // check allowance is enough
        require(token.allowance(msg.sender, address(this)) >= 1 * 10 ** 18, "Not enough allowance");
        token.transferFrom(msg.sender, _owner, 1 * 10 ** 18);
        _userQuizId[msg.sender] = _quizIdCounter;
        // Increment quiz ID
        _quizIdCounter++;
    }

    // call this function to end a game so that player can start a new game
    function end(address player) external {
        require(_userExistence[player], "Player not initialized");
        // Check if game is in progress
        require(_userQuizId[player] != 0, "No game in progress");
        // Reset quiz ID for player
        _userQuizId[player] = 0;
    }

    function win(address player) external onlyOwner {
        require(_userExistence[player], "Player not initialized");
        // Player wins the game and receives 2 tokens
        require(token.balanceOf(_owner) >= 2 * 10 ** 18, "Not enough tokens in contract");
        token.transferFrom(_owner, player, 2 * 10 ** 18);
    }
}
