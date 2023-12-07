// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./ElectionManager.sol";

contract CitizenManager is ElectionManager {
    // Event emitted when a voter has cast a vote
    event HasVoted(address Voter, uint256 _electionID);
    event GotAVote(uint256 _candidateId, uint256 _electionID);

    // Function to add a new Voter for an Election
    function addVoter(
        uint _electionID,
        uint _nip,
        address _citizenAddress,
        uint8 _circonscription
    ) external onlyOwner electionNotStarted(_electionID) {
        users.push(Citizen(_nip, _citizenAddress, _circonscription));
        hasVoted[_electionID][_citizenAddress] = false;
        hasRigthToVote[_electionID][_citizenAddress] = true;
    }
    
    // Function for a Citizen to cast a vote
    function vote(
        uint256 _candidateId,
        uint256 _electionID,
        uint8 _circonscription
    ) external electionOngoing(_electionID) isCandidate(_candidateId, _electionID) {
        require(
            hasRigthToVote[_electionID][msg.sender] == true,
            "You aren't on the electoral list"
        );
        require(
            hasVoted[_electionID][msg.sender] == false,
            "You've already voted on this election"
        );

        // Check if the candidate is delegated and update _candidateId accordingly
        while (candidates[_candidateId].delegated == true) {
            for (uint256 i = 0; i < candidates.length; i++) {
                if (candidates[i].candidateAddress == candidates[_candidateId].candidateAddress && i != _candidateId) {
                    _candidateId = i;
                }
            }
        }

        // Increment the votes for the chosen candidate in the specified circonscription
        candidates[_candidateId].votesByCirconscription[_circonscription]++;
        
        // Increment the total votes in the election
        elections[_electionID].totalVotes++;
		
		// Write on the Blockchain
		// -------

        // Emit event indicating a vote was cast
        emit GotAVote(_candidateId, _electionID);

        // Mark the sender as having voted in this election
        hasVoted[_electionID][msg.sender] = true;
        emit HasVoted(msg.sender, _electionID);
    }

    // Function to retrieve details of a specific Voter
    function getVoter(uint i) public view returns (uint, address, uint8) {
        return (users[i].nip, users[i].citizenAddress, users[i].circonscription);
    }

    // Other functions related to managing citizens...
}