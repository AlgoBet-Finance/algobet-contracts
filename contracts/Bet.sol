pragma solidity ^0.8.4;

import '@openzeppelin/contracts/utils/Counters.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/utils/Strings.sol";
import '@openzeppelin/contracts/utils/cryptography/ECDSA.sol';


contract Bet is Ownable {
    using ECDSA for bytes32;
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
        uint256 reward;
        bool isClaim;
    }

     mapping(uint256 => MatchInfo) public idToMatchInfo;
     mapping(uint256 => mapping(uint256 => BetInfo)) public idToBetInfo;

    constructor() {
    }

    function createMatch(string memory _matchCode) public onlyOwner{
        uint256 itemId = matchIds.current();
        idToMatchInfo[itemId] = MatchInfo(
            itemId,
            _matchCode,
            0,
            0,
            false
        );
        matchIds.increment();
    }

    function updateMatch(
        uint256 _matchId,
        uint256 _scoreA,
        uint256 _scoreB
    ) public onlyOwner{
        idToMatchInfo[_matchId].scoreA = _scoreA;
        idToMatchInfo[_matchId].scoreB = _scoreB;
        idToMatchInfo[_matchId].isStopBet = true;
    }


    function userBet(
        uint256 _matchId,
        MatchResult _bet,
        uint256 _amount,
        Odds memory _odds,
        uint256 _reward,
        bytes memory _hashedMessage
    ) public{
        bool isValid = verifyMessage(_reward, _hashedMessage);
        require(isValid);
        uint256 itemId = betIds.current();
        idToBetInfo[itemId][_matchId] = BetInfo(
            itemId,
            _matchId,
            _bet,
            _odds,
            _amount,
            _reward,
            false
        );
        betIds.increment();
    }

    function userClaim(uint256 betId) public {
        // claim logic
    }

    function verifyMessage(uint256 reward, bytes memory signature) public view  returns(bool) {
        bytes32 messageHash =  keccak256(bytes(Strings.toString(reward)));
       
        address signerAddress = messageHash.toEthSignedMessageHash().recover(signature);
              
        if (signerAddress==owner()) {
            return true;
        } else {
            return false;
        }
    }
}