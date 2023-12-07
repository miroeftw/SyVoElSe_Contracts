// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./ScrutinManager.sol";

contract ScrutinUNI is ModelScrutin, ScrutinManager {
    // Function to compile results for Scrutin uninominal majoritaire à deux tours (First-past-the-post, two-round system)
    function compile(uint _electionID) external override {
        // Variables to store positions and votes
        uint pos = 0;
        uint votesI = 0;
        uint votesPos = 0;
        uint votesPos2 = 0;

        // Finding the winner based on highest votes (first round)
        for(uint i = 1; i < candidates.length; i++){
            if(listCandidatesPerElection[_electionID][i] == true && candidates[i].delegated == false){
                votesI = 0;
                votesPos = 0;
                // Calculate total votes per candidate for all circonscriptions
                for(uint8 j = 0; j < elections[_electionID].nbCirconscription; j++){
                    votesI += candidates[i].votesByCirconscription[j];
                }
                // Check if this candidate has more votes
                if(votesI > votesPos){
                    pos = i;
                    votesPos = votesI;
                }
            }
        }
        // Emit event for winner of first round
        emit Winner(_electionID, elections[_electionID].name, elections[_electionID].scrutinID, pos, candidates[pos].name, votesPos);

        // In case there are more than 2 candidates, proceed to second round
        if(candidates.length != 2){
            uint pos2 = 0;
            // Find the winner for the second round
            for(uint i = 1; i < candidates.length; i++){
                if(listCandidatesPerElection[_electionID][i] == true && candidates[i].delegated == false){
                    if(i != pos){
                        votesI = 0;
                        votesPos2 = 0;
                        // Calculate total votes per candidate for all circonscriptions in the second round
                        for(uint8 j = 0; j < elections[_electionID].nbCirconscription; j++){
                            votesI += candidates[i].votesByCirconscription[j];
                        }
                        // Check if this candidate has more votes
                        if(votesI > votesPos2){
                            pos2 = i;
                            votesPos2 = votesI;
                        }
                    }
                }
            }
            // Emit event for winner of the second round
            emit Winner(_electionID, elections[_electionID].name, elections[_electionID].scrutinID, pos2, candidates[pos2].name, votesPos2);
        }
    }
    // Can add other functions or events specific to ScrutinUNI as needed
}
