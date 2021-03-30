pragma solidity ^0.4.24;

contract FundRaising{
    //contributors to the FundRaising Campaign
    mapping(address => uint) public contributors;
    
    address public admin;
    uint public noOfContributors;
    uint public minimumContribution;
    uint public deadline; //this is a timestamp (seconds)
    //amount that must be raised for a successful Campaign
    uint public goal;
    uint public raisedAmount = 0;
    
    //Spending Request created by admin, must be voted by donors
    struct Request{
        string description;
        address recipient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address => bool) voters;
    }
    
    //dynamic array of requests
    Request[] public requests;

    event ContributeEvent(address sender, uint value);
    event CreateRequestEvent(string _description, address _recipient, uint _value);
    event MakePaymentEvent(address recipient, uint value);

    constructor(uint _goal, uint _deadline) public{
        goal = _goal;
        deadline = now + _deadline;
        
        admin = msg.sender;
        minimumContribution = 10;
    }
    
   
   
    modifier onlyAdmin(){
        require(msg.sender == admin);
        _;
    }
   
   
    function contribute() public payable{
        require(now < deadline);
        require(msg.value >= minimumContribution);
        
        if(contributors[msg.sender] == 0){
            noOfContributors++;
        }
        
        contributors[msg.sender] += msg.value;
        raisedAmount += msg.value;
        emit ContributeEvent(address sender, uint value);
    }
    
    function getBalance() public view returns(uint){
        return address(this).balance;
    }
    
    //refund if goal not met within deadline
    function getRefund() public{
        require(now > deadline);
        require(raisedAmount < goal);
        require(contributors[msg.sender] > 0);
        
        address recipient = msg.sender;
        uint value = contributors[msg.sender];
        
        recipient.transfer(value);
        contributors[msg.sender] = 0;
        
        
    }
    
    
    //admin creates spending request
    function createRequest(string _description, address _recipient, uint _value) public onlyAdmin {
        Request memory newRequest = Request({
           description: _description,
           recipient: _recipient,
           value: _value,
           completed: false,
           noOfVoters: 0
        
            
        });
    
        requests.push(newRequest);
        emit CreateRequestEvent(string _description, address _recipient, uint _value);
    }
    
    

    //contributors vote for a request
  function voteRequest(uint index) public{
      Request storage thisRequest = requests[index];
    
      require(contributors[msg.sender] > 0);
      require(thisRequest.voters[msg.sender] == false);
      
      thisRequest.voters[msg.sender] = true;
      thisRequest.noOfVoters++;
      
  }
    
    //if voted, owner sends money to the recipient (vendor, seller)
    function makePayment(uint index) public onlyAdmin{
        Request storage thisRequest  = requests[index];
        require(thisRequest.completed == false);
        
        require(thisRequest.noOfVoters > noOfContributors / 2);//more than 50% voted
        thisRequest.recipient.transfer(thisRequest.value); //trasfer the money to the recipient
        
        thisRequest.completed = true;
        emit MakePaymentEvent(address recipient, uint value);
    }
    
}
