import { EthProvider } from "./contexts/EthContext";
import React, { Component } from "react";
import Main from "./components/Main";
import Demo from "./components/Demo";
import Footer from "./components/Footer";
import Web3 from "web3";
import "./style.css";
import Platform from "../abis/Platform.json";
import Question from "../abis/Question.json";

//Declare IPFS
const ipfsClient = require("ipfs-http-client");
const ipfs = ipfsClient({
  host: "ipfs.infura.io",
  port: 5001,
  protocol: "https",
});

class App extends Component {

  async componentWillMount() {
    await this.loadWeb3()
    await this.loadBlockchainData()
  }

  async loadWeb3() {
    if (window.ethereum) {
      window.web3 = new Web3(window.ethereum)
      await window.ethereum.request({ method: 'eth_requestAccounts' })
    }
    else if (window.web3) {
      window.web3 = new Web3(window.web3.currentProvider)
    }
    else {
      window.alert('Non-Ethereum browser detected. You should consider trying MetaMask!')
    }
  }

  async loadBlockchainData() {
    const web3 = window.web3;
    // Load account
    const accounts = await web3.eth.getAccounts();
    this.setState({ account: accounts[0] });
    // Network ID
    const networkId = await web3.eth.net.getId();
    const networkData = Platform.networks[networkId];
  
    if (networkData) {
      const platform = new web3.eth.Contract(Platform.abi, networkData.address);
      this.setState({ platform });
      const num_debates = await platform.methods.num_debates().call();
      const questionAddresses = [];
  
      for (let i = 0; i < num_debates; i++) {
        const questionAddress = await platform.methods.debates(i).call();
        questionAddresses.push(questionAddress);
        const questionContract = new web3.eth.Contract(Question.abi, questionAddress);
        const n_arguments = await questionContract.methods.n_arguments().call();
        
        const question = questionContract.methods.question.call();
        const textList = [];
        const personList = [];
        const rootList = [];
        const votesList = [];
        // const votersList = []; cheese
        const argument_aboveList = [];
        // const argument_below = []; cheese
  
        for (let j = 0; j < n_arguments; j++) {
          const argument = await questionContract.methods.arguments(j).call();
          const text = argument.text;
          const person = argument.person;
          const root = argument.root;
          const votes = argument.votes;
          const argument_below = argument.below;

          // Read other struct variables as needed, e.g., argument.person, argument.root, etc.
          textList.push(text);
          personList.push(person);
          rootList.push(root);
          votesList.push(votes);
          argument_aboveList.push(argument_aboveList);
        }
  
        // Store the arguments list in the component's state
        this.setState(prevState => ({
          question: [...prevState.question, question],
          text: [...prevState.text, textList],
          person: [...prevState.person, personList],
          root: [...prevState.root, rootList],
          votes: [...prevState.votes, votesList],
          argument_above: [...prevState.argument_above, argument_aboveList],
        }));

        if (i < num_debates - 1) {
          this.setState(questionContract);
        }
      }
      // Store the question addresses in the component's state
      this.setState({ questionAddresses });
      this.setState({ loading: false });
    } else {
      window.alert("Platform contract not deployed to detected network.");
    }
  }

  publishArgument = (text) => {
    console.log("Submitting text to IPFS...");
    
    //adding file to the IPFS
    ipfs.add(text, (error, result) => {
      console.log("IPFS result", result);
      if (error) {
        console.error(error);
        return;
      }

      this.setState({ loading: true });
      this.state.questionContract.methods
        .publishArgument(result[0].hash)
        .send({ from: this.state.account })
        .on("transactionHash", (hash) => {
          this.setState({ loading: false });
        });
    });
  }

  constructor(props) {
    super(props);
    this.state = {
      account: "",
      question: [],
      text: [],
      person: [],
      root: [],
      votes: [],
      argument_above: [],
      platform: null,
      questionContract: null,
      questionAddress: [],
      loading: true,
    };
    this.publishArgument = this.publishArgument.bind(this);
  }

  render() {
    return (
      <div>
        <Demo account={this.state.account} />
        {this.state.loading ? (
          <div id="loader" className="text-center mt-5">
            <p>Loading...</p>
          </div>
        ) : (
          <Main
            question={this.state.question}
            text={this.state.text}
            person={this.state.person}
            root={this.state.root}
            votes={this.state.votes}
            argument_above={this.state.argument_above}
          />
        )}
        <Footer />
      </div>
    );
  }
}

export default App;
