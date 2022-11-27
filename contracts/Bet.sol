// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;

import '@openzeppelin/contracts/utils/Counters.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import '@openzeppelin/contracts/utils/cryptography/ECDSA.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC1155/IERC1155.sol';

import './interfaces/IStarTicket.sol';
import './libraries/VerifyBetInfo.sol';

contract Bet is Ownable {
    using ECDSA for bytes32;
    using Counters for Counters.Counter;

    uint8 constant NOT_END = 0;
    uint8 constant A_WIN = 1;
    uint8 constant DRAW = 2;
    uint8 constant B_WIN = 3;

    uint8 constant FIRST_HALF = 0;
    uint8 constant SECOND_HALF = 1;
    uint8 constant FULLTIME = 2;

    Counters.Counter public matchIds;
    Counters.Counter public betIds;
    address public treasury;
    address public agbToken;
    address public starTicket;
    mapping(uint256 => MatchInfo) public idToMatchInfo;
    mapping(uint256 => BetInfo) public idToBetInfo;

    event MatchStatus(
        uint256 itemId,
        string matchCode,
        uint8 firstHalfResult,
        uint8 secondHalfResult,
        uint8 fulltimeResult
    );

    event BetStatus(
        uint256 betId,
        uint256 matchId,
        uint8 betType,
        uint8 betResult,
        uint16 oddsBet, // 2/100 ~ 0.02
        uint256 amount,
        uint8 starTicketId,
        address user,
        bool isClaim
    );

    struct MatchInfo {
        uint256 itemId;
        string matchCode;
        uint8 firstHalfResult;
        uint8 secondHalfResult;
        uint8 fulltimeResult;
    }

    struct BetInfo {
        uint256 betId;
        uint256 matchId;
        uint8 betType;
        uint8 betResult;
        uint16 oddsBet; // 2/100 ~ 0.02
        uint256 amount;
        uint8 starTicketId;
        address user;
        bool isClaim;
    }

    constructor(
        address _treasury,
        address _agbToken,
        address _starTicket
    ) {
        treasury = _treasury;
        agbToken = _agbToken;
        starTicket = _starTicket;
    }

    function createMatch(string memory _matchCode) public onlyOwner {
        uint256 itemId = matchIds.current();
        idToMatchInfo[itemId] = MatchInfo(itemId, _matchCode, 0, 0, 0);
        matchIds.increment();
        emit MatchStatus(
            itemId,
            _matchCode,
            0,
            0,
            0
        );
    }

    function updateFirstHalf(uint256 _matchId, uint8 _result) public onlyOwner {
        MatchInfo memory matchInfo = idToMatchInfo[_matchId];
        require(matchInfo.firstHalfResult == NOT_END, 'First half was updated');
        idToMatchInfo[_matchId].firstHalfResult = _result;
        emit MatchStatus(
            _matchId,
            matchInfo.matchCode,
            _result,
            0,
            0
        );
    }

    function updateSecondHalf(uint256 _matchId, uint8 _result)
    public
    onlyOwner
    {
        MatchInfo memory matchInfo = idToMatchInfo[_matchId];
        require(
            matchInfo.firstHalfResult != NOT_END,
            'First half was not updated'
        );
        require(
            matchInfo.secondHalfResult == NOT_END,
            'Second half was updated'
        );
        idToMatchInfo[_matchId].secondHalfResult = _result;
        emit MatchStatus(
            _matchId,
            matchInfo.matchCode,
            matchInfo.firstHalfResult,
            _result,
            0
        );
    }

    function updateFulltime(uint256 _matchId, uint8 _result) public onlyOwner {
        MatchInfo memory matchInfo = idToMatchInfo[_matchId];
        require(
            matchInfo.firstHalfResult != NOT_END,
            'First half was not updated'
        );
        require(
            matchInfo.secondHalfResult != NOT_END,
            'Second half was not updated'
        );
        require(matchInfo.fulltimeResult == NOT_END, 'Fulltime was updated');
        idToMatchInfo[_matchId].fulltimeResult = _result;
        emit MatchStatus(
            _matchId,
            matchInfo.matchCode,
            matchInfo.firstHalfResult,
            matchInfo.secondHalfResult,
            _result
        );
    }

    function userBet(
        uint256 _matchId,
        uint8 _betType,
        uint256 _amount,
        uint16 _oddsBet,
        uint8 _betResult,
        uint8 _starTicketId,
        bytes memory _hashedMessage
    ) public {
        MatchInfo memory matchInfo = idToMatchInfo[_matchId];
        require(_betResult != NOT_END, 'This bet result is invalid');
        bool isValidBet = true;
        if (_betType == FIRST_HALF && matchInfo.firstHalfResult != NOT_END) {
            isValidBet = false;
        }
        if (_betType == SECOND_HALF && matchInfo.secondHalfResult != NOT_END) {
            isValidBet = false;
        }
        if (_betType == FULLTIME && matchInfo.fulltimeResult != NOT_END) {
            isValidBet = false;
        }
        require(isValidBet, 'This bet information is invalid');
        isValidBet = VerifyBetInfo.verify(
            owner(),
            _matchId,
            _betType,
            _betResult,
            _amount,
            _oddsBet,
            _hashedMessage
        );
        require(isValidBet, 'This bet signature is invalid');
        if (_starTicketId > 0) {
            require(
                IERC1155(starTicket).balanceOf(msg.sender, _starTicketId) > 0,
                'Star ticket is invalid'
            );
        }
        uint256 itemId = betIds.current();
        idToBetInfo[itemId] = BetInfo(
            itemId,
            _matchId,
            _betType,
            _betResult,
            _oddsBet,
            _amount,
            _starTicketId,
            msg.sender,
            false
        );
        betIds.increment();
        IERC20(agbToken).transferFrom(msg.sender, treasury, _amount);
        if (_starTicketId > 0) {
            IERC1155(starTicket).safeTransferFrom(msg.sender, treasury, _starTicketId, 1, '');
        }
        emit BetStatus(
            itemId,
            _matchId,
            _betType,
            _betResult,
            _oddsBet,
            _amount,
            _starTicketId,
            msg.sender,
            false
        );
    }

    function userClaim(uint256 _betId) public {
        BetInfo storage betInfo = idToBetInfo[_betId];
        MatchInfo memory matchInfo = idToMatchInfo[betInfo.matchId];
        require(msg.sender == betInfo.user, 'You are not owner of this bet');
        bool isValidClaim = true;
        if (
            betInfo.betType == FIRST_HALF &&
            matchInfo.firstHalfResult == NOT_END
        ) {
            isValidClaim = false;
        }
        if (
            betInfo.betType == SECOND_HALF &&
            matchInfo.secondHalfResult == NOT_END
        ) {
            isValidClaim = false;
        }
        if (
            betInfo.betType == FULLTIME && matchInfo.fulltimeResult == NOT_END
        ) {
            isValidClaim = false;
        }
        require(isValidClaim, 'This claim information is invalid');
        require(!betInfo.isClaim, 'User claimed');
        bool isWin = false;
        if (
            betInfo.betType == FIRST_HALF &&
            betInfo.betResult == matchInfo.firstHalfResult
        ) {
            isWin = true;
        }
        if (
            betInfo.betType == SECOND_HALF &&
            betInfo.betResult == matchInfo.secondHalfResult
        ) {
            isWin = true;
        }
        if (
            betInfo.betType == FULLTIME &&
            betInfo.betResult == matchInfo.fulltimeResult
        ) {
            isWin = true;
        }
        require(isWin, 'You lose');
        betInfo.isClaim = true;
        uint16 bonus = 0;
        if (betInfo.starTicketId > 0) {
            bonus = IStarTicket(starTicket).getBonusProfit(
                betInfo.starTicketId
            );
        }
        uint256 reward = (betInfo.oddsBet * betInfo.amount) /
        100 +
        (bonus * betInfo.amount * (betInfo.oddsBet - 100)) /
        100;
        IERC20(agbToken).transferFrom(treasury, msg.sender, reward);
        emit BetStatus(
            _betId,
            matchInfo.itemId,
            betInfo.betType,
            betInfo.betResult,
            betInfo.oddsBet,
            betInfo.amount,
            betInfo.starTicketId,
            msg.sender,
            true
        );
    }

    function getMessageHash(
        uint256 _matchId,
        uint8 _betType,
        uint8 _betResult,
        uint256 _amount,
        uint256 _oddsBet
    ) public pure returns (bytes32) {
        return
        keccak256(abi.encodePacked(_matchId, _betType, _betResult, _amount, _oddsBet));
    }
}
