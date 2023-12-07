// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./ElectionManager.sol";

contract CandidateManager is ElectionManager {
    // Event emitted when a new Candidate is added
    event NewCandidate(uint256 candidateId, string name, uint256 electionID);
    
    // Event emitted when a candidate delegates their votes
    event HasDelegated(address candidateDelegating, uint256 candidateId, uint256 electionID);

    // Function to add a new Candidate for an Election
    function addCandidate(
        uint256 _electionID,
        string memory _name,
        address _candidateAddress
    ) external onlyOwner electionNotStarted(_electionID) {
        uint256[] memory initVotesByCirconscription;
        for (uint8 i = 0; i < elections[_electionID].nbCirconscription; i++) {
            initVotesByCirconscription[i] = 0;
        }

        candidates.push(Candidate(_name, _candidateAddress, initVotesByCirconscription, false));
        uint256 candidateId = candidates.length - 1;

        listCandidatesPerElection[_electionID][candidateId] = true;
        
        emit NewCandidate(candidateId, _name, _electionID);
    }

    // Function to delegate votes from one candidate to another
    function delegateVote(
        uint256 _myId,
        uint256 _candidateId,
        uint256 _electionID
    ) external isCandidate(_myId, _electionID) isCandidate(_candidateId, _electionID) electionOngoing(_electionID) {
        require(candidates[_myId].candidateAddress == msg.sender, "You aren't a candidate for this election");

        // Loop to handle delegate chains until reaching a non-delegated candidate
        while (candidates[_candidateId].delegated == true) {
            for (uint256 i = 0; i < candidates.length; i++) {
                if (candidates[i].candidateAddress == candidates[_candidateId].candidateAddress && i != _candidateId) {
                    _candidateId = i;
                }
            }
        }

        // Delegate votes to the chosen candidate for each circonscription
        for (uint8 i = 0; i < elections[_electionID].nbCirconscription; i++) {
            candidates[_candidateId].votesByCirconscription[i] += candidates[_myId].votesByCirconscription[i];
            candidates[_myId].votesByCirconscription[i] = 0; // Zero out the votes from the sender
        }

        // Update the candidate's address and mark as delegated
        candidates[_myId].delegated = true;
        candidates[_myId].candidateAddress = candidates[_candidateId].candidateAddress;
		
		// Write on the Blockchain
		// -------

        // Emit event indicating a successful delegation
        emit HasDelegated(msg.sender, _candidateId, _electionID);
    }

    // Function to retrieve details of a specific Candidate
    function getCandidate(uint i) public view returns (string memory, address) {
        return (candidates[i].name, candidates[i].candidateAddress);
    }

    // Other functions related to candidate management...
}
