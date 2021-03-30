pragma solidity ^0.4.24;

contract Lottery{
    address[] public players; //dynamic array with players addresses
    address public manager; //contract manager
    
    //contract constructor, runs once at contract deployment
    constructor() public{
        //the manager is account address that deploys the contract
        manager = msg.sender; 
    }
    
    //this fallback payable function will be automatically called when somebody
    //sends ether to our contract address
    function () payable public{
        require(msg.value >= 0.01 ether);
        players.push(msg.sender); //add the address of the account that sends
                                  //ether to players array
    }
    
    function get_balance() public view returns(uint){
        require(msg.sender == manager);
        return address(this).balance; //return contract balance
    }
    
    //returns a very big pseodo-random integer no.
    function random() public view returns(uint256){
       return uint256(keccak256(block.difficulty, block.timestamp, players.length));
    }
    
    function selectWinner() public {
        require(msg.sender == manager);
        

        uint r = random();
        
        address winner;
        
        //a random index
        uint index = r % players.length;
        winner = players[index];
        
        //transfer contract balance to the winner address
        winner.transfer(address(this).balance);
        
        players = new address[](0); //resetting the players dynamic array
    }
}

