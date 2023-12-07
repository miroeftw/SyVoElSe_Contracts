// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./ScrutinManager.sol";

contract ScrutinRP is ModelScrutin, ScrutinManager {
    // Function to compile results for Scrutin proportionnel plurinominal
    function compile(uint _electionID) external override {
        // Logic for Scrutin proportionnel plurinominal
        for(uint i = 0; i < candidates.length; i++){
            if(listCandidatesPerElection[_electionID][i] == false){
                candidates[i] = candidates[candidates.length - 1];
                candidates.pop();
            }
        }

        uint8 seuilElectoral = 10; // 10% threshold for seats

        // Remove all lists not meeting the electoral threshold
        for(uint i = 0; i < candidates.length; i++){
            uint votesI = 0;
            for(uint8 j = 0; j < elections[_electionID].nbCirconscription; j++){
                votesI += candidates[i].votesByCirconscription[j];
            }
            if(votesI / elections[_electionID].totalVotes < seuilElectoral / 100){
                candidates[i] = candidates[candidates.length - 1];
                candidates.pop();
            }
        }

        // Calculate electoral quotient
        uint16 totalSeats;
        for(uint i = 0; i < elections[_electionID].seatsByCirconscription.length; i++){
            totalSeats += elections[_electionID].seatsByCirconscription[i];
        }
        uint quotientElectoral = elections[_electionID].totalVotes / totalSeats;

        // Process by circonscription
        for(uint8 circonscription = 0; circonscription <= elections[_electionID].nbCirconscription; circonscription++){
            uint[] memory selectedLists; // selected lists
            uint8[] memory seatsbyLists;

            // Calculate total votes per circonscription
            uint totalVotesCirconscription = 0;
            for(uint i = 0; i < candidates.length; i++){
                totalVotesCirconscription += candidates[i].votesByCirconscription[circonscription];
            }

            // Remove lists not meeting the electoral threshold for circonscription
            for(uint i = 0; i < candidates.length; i++){
                if(candidates[i].votesByCirconscription[circonscription] / totalVotesCirconscription < seuilElectoral / 100){
                    selectedLists[selectedLists.length] = i;
                }
            }
            emit SelectedList(_electionID, circonscription, selectedLists);

            // Use Hare quota method
            // First round
            for(uint i = 0; i < selectedLists.length; i++){
                while(candidates[selectedLists[i]].votesByCirconscription[circonscription] >= quotientElectoral){
                    candidates[selectedLists[i]].votesByCirconscription[circonscription] -= quotientElectoral;
                    seatsbyLists[i]++;
                    elections[_electionID].seatsByCirconscription[circonscription]--;
                }
            }

            // Second round
            while(elections[_electionID].seatsByCirconscription[circonscription] > 0){
                uint maxRemain = 0;
                for(uint i = 0; i < selectedLists.length; i++){
                    if(candidates[selectedLists[i]].votesByCirconscription[circonscription] > candidates[selectedLists[maxRemain]].votesByCirconscription[circonscription]){
                        maxRemain = i;
                    }
                }
                candidates[selectedLists[maxRemain]].votesByCirconscription[circonscription] = 0;
                seatsbyLists[maxRemain]++;
                elections[_electionID].seatsByCirconscription[circonscription]--;
            }

            emit RepartitionSeatsForCirconscription(_electionID, circonscription, selectedLists, seatsbyLists);
        }

        // Rest of the ScrutinRP logic, e.g., positive discrimination for women, can be added here
    }
    // Can add other functions or events specific to ScrutinRP as needed
}