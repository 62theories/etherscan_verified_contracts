pragma solidity ^0.4.23;

// If you are reading this...
// This is a &quot;backup&quot; - deploying to the same address on mainnet and testnet
// Just in case someone accidentally sends Ether into ether
// Here is the Ropsten (testnet, monopoly money) address: https://ropsten.etherscan.io/address/0x6c1c2fd38fccc0b010f75b2ece535cf57543ddcd#code
// Learning stuff, heavily investing in skills and education
// If you can - hire me - https://genesis.re
// One disclaimer though - cannot handle bullshit jobs - only true leaders, only meaningful projects please :)

// File: contracts/Auction.sol

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
  function getAccountListLenght() public constant returns(uint) { return accountsList.length; } // lenght is not accessible from DApp, exposing convenience method: https://stackoverflow.com/questions/43016011/getting-the-length-of-public-array-variable-getter

  // THINK: should be (an optional) constructor parameter?
  // For now if you want to change - simply modify the code
  uint public increaseTimeIfBidBeforeEnd = 24 * 60 * 60; // Naming things: https://www.instagram.com/p/BSa_O5zjh8X/
  uint public increaseTimeBy = 24 * 60 * 60;
  

  event BidEvent(address indexed bidder, uint value, uint timestamp); // cannot have event and struct with the same name
  event Refund(address indexed bidder, uint value, uint timestamp);

  
  modifier onlyOwner { require(owner == msg.sender, &quot;only owner&quot;); _; }
  modifier onlyWinner { require(winner == msg.sender, &quot;only winner&quot;); _; }
  modifier ended { require(now &gt; timestampEnd, &quot;not ended yet&quot;); _; }


  function setDescription(string _description) public onlyOwner() {
    description = _description;
  }

  // TODO: Override this method in the derived functions, think about on-chain / off-chain communication mechanism
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

  // Same for all the derived contract, it&#39;s the implementation of refund() and bid() that differs
  function() public payable {
    if (msg.value == 0) {
      refund();
    } else {
      bid();
    }  
  }

  function bid() public payable {
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
    emit BidEvent(winner, msg.value, now); // THINK: I prefer sharing the value of the current transaction, the total value can be retrieved from the array
  }

  function finalize() public ended() onlyOwner() {
    require(finalized == false, &quot;can withdraw only once&quot;);
    require(initialPrice == false, &quot;can withdraw only if there were bids&quot;);

    finalized = true;
    beneficiary.transfer(price);
  }

  function refund(address addr) private {
    require(addr != winner, &quot;winner cannot refund&quot;);
    require(bids[addr] &gt; 0, &quot;refunds only allowed if you sent something&quot;);

    uint refundValue = bids[addr];
    bids[addr] = 0; // reentrancy fix, setting to zero first
    addr.transfer(refundValue);
    
    emit Refund(addr, refundValue, now);
  }

  function refund() public {
    refund(msg.sender);
  }

  function refundOnBehalf(address addr) public onlyOwner() {
    refund(addr);
  }

}

// File: contracts/AuctionMultiple.sol

// 1, &quot;something&quot;, 1539659548, &quot;0xca35b7d915458ef540ade6068dfe2f44e8fa733c&quot;, 3
// 1, &quot;something&quot;, 1539659548, &quot;0x315f80C7cAaCBE7Fb1c14E65A634db89A33A9637&quot;, 3

contract AuctionMultiple is Auction {

  uint public constant LIMIT = 2000; // due to gas restrictions we limit the number of participants in the auction (no Burning Man tickets yet)
  uint public constant HEAD = 120000000 * 1e18; // uint(-1); // really big number
  uint public constant TAIL = 0;
  uint public lastBidID = 0;  
  uint public howMany; // number of items to sell, for isntance 40k tickets to a concert

  struct Bid {
    uint prev;            // bidID of the previous element.
    uint next;            // bidID of the next element.
    uint value;
    address contributor;  // The contributor who placed the bid.
  }    

  mapping (uint =&gt; Bid) public bids; // map bidID to actual Bid structure
  mapping (address =&gt; uint) public contributors; // map address to bidID
  
  event LogNumber(uint number);
  event LogText(string text);
  event LogAddress(address addr);
  
  constructor(uint _price, string _description, uint _timestampEnd, address _beneficiary, uint _howMany) Auction(_price, _description, _timestampEnd, _beneficiary) public {
    require(_howMany &gt; 1, &quot;This auction is suited to multiple items. With 1 item only - use different code. Or remove this &#39;require&#39; - you&#39;ve been warned&quot;);
    howMany = _howMany;

    bids[HEAD] = Bid({
        prev: TAIL,
        next: TAIL,
        value: HEAD,
        contributor: address(0)
    });
    bids[TAIL] = Bid({
        prev: HEAD,
        next: HEAD,
        value: TAIL,
        contributor: address(0)
    });    
  }

  function bid() public payable {
    require(now &lt; timestampEnd, &quot;cannot bid after the auction ends&quot;);

    uint myBidId = contributors[msg.sender];
    uint insertionBidId;
    
    if (myBidId &gt; 0) { // sender has already placed bid, we increase the existing one
        
      Bid storage existingBid = bids[myBidId];
      existingBid.value = existingBid.value + msg.value;
      if (existingBid.value &gt; bids[existingBid.next].value) { // else do nothing (we are lower than the next one)
        insertionBidId = searchInsertionPoint(existingBid.value, existingBid.next);

        bids[existingBid.prev].next = existingBid.next;
        bids[existingBid.next].prev = existingBid.prev;

        existingBid.prev = insertionBidId;
        existingBid.next = bids[insertionBidId].next;

        bids[ bids[insertionBidId].next ].prev = myBidId;
        bids[insertionBidId].next = myBidId;
      } 

    } else { // bid from this guy does not exist, create a new one
      require(msg.value &gt;= price, &quot;Not much sense sending less than the price, likely an error&quot;); // but it is OK to bid below the cut off bid, some guys may withdraw
      require(lastBidID &lt; LIMIT, &quot;Due to blockGas limit we limit number of people in the auction to 4000 - round arbitrary number - check test gasLimit folder for more info&quot;);

      lastBidID++;

      insertionBidId = searchInsertionPoint(msg.value, TAIL);

      contributors[msg.sender] = lastBidID;
      accountsList.push(msg.sender);

      bids[lastBidID] = Bid({
        prev: insertionBidId,
        next: bids[insertionBidId].next,
        value: msg.value,
        contributor: msg.sender
      });

      bids[ bids[insertionBidId].next ].prev = lastBidID;
      bids[insertionBidId].next = lastBidID;
    }

    emit BidEvent(msg.sender, msg.value, now);
  }

  function refund(address addr) private {
    uint bidId = contributors[addr];
    require(bidId &gt; 0, &quot;the guy with this address does not exist, makes no sense to witdraw&quot;);
    uint position = getPosition(addr);
    require(position &gt; howMany, &quot;only the non-winning bids can be withdrawn&quot;);

    Bid memory thisBid = bids[ bidId ];
    bids[ thisBid.prev ].next = thisBid.next;
    bids[ thisBid.next ].prev = thisBid.prev;

    delete bids[ bidId ]; // clearning storage
    delete contributors[ msg.sender ]; // clearning storage
    // cannot delete from accountsList - cannot shrink an array in place without spending shitloads of gas

    addr.transfer(thisBid.value);
    emit Refund(addr, thisBid.value, now);
  }

  function finalize() public ended() onlyOwner() {
    require(finalized == false, &quot;auction already finalized, can withdraw only once&quot;);
    finalized = true;

    uint sumContributions = 0;
    uint counter = 0;
    Bid memory currentBid = bids[HEAD];
    while(counter++ &lt; howMany &amp;&amp; currentBid.prev != TAIL) {
      currentBid = bids[ currentBid.prev ];
      sumContributions += currentBid.value;
    }

    beneficiary.transfer(sumContributions);
  }

  // We are  starting from TAIL and going upwards
  // This is to simplify the case of increasing bids (can go upwards, cannot go lower)
  // NOTE: blockSize gas limit in case of so many bids (wishful thinking)
  function searchInsertionPoint(uint _contribution, uint _startSearch) view public returns (uint) {
    require(_contribution &gt; bids[_startSearch].value, &quot;your contribution and _startSearch does not make sense, it will search in a wrong direction&quot;);

    Bid memory lowerBid = bids[_startSearch];
    Bid memory higherBid;

    while(true) { // it is guaranteed to stop as we set the HEAD bid with very high maximum valuation
      higherBid = bids[lowerBid.next];

      if (_contribution &lt; higherBid.value) {
        return higherBid.prev;
      } else {
        lowerBid = higherBid;
      }
    }
  }

  function getPosition(address addr) view public returns(uint) {
    uint bidId = contributors[addr];
    require(bidId != 0, &quot;cannot ask for a position of a guy who is not on the list&quot;);
    uint position = 1;

    Bid memory currentBid = bids[HEAD];

    while (currentBid.prev != bidId) { // BIG LOOP WARNING, that why we have LIMIT
      currentBid = bids[currentBid.prev];
      position++;
    }
    return position;
  }

  function getPosition() view public returns(uint) { // shorthand for calling without parameters
    return getPosition(msg.sender);
  }

}

// File: contracts/AuctionMultipleGuaranteed.sol

// 100000000000000000, &quot;membership in Casa Crypto&quot;, 1546300799, &quot;0x8855Ef4b740Fc23D822dC8e1cb44782e52c07e87&quot;, 20, 5, 5000000000000000000
// 100000000000000000, &quot;membership in Casa Crypto&quot;, 1546300799, &quot;0x85A363699C6864248a6FfCA66e4a1A5cCf9f5567&quot;, 2, 1, 5000000000000000000

// For instance: effering limited &quot;Early Bird&quot; tickets that are guaranteed
contract AuctionMultipleGuaranteed is AuctionMultiple {

  uint public howManyGuaranteed; // after guaranteed slots are used, we decrease the number of slots available (in the parent contract)
  uint public priceGuaranteed;
  address[] public guaranteedContributors; // cannot iterate mapping, keeping addresses in an array
  mapping (address =&gt; uint) public guaranteedContributions;
  function getGuaranteedContributorsLenght() public constant returns(uint) { return guaranteedContributors.length; } // lenght is not accessible from DApp, exposing convenience method: https://stackoverflow.com/questions/43016011/getting-the-length-of-public-array-variable-getter

  event GuaranteedBid(address indexed bidder, uint value, uint timestamp);
  
  constructor(uint _price, string _description, uint _timestampEnd, address _beneficiary, uint _howMany, uint _howManyGuaranteed, uint _priceGuaranteed) AuctionMultiple(_price, _description, _timestampEnd, _beneficiary, _howMany) public {
    require(_howMany &gt;= _howManyGuaranteed, &quot;The number of guaranteed items should be less or equal than total items. If equal = fixed price sell, kind of OK with me&quot;);
    require(_priceGuaranteed &gt; 0, &quot;Guranteed price must be greated than zero&quot;);

    howManyGuaranteed = _howManyGuaranteed;
    priceGuaranteed = _priceGuaranteed;
  }

  function bid() public payable {
    require(now &lt; timestampEnd, &quot;cannot bid after the auction ends&quot;);
    require(guaranteedContributions[msg.sender] == 0, &quot;already a guranteed contributor, cannot more than once&quot;);

    if (msg.value &gt;= priceGuaranteed &amp;&amp; howManyGuaranteed &gt; 0) {
      guaranteedContributors.push(msg.sender);
      guaranteedContributions[msg.sender] = msg.value;
      howManyGuaranteed--;
      howMany--;
      emit GuaranteedBid(msg.sender, msg.value, now);
    } else {
      super.bid(); // https://ethereum.stackexchange.com/questions/25046/inheritance-and-function-overwriting-who-can-call-the-parent-function
    }
  }

  function finalize() public ended() onlyOwner() {
    require(finalized == false, &quot;auction already finalized, can withdraw only once&quot;);
    finalized = true;

    uint sumContributions = 0;
    uint counter = 0;
    Bid memory currentBid = bids[HEAD];
    while(counter++ &lt; howMany &amp;&amp; currentBid.prev != TAIL) {
      currentBid = bids[ currentBid.prev ];
      sumContributions += currentBid.value;
    }

    // At all times we are aware of gas limits - that&#39;s why we limit auction to 2000 participants, see also `test-gasLimit` folder
    for (uint i=0; i&lt;guaranteedContributors.length; i++) {
      sumContributions += guaranteedContributions[ guaranteedContributors[i] ];
    }

    beneficiary.transfer(sumContributions);
  }
}