pragma solidity ^0.8.4;

import '@openzeppelin/contracts/utils/Counters.sol';
import '@openzeppelin/contracts/access/Ownable.sol';


contract NFTMarket is Ownable {

    using Counters for Counters.Counter;
    Counters.Counter public matchIds;
    Counters.Counter public betIds;

    enum MatchResult {
        A_WIN,
        DRAW,
        B_WIN
    }

    struct Odds {
        uint256 aWin;
        uint256 draw;
        uint256 bWin;
    }

    struct MatchInfo {
        uint256 itemId;
        string matchCode;
        uint256 scoreA;
        uint256 scoreB;
        bool isStopBet;
    }
    struct BetInfo {
        uint256 betId;
        uint256 matchId;
        MatchResult bet;
        Odds odds;
        uint256 amount;
        bool isEnd;
        bool isClaim;
    }


    address payable owner;

    constructor() {
        owner = payable(msg.sender);
    }

    function createMatch(string memory matchCode) public onlyOwner{

    }

    function updateMatch(
        uint256 matchId,
        uint256 scoreA,
        uint256 scoreB
    ) public onlyOwner{

    }


    function userBet(
        uint256 matchId,
        MatchResult bet,
        uint256 amount,
        Odds memory odds,
        bytes32 _hashedMessage,
        uint8 _v, 
        bytes32 _r, 
        bytes32 _s
    ) public{

    }

    function userClaim(uint256 betId) public {

    }
}