// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

// Tertulia Smart Contract
// The entire platform is embedded in the contract
contract Tertulia {

    // Variable Declarations

    // Current budget provided by sponsors
    uint public totalBudget;

    // Number of debates
    uint public nDebates;

    // Boolean variable to determine if the current debate prize has been distributed
    bool public poolDistributed;
    // Boolean variable to determine if the current debate has started
    bool public debateStarted;

    // Debate-Question information
    struct Debate {
        uint pool;
        string sponsor;
        string sponsor_url; 
        string question; 
        uint topic;
    }

    // Information of current debate
    Debate public currentDebate;
    // Information of all debates
    Debate[] public debates;

    // Different medals awarded to users
    enum Medal {Default, Knowledgeable, Enlightened, Omniscient}

    // User information {10 different subject medals}
    struct User {
        Medal[10] medals;
        uint[10] medals_votes;
        mapping(uint256 => UserDebate) userDebates;
    }

    // All user information
    mapping(address => User) users;

    // Debate information by user
    struct UserDebate {
        uint[] userArguments; // links to argument uint
        uint[] votes; // links to argument uint

        uint nFirst;
        uint nResponses;
        uint nVotes;

        bool initialized;
    }

    // All debate information by user
    mapping(address => UserDebate) usersDebates;

    // Current users participating in the debate
    address[] currentUsers;

    // Argument information
    struct Argument {
        string text;
        address user;
        
        bool root;

        uint votes;
        address[] voters;

        uint argumentAbove;
        uint[] argumentsBelow;
    }

    // All arguments information of the current debate
    Argument[] public currentArguments;
    // Number of arguments of the current debate
    uint public nArguments;

    // All arguments information by debate
    Argument[][] public debatesArguments;

    // Sponsor information
    struct Sponsor{
        uint256 indentifier;
        address sponsorAddress;
        string sponsor;
        string url;
        uint value;
    }

    // List of all sponsors
    Sponsor[] sponsors;

    // Identifiers for sponsorship removal
    mapping(uint256 => bool) public identifiers;

    // Questions for debate & Constructor
    // IMPORTANT! Needs to be automated in the future
    struct Question {
        string question;
        uint topic;
    }

    Question[] questions;

    constructor() {
        questions.push(Question("Is social media more harmful than beneficial for society?", 0));
        questions.push(Question("Should the death penalty be abolished?", 1));
    }

    // Interaction Functions

    // Function to create a debate 
    // IMPORTANT! Needs to be automated in the future
    function createDebate () public {
        // Company fee: 10%
        uint fee = sponsors[sponsors.length - 1].value / 10;
        // Prize to be distributed
        uint prize = sponsors[sponsors.length - 1].value - fee;

        // Transfer fee to Company address
        payable(address(0)).transfer(fee);

        // Reduce totalBudget
        totalBudget -= sponsors[sponsors.length - 1].value;

        // Create new debate 
        Debate memory newDebate = Debate({
            pool: prize,
            sponsor: sponsors[sponsors.length-1].sponsor,
            sponsor_url: sponsors[sponsors.length-1].url,
            question: questions[nDebates].question,
            topic: questions[nDebates].topic
        });

        // Set new debate as current debate
        currentDebate = newDebate;
        // Add current debate to array of debates
        debates.push(newDebate);
        // Increase number of debates
        nDebates++;

        // Set new current variables to empty
        clearCurrentInformation();

        // Delete sponsor from list
        sponsors.pop();

        // Inform of debate started
        debateStarted = true;
    }

    // Sponsor Functions

    // Function to add a sponsor
    // Called by the sponsor's address
    // Requests company name and URL
    // Returns an identifier for sponsor removal
    function addSponsor(string memory _name, string memory _url) public payable returns (uint256) {
       
        // Increase Total Budget
        totalBudget += msg.value;

        // Generate Random Value
        uint256 random = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty)));
        // Check if the random value is already used
        while (identifiers[random]) {
            random = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty)));
        }
        // Set the identifier as being used
        identifiers[random] = true;

        // Create new Sponsor information
        Sponsor memory newSponsor = Sponsor(random, msg.sender, _name, _url, msg.value);

        // Add sponsor information to the sponsor list
        // The sponsor list is sorted in ascending order
        if (sponsors.length == 0) {
            sponsors.push(newSponsor);
        } else {
            bool added = false;
            for (uint i = 0; i < sponsors.length; i++) {
                if (newSponsor.value < sponsors[i].value) {
                    sponsors.push(Sponsor(0, address(0),"", "", 0));
                    for (uint j = sponsors.length - 1; j > i; j--) {
                        sponsors[j] = sponsors[j-1];
                    }
                    sponsors[i] = newSponsor;
                    added = true;
                    break;
                }
            }
            if (!added) {
                sponsors.push(newSponsor);
            }
        }
        // Return identifier to the sponsor in case they want to remove their listing
        return random;
    }

    // Function to delete a sponsor
    // Called by the sponsor's address
    // Requests identifier
    function deleteSponsor(uint256 _identifier) public {
        // Bool variable to check if sponsor listing found
        bool found = false;
        // Amount to be refunded
        uint refundedAmount;
    
        // Loop over sponsors to find sponsor to remove
        for (uint i = 0; i < sponsors.length; i++) {
            if (sponsors[i].indentifier == _identifier && msg.sender == sponsors[i].sponsorAddress) {
                refundedAmount = sponsors[i].value;
                found = true;
            }
            if (found && i < sponsors.length-1) {
                sponsors[i] = sponsors[i+1];
            }
        }
        if (found) {
            sponsors.pop();
            identifiers[_identifier] = false;
            payable(msg.sender).transfer(refundedAmount);
            totalBudget -= refundedAmount;
        }
    }

    // User Functions
    
    // Function to publish an argument in the current debate
    // Requests Text {Hash value if using IFPS}
    // Called by the user
    function publishArgument(string memory _text) public {
        require(usersDebates[msg.sender].nFirst == 0, "Only one Argument per debate");
        require(debateStarted, "Debate has not started yet");

        if (!usersDebates[msg.sender].initialized) {
            currentUsers.push(msg.sender);
        }

        // Create new Argument
        Argument memory newArgument = Argument({
            text: _text,
            user: msg.sender,
            root: true,
            votes: 0,
            voters: new address[](0),
            argumentAbove: 0,
            argumentsBelow: new uint[](0)
        });
        
        // Add the new argument to the list of current arguments
        currentArguments.push(newArgument);

        // Add a link to the current argument (using the index)
        usersDebates[msg.sender].userArguments.push(nArguments);
        // Ensure only one argument per user
        usersDebates[msg.sender].nFirst++;
        // Ensure mapping is initialized
        usersDebates[msg.sender].initialized = true;

        // Increase the number of arguments in the current debate
        nArguments++;
    }

    // Function to publish a response in the current debate
    // Requests text (hash value if using IPFS) and the argument responding to
    // Called by the user
    function publishResponse(string memory _text, uint _argumentAbove) public {
        require(usersDebates[msg.sender].nResponses < 3, "Only three responses per debate");
        require(debateStarted, "Debate has not started yet");

        if (!usersDebates[msg.sender].initialized) {
            currentUsers.push(msg.sender);
        }

        // Add the link of the response to the original argument
        currentArguments[_argumentAbove].argumentsBelow.push(nArguments);

        // Create new Response
        Argument memory newResponse = Argument({
            text: _text,
            user: msg.sender,
            root: false,
            votes: 0,
            voters: new address[](0),
            argumentAbove: _argumentAbove,
            argumentsBelow: new uint[](0)
        });
        
        // Add new Response to list of current arguments
        currentArguments.push(newResponse);

        // Add a link to the current argument information (using the index)
        usersDebates[msg.sender].userArguments.push(nArguments);
        // Ensure only one response per user
        usersDebates[msg.sender].nResponses++;
        // Ensure mapping is initialized
        usersDebates[msg.sender].initialized = true;

        // Increase the number of arguments in the current debate
        nArguments++;
    }

    // Function to publish an argument in the current debate
    // Requests argument voting to
    // Called by the user
    function voteArgument(uint _argument) public {
        require(usersDebates[msg.sender].nVotes < 3, "Only three votes per debate");
        require(debateStarted, "Debate has not started yet");

        if (!usersDebates[msg.sender].initialized) {
            currentUsers.push(msg.sender);
        }
        
        // Add user voter information to argument
        currentArguments[_argument].votes++;
        currentArguments[_argument].voters.push(msg.sender);

        // Add a link to the current argument information (using the index)
        usersDebates[msg.sender].votes.push(_argument);
        // Ensure only one vote per user
        usersDebates[msg.sender].nVotes++;
        // Ensure mapping is initialized
        usersDebates[msg.sender].initialized = true;
    }

    // DISTRIBUTE PRIZE FUNCTION - END OF DEBATE
    // IMPORTANT! Should be automated in the future!
    function distributePrize() public {
        require(poolDistributed == false, "Pool already distributed.");
        require(debateStarted == true, "Debate has not started yet.");

        uint currentPool = currentDebate.pool;

        uint n = currentArguments.length;
        uint n_users = currentUsers.length;

        uint[] memory topArguments = new uint[](n);

        for (uint i = 0; i < n; i++) {
            topArguments[i] = i;
        }

        for (uint i = 0; i < n_users; i++) {
            users[currentUsers[i]].userDebates[nDebates] = usersDebates[currentUsers[i]];
        }

        // Sort arguments based on vote count (descending order) 
        // Medal system voting should be develop in the future
        for (uint i = 0; i < n - 1; i++) {
            for (uint j = 0; j < n - i - 1; j++) {
                if (currentArguments[topArguments[j]].votes < currentArguments[topArguments[j + 1]].votes) {
                    (topArguments[j], topArguments[j + 1]) = (topArguments[j + 1], topArguments[j]);
                }
            }
        }

        // Distribute the prize equally among the top 20 arguments
        // May need to change to percentage in the future
        uint prizePerArgument = currentPool / 20;

        for (uint i = 0; i < 20 && i < n; i++) {
            address argumentCreator = currentArguments[topArguments[i]].user;
            payable(argumentCreator).transfer(prizePerArgument);
            currentPool -= prizePerArgument;
        }

        payable(address(0)).transfer(currentPool);
        currentPool = 0;
    }

    // VIEW CURRENT FUNCTIONS
    function getCurrentResponsesList(uint _argument) public view returns (uint[] memory) {
        return currentArguments[_argument].argumentsBelow;
    }

    function getCurrentVotersList(uint _argument) public view returns (address[] memory) {
        return currentArguments[_argument].voters;
    }

    // VIEW PAST FUNCTIONS
    function getResponsesList(uint _debate, uint _argument) public view returns (uint[] memory) {
        return debatesArguments[_debate][_argument].argumentsBelow;
    }

    function getVotersList(uint _debate, uint _argument) public view returns (address[] memory) {
        return debatesArguments[_debate][_argument].voters;
    }
    
    // INTERNAL FUNCTIONS
    function clearCurrentInformation() internal {
        for (uint256 i = 0; i < currentUsers.length; i++) {
            delete usersDebates[currentUsers[i]];
        }
        delete currentArguments;
        delete currentUsers;
        nArguments = 0;
    }
}
