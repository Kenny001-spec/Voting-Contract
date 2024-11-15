const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Voting Contract", function () {
    let Voting;
    let votingContract;
    let owner;
    let voter1;
    let voter2;

    beforeEach(async function () {
        [owner, voter1, voter2] = await ethers.getSigners();
        Voting = await ethers.getContractFactory("Voting");
        votingContract = await Voting.connect(owner).deploy();
        await votingContract.deployed();
    });

    it("Should set the deployer as the owner", async function () {
        expect(await votingContract.owner()).to.equal(owner.address);
    });

    it("Should allow the owner to add candidates", async function () {
        await votingContract.connect(owner).addCandidate(1);
        await votingContract.connect(owner).addCandidate(2);

        expect(await votingContract.getVotesForCandidate(1)).to.equal(0);
        expect(await votingContract.getVotesForCandidate(2)).to.equal(0);
    });

    it("Should not allow non-owners to add candidates", async function () {
        await expect(votingContract.connect(voter1).addCandidate(1)).to.be.revertedWith("Only owner can call this function");
    });

    it("Should start and end voting by the owner", async function () {
        await votingContract.connect(owner).startVoting();
        expect(await votingContract.votingOpen()).to.be.true;

        await votingContract.connect(owner).endVoting();
        expect(await votingContract.votingOpen()).to.be.false;
    });

    it("Should not allow non-owners to start or end voting", async function () {
        await expect(votingContract.connect(voter1).startVoting()).to.be.revertedWith("Only owner can call this function");
        await votingContract.connect(owner).startVoting();
        await expect(votingContract.connect(voter1).endVoting()).to.be.revertedWith("Only owner can call this function");
    });

    it("Should allow a voter to vote for a candidate", async function () {
        await votingContract.connect(owner).addCandidate(1);
        await votingContract.connect(owner).startVoting();

        await votingContract.connect(voter1).vote(1);
        expect(await votingContract.getVotesForCandidate(1)).to.equal(1);
    });

    it("Should not allow voting if voting is not open", async function () {
        await votingContract.connect(owner).addCandidate(1);

        await expect(votingContract.connect(voter1).vote(1)).to.be.revertedWith("Voting is not open");
    });

    it("Should not allow a voter to vote more than once", async function () {
        await votingContract.connect(owner).addCandidate(1);
        await votingContract.connect(owner).startVoting();

        await votingContract.connect(voter1).vote(1);

        await expect(votingContract.connect(voter1).vote(1)).to.be.revertedWith("Voter has already voted");
    });

    it("Should return the correct winner", async function () {
        await votingContract.connect(owner).addCandidate(1);
        await votingContract.connect(owner).addCandidate(2);
        await votingContract.connect(owner).startVoting();

        await votingContract.connect(voter1).vote(1);
        await votingContract.connect(voter2).vote(2);
        await votingContract.connect(owner).endVoting();

        const [winnerId, votes] = await votingContract.getWinner();
        expect(winnerId).to.equal(1); // Candidate 1 wins because they were added first
        expect(votes).to.equal(1);   // Both candidates received 1 vote, but first added candidate wins ties
    });

    it("Should allow users to check if they have voted", async function () {
        await votingContract.connect(owner).addCandidate(1);
        await votingContract.connect(owner).startVoting();

        expect(await votingContract.hasVoted(voter1.address)).to.be.false;
        await votingContract.connect(voter1).vote(1);
        expect(await votingContract.hasVoted(voter1.address)).to.be.true;
    });

    it("Should prevent adding the same candidate twice", async function () {
        await votingContract.connect(owner).addCandidate(1);
        await expect(votingContract.connect(owner).addCandidate(1)).to.be.revertedWith("Candidate already exists");
    });
});
