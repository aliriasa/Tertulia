// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Tertulia {

    uint private total_budget;
    uint private total_sponsors;
    
    uint public num_debates;

    struct Question {
        uint pool;
        string sponsor;
        string sponsor_url; 
        string question; 
    }

    Question public current_debate;
    Question[] public debates;

    enum Medal {Default, Knowledgeable, Enlightened, Omniscient}
    
    struct User {
        Medal[10] medals;
        mapping(uint256 => User_Question) user_questions;
    }

    struct User_Question {
        uint[] user_arguments;
        uint[] votes;

        uint n_first;
        uint n_answers;
        uint n_votes;
    }

    struct Argument {
        string text;
        address person;
        
        bool root;

        uint votes;
        address[] voters;

        uint argument_above;
        uint[] arguments_below;
    }

    struct Sponsor{
        uint256 indentifier;
        address sponsor_address;
        string sponsor;
        string url;
        uint value;
    }

    Sponsor[] sponsors;
    mapping(uint256 => bool) public indentifiers;

    string[] private questions;
    constructor() {
        questions.push("Is social media more harmful than beneficial for society?");
        questions.push("Should the death penalty be abolished?");
    }

    function createDebate () public {
        uint _fee = sponsors[sponsors.length-1].value / 10;
        uint _pool = sponsors[sponsors.length-1].value - _fee;
        payable(address(0)).transfer(_fee);

        Question memory newDebate = Question({
            pool: _pool,
            sponsor: sponsors[sponsors.length-1].sponsor,
            sponsor_url: sponsors[sponsors.length-1].url,
            question: questions[num_debates]
        });

        current_debate = newDebate;
        debates.push(newDebate);
        num_debates++;
    }

    function addSponsor(string memory _name, string memory _url) public payable returns (uint256) {
        total_budget += msg.value;
        uint256 random = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty)));
        
        while (indentifiers[random]) {
            random = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty)));
        }

        indentifiers[random] = true;

        Sponsor memory newSponsor = Sponsor(random, msg.sender, _name, _url, msg.value);

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
        return random;
    }

    function deleteSponsor(uint256 _identifier) public {
        bool found = false;
        uint refundedAmount;
        address sponsor_address;

        for (uint i = 0; i < sponsors.length-1; i++) {
            if (sponsors[i].indentifier == _identifier) {
                sponsor_address = sponsors[i].sponsor_address;
                refundedAmount = sponsors[i].value;
                found = true;
            }
            if (found) {
                sponsors[i] = sponsors[i+1];
            }
        }

        if (!found) {
            sponsor_address = sponsors[sponsors.length-1].sponsor_address;
            refundedAmount = sponsors[sponsors.length-1].value;
            found = true;
        }
        sponsors.pop();
        indentifiers[_identifier] = false;
        payable(sponsor_address).transfer(refundedAmount);
        total_budget -= refundedAmount;
    }

}