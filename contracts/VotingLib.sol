// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library VotingLib {
    struct VotingData {
        mapping(address => bool) hasVoted;
        mapping(uint256 => uint256) votesReceived;
        uint256[] candidateIds;
        uint256 totalVotes;
    }

    function addCandidate(
        VotingData storage self,
        uint256 _candidateId
    ) public {
        require(msg.sender != address(0), "User not allowed");
        require(
            !isCandidateExists(self, _candidateId),
            "Candidate already exists"
        );
        self.candidateIds.push(_candidateId);
        self.votesReceived[_candidateId] = 0;
    }

    function isCandidateExists(
        VotingData storage self,
        uint256 _candidateId
    ) public view returns (bool) {
        require(msg.sender != address(0), "User not allowed");
        for (uint i = 0; i < self.candidateIds.length; i++) {
            if (self.candidateIds[i] == _candidateId) {
                return true;
            }
        }
        return false;
    }

    function castVote(
        VotingData storage self,
        uint256 _candidateId,
        address _voter
    ) public {
        require(msg.sender != address(0), "User not allowed");
        require(!self.hasVoted[_voter], "Voter has already voted");
        require(isCandidateExists(self, _candidateId), "Invalid candidate");

        self.hasVoted[_voter] = true;
        self.votesReceived[_candidateId]++;
        self.totalVotes++;
    }

    function getVotes(
        VotingData storage self,
        uint256 _candidateId
    ) public view returns (uint256) {
        require(msg.sender != address(0), "User not allowed");
        require(isCandidateExists(self, _candidateId), "Invalid candidate");
        return self.votesReceived[_candidateId];
    }

    function calculateWinner(
        VotingData storage self
    ) public view returns (uint256, uint256) {
        require(msg.sender != address(0), "User not allowed");
        require(self.totalVotes > 0, "No votes cast yet");

        uint256 winningVoteCount = 0;
        uint256 winningCandidateId = 0;

        for (uint i = 0; i < self.candidateIds.length; i++) {
            uint256 candidateId = self.candidateIds[i];
            uint256 voteCount = self.votesReceived[candidateId];

            if (voteCount > winningVoteCount) {
                winningVoteCount = voteCount;
                winningCandidateId = candidateId;
            }
        }

        return (winningCandidateId, winningVoteCount);
    }
}