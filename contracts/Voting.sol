// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;
import "./VotingLib.sol";

contract Voting {
    using VotingLib for VotingLib.VotingData;

    VotingLib.VotingData private votingData;
    address public owner;
    bool public votingOpen;

    event VoteCast(address indexed voter, uint256 candidateId);
    event CandidateAdded(uint256 candidateId);
    event VotingStatusChanged(bool isOpen);

    modifier onlyOwner() {
        require(msg.sender != address(0), "User not allowed");
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier votingIsOpen() {
        require(msg.sender != address(0), "User not allowed");
        require(votingOpen, "Voting is not open");
        _;
    }

    constructor() {
        owner = msg.sender;
        votingOpen = false;
    }

    function startVoting() external onlyOwner {
        votingOpen = true;
        emit VotingStatusChanged(true);
    }

    function endVoting() external onlyOwner {
        votingOpen = false;
        emit VotingStatusChanged(false);
    }

    function addCandidate(uint256 _candidateId) external onlyOwner {
        votingData.addCandidate(_candidateId);
        emit CandidateAdded(_candidateId);
    }

    function vote(uint256 _candidateId) external votingIsOpen {
        votingData.castVote(_candidateId, msg.sender);
        emit VoteCast(msg.sender, _candidateId);
    }

    function getVotesForCandidate(
        uint256 _candidateId
    ) external view returns (uint256) {
        return votingData.getVotes(_candidateId);
    }

    function getWinner()
        external
        view
        returns (uint256 winningCandidateId, uint256 winningVoteCount)
    {
        return votingData.calculateWinner();
    }

    function hasVoted(address _voter) external view returns (bool) {
        return votingData.hasVoted[_voter];
    }
}