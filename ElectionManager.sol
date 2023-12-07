// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./Ownable.sol";

contract ElectionManager is Ownable {
    // Struct to store details of a Scrutin (voting system)
    struct Scrutin {
        string designation;
        string description;
        address scrutinAddress;
    }

    Scrutin[] scrutins; // Array to hold multiple Scrutins

    // Struct to store details of an Election
    struct Election {
        string name;
        uint scrutinID;
        uint startTime;
        uint endTime;
        uint8 nbCirconscription;
        uint8[] seatsByCirconscription;
        uint totalVotes;
        bool delegateTracker;
    }

    Election[] elections; // Array to hold multiple Elections

    // Struct to represent a Candidate in an Election
    struct Candidate {
        string name;
        address candidateAddress;
        uint[] votesByCirconscription;
        bool delegated;
    }

    Candidate[] candidates; // Array to hold multiple Candidates

    // Mapping to track candidates for each election
    mapping(uint => mapping(uint => bool)) listCandidatesPerElection;

    // Array to store Citizen details
    struct Citizen {
        uint256 nip; // Numéro d'identification personnel ou autre...
        address citizenAddress;
        uint8 circonscription; // Les différentes circonscriptions seront numérotées.
    }

    Citizen[] users; // Array to hold multiple Citizens

    // Mapping to track voter rights and voted status for each election
    mapping(uint256 => mapping(address => bool)) hasRigthToVote;
    mapping(uint256 => mapping(address => bool)) hasVoted;

    // Modifier to check if election has not started yet
    modifier electionNotStarted(uint _electionID){
        require(elections[_electionID].startTime >= block.timestamp, "This election has already started");
        _;
    }

    // Modifier to check if election is ongoing
    modifier electionOngoing(uint _electionID){
        require(elections[_electionID].startTime <= block.timestamp, "This election hasn't started yet");
        require(elections[_electionID].endTime >= block.timestamp, "This election has ended");
        _;
    }

    // Modifier to check if election has ended
    modifier electionEnded(uint _electionID){
        require(elections[_electionID].endTime > block.timestamp, "This election has ended");
        _;
    }

    // Modifier to check if a given ID corresponds to a Candidate in a specific Election
    modifier isCandidate(uint256 _candidateId, uint256 _electionID) {
        require(listCandidatesPerElection[_electionID][_candidateId] == true, "Not a candidate for this election");
        _;
    }

    // Event emitted when a new Election is added
    event NewElection(uint electionID, string _name, uint _scrutinID, uint _startTime, uint _endTime, uint8 _nbCirconscription);

    // Event emitted when a compiler is added for an election
    event AddCompiler(uint _electionID, address compiler);

    // Function to add a new Election
    function addElection (
        string memory _name,
        uint _scrutinID,
        uint _startTime,
        uint _endTime,
        uint8 _nbCirconscription,
        bool _delegateTracker
    ) external onlyOwner {
        require(_startTime <= block.timestamp, "The starting time input is unacceptable");
        require(_startTime < _endTime, "The ending time input is unacceptable");

        uint8[] memory seatsByCirconscription;
        elections.push(Election(_name, _scrutinID, _startTime, _endTime, _nbCirconscription, seatsByCirconscription, 0, _delegateTracker));
        uint electionID = elections.length - 1;
        emit NewElection(electionID, _name, _scrutinID, _startTime, _endTime, _nbCirconscription);
    }

    // Function to add a compiler for an election (internal function, accessible only by contract)
    function addCompiler(address _compiler, uint _electionID) internal onlyOwner {
        emit AddCompiler(_electionID, _compiler);
    }

    // Function to retrieve details of a specific Election
    function getElection(uint i) public view returns (
        string memory,
        uint,
        uint,
        uint,
        uint8,
        uint,
        bool
    ) {
        return (
            elections[i].name,
            elections[i].scrutinID,
            elections[i].startTime,
            elections[i].endTime,
            elections[i].nbCirconscription,
            elections[i].totalVotes,
            elections[i].delegateTracker
        );
    }

    // Other functions for managing elections...
}
