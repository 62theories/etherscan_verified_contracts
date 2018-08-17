pragma solidity ^0.4.23;

// Deploying version: https://github.com/astralship/eos/tree/4a4929d7e434ff8f2aec148fd038f30fa3cf26e4
// Timestamp Converter: 1529279999
// Is equivalent to: 06/17/2018 @ 11:59pm (UTC)
// Sunday midnight, in a week &#128526;

contract Auction {
  
  string public description;
  string public instructions; // will be used for delivery address or email
  uint public price;
  bool public initialPrice = true; // at first asking price is OK, then +25% required
  uint public timestampEnd;
  address public beneficiary;
  bool public finalized = false;

  address public owner;
  address public winner;
  mapping(address =&gt; uint) public bids;
  address[] public accountsList; // so we can iterate: https://ethereum.stackexchange.com/questions/13167/are-there-well-solved-and-simple-storage-patterns-for-solidity

  // THINK: should be (an optional) constructor parameter?
  // For now if you want to change - simply modify the code
  uint public increaseTimeIfBidBeforeEnd = 24 * 60 * 60; // Naming things: https://www.instagram.com/p/BSa_O5zjh8X/
  uint public increaseTimeBy = 24 * 60 * 60;
  

  event Bid(address indexed winner, uint indexed price, uint indexed timestamp);
  event Refund(address indexed sender, uint indexed amount, uint indexed timestamp);
  
  modifier onlyOwner { require(owner == msg.sender, &quot;only owner&quot;); _; }
  modifier onlyWinner { require(winner == msg.sender, &quot;only winner&quot;); _; }
  modifier ended { require(now &gt; timestampEnd, &quot;not ended yet&quot;); _; }

  function setDescription(string _description) public onlyOwner() {
    description = _description;
  }

  function setInstructions(string _instructions) public ended() onlyWinner()  {
    instructions = _instructions;
  }

  constructor(uint _price, string _description, uint _timestampEnd, address _beneficiary) public {
    require(_timestampEnd &gt; now, &quot;end of the auction must be in the future&quot;);
    owner = msg.sender;
    price = _price;
    description = _description;
    timestampEnd = _timestampEnd;
    beneficiary = _beneficiary;
  }

  function() public payable {

    if (msg.value == 0) { // when sending `0` it acts as if it was `withdraw`
      refund();
      return;
    }

    require(now &lt; timestampEnd, &quot;auction has ended&quot;); // sending ether only allowed before the end

    if (bids[msg.sender] &gt; 0) { // First we add the bid to an existing bid
      bids[msg.sender] += msg.value;
    } else {
      bids[msg.sender] = msg.value;
      accountsList.push(msg.sender); // this is out first bid, therefore adding 
    }

    if (initialPrice) {
      require(bids[msg.sender] &gt;= price, &quot;bid too low, minimum is the initial price&quot;);
    } else {
      require(bids[msg.sender] &gt;= (price * 5 / 4), &quot;bid too low, minimum 25% increment&quot;);
    }
    
    if (now &gt; timestampEnd - increaseTimeIfBidBeforeEnd) {
      timestampEnd = now + increaseTimeBy;
    }

    initialPrice = false;
    price = bids[msg.sender];
    winner = msg.sender;
    emit Bid(winner, price, now);
  }

  function finalize() public ended() onlyOwner() {
    require(finalized == false, &quot;can withdraw only once&quot;);
    require(initialPrice == false, &quot;can withdraw only if there were bids&quot;);

    finalized = true;
    beneficiary.transfer(price);
  }

  function refundContributors() public ended() onlyOwner() {
    bids[winner] = 0; // setting it to zero that in the refund loop it is skipped
    for (uint i = 0; i &lt; accountsList.length;  i++) {
      if (bids[accountsList[i]] &gt; 0) {
        uint refundValue = bids[accountsList[i]];
        bids[accountsList[i]] = 0;
        accountsList[i].transfer(refundValue); 
      }
    }
  }   

  function refund() public {
    require(msg.sender != winner, &quot;winner cannot refund&quot;);
    require(bids[msg.sender] &gt; 0, &quot;refunds only allowed if you sent something&quot;);

    uint refundValue = bids[msg.sender];
    bids[msg.sender] = 0; // reentrancy fix, setting to zero first
    msg.sender.transfer(refundValue);
    
    emit Refund(msg.sender, refundValue, now);
  }

}