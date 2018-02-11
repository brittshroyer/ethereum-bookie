pragma solidity ^0.4.11;

contract Casino {
   address owner;

   uint public minimumBet;
   uint public totalBet;
   uint public numberOfBets;
   uint public maxAmountOfBets = 100;
   address[] public players; // think array of player objects

   struct Player {  // think js object
      uint amountBet;
      uint numberSelected;
   }

   mapping(address => Player) playerInfo;

   function Casino(uint _minimumBet) public{
      owner = msg.sender;
      if(_minimumBet != 0) minimumBet = _minimumBet;
   }

   function kill() public{
      if(msg.sender == owner)
         selfdestruct(owner);
   }

  // ** payable means this function requires ether to be executed
   function bet(uint number) payable public {
     assert(checkPlayerExists(msg.sender) == false); // must make sure this player has NOT played already
     assert(number >= 1 && number <= 10); // must be betting within the 1-10 range
     assert(msg.value >= minimumBet); // must bet at least the minimum

     // msg.sender == address
     // msg.value == defined by user when he executes the contract
     playerInfo[msg.sender].amountBet = msg.value;
     playerInfo[msg.sender].numberSelected = number;
     numberOfBets += 1;
     players.push(msg.sender);
     totalBet += msg.value;

     if (numberOfBets >= maxAmountOfBets) generateNumberWinner();
   }

   function checkPlayerExists (address player) public view returns(bool){
     for (uint i = 0; i < players.length; i++) {
        if (players[i] == player) {
          return true;
        }
     }
     return false;
   }

   function generateNumberWinner() public{
     // probably not ideal way of generating random number
     uint numberGenerated = block.number % 10 + 1; // retrieves last digit of block number and adds 1. ex: previous block = 64783 will return 4 (3 + 1)
     distributePrizes(numberGenerated);
   }

   function distributePrizes(uint numberWinner) public{
     address[100] memory winners; // create an array of fixed size (100) that is store in memory ** memory variables get deleted after the function executes (probably pretty valuable feature given blockchain costs to store variables)
     uint count = 0;

     for (uint i = 0; i < players.length; i++) {
       address playerAddress = players[i];

       if (playerInfo[playerAddress].numberSelected == numberWinner) {
         winners[count] == playerAddress;
         count++;
       }
       delete playerInfo[playerAddress]; // deletes all players
     }

     players.length = 0; // remove all players from the players array (I think)

     uint winnerEtherAmount = totalBet / winners.length; // amount each winner receives

     for (uint j = 0; j < count; j++) {
       if (winners[j] != address(0)) { // making sure there is at least one address in the winners array
          winners[j].transfer(winnerEtherAmount);
       }

     }

     resetData();

   }

   function resetData() public{
     players.length = 0; // Delete all the players array
     totalBet = 0;
     numberOfBets = 0;
   }

   function() payable public {} // This is a fallback function

  // fallback functions are the only unnamed functions and must be used in order for contract to receive Ether.
  // gets executed whenever a call is made to contract without data or without an identifier that matches any function names on the contract


}
