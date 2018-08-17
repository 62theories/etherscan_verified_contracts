pragma solidity ^0.4.20;
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b &gt; 0); // Solidity automatically throws when dividing by 0 uint256 c = a / b;
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn&#39;t hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b &lt;= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c &gt;= a);
    return c;
  }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of &quot;user permissions&quot;.
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor () public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

contract Jackpot is Ownable {

  string public constant name = &quot;Jackpot&quot;;

  event newWinner(address winner, uint256 ticketNumber);
  // event newRandomNumber_bytes(bytes);
  // event newRandomNumber_uint(uint);
  event newContribution(address contributor, uint value);

  using SafeMath for uint256;
  address[] public players = new address[](10);
  uint256 public lastTicketNumber = 0;
  uint8 public lastIndex = 0;

  uint256 public numberOfPlayers = 10;

  struct tickets {
    uint256 startTicket;
    uint256 endTicket;
  }

  mapping (address =&gt; tickets[]) public ticketsMap;
  mapping (address =&gt; uint256) public contributions;

  function setNumberOfPlayers(uint256 _noOfPlayers) public onlyOwner {
    numberOfPlayers = _noOfPlayers;
  }


  function executeLottery() public { 
      
        if (lastIndex &gt;= numberOfPlayers) {
          uint randomNumber = address(this).balance.mul(16807) % 2147483647;
          randomNumber = randomNumber % lastTicketNumber;
          address winner;
          bool hasWon;
          for (uint8 i = 0; i &lt; lastIndex; i++) {
            address player = players[i];
            for (uint j = 0; j &lt; ticketsMap[player].length; j++) {
              uint256 start = ticketsMap[player][j].startTicket;
              uint256 end = ticketsMap[player][j].endTicket;
              if (randomNumber &gt;= start &amp;&amp; randomNumber &lt; end) {
                winner = player;
                hasWon = true;
                break;
              }
            }
            if(hasWon) break;
          }
          require(winner!=address(0) &amp;&amp; hasWon);

          for (uint8 k = 0; k &lt; lastIndex; k++) {
            delete ticketsMap[players[k]];
            delete contributions[players[k]];
          }

          lastIndex = 0;
          lastTicketNumber = 0;

          uint balance = address(this).balance;
        //   if (!owner.send(balance/10)) throw;
          owner.transfer(balance/10);
          //Both SafeMath.div and / throws on error
        //   if (!winner.send(balance - balance/10)) throw;
        winner.transfer(balance.sub(balance/10));
        emit  newWinner(winner, randomNumber);
          
        }
      
  }

  function getPlayers() public constant returns (address[], uint256[]) {
    address[] memory addrs = new address[](lastIndex);
    uint256[] memory _contributions = new uint256[](lastIndex);
    for (uint i = 0; i &lt; lastIndex; i++) {
      addrs[i] = players[i];
      _contributions[i] = contributions[players[i]];
    }
    return (addrs, _contributions);
  }

  function getTickets(address _addr) public constant returns (uint256[] _start, uint256[] _end) {
    tickets[] storage tks = ticketsMap[_addr];
    uint length = tks.length;
    uint256[] memory startTickets = new uint256[](length);
    uint256[] memory endTickets = new uint256[](length);
    for (uint i = 0; i &lt; length; i++) {
      startTickets[i] = tks[i].startTicket;
      endTickets[i] = tks[i].endTicket;
    }
    return (startTickets, endTickets);
  }

  function () public payable {
    uint256 weiAmount = msg.value;
    require(weiAmount &gt;= 1e16);

    bool isSenderAdded = false;
    for (uint8 i = 0; i &lt; lastIndex; i++) {
      if (players[i] == msg.sender) {
        isSenderAdded = true;
        break;
      }
    }
    if (!isSenderAdded) {
      players[lastIndex] = msg.sender;
      lastIndex++;
    }

    tickets memory senderTickets;
    senderTickets.startTicket = lastTicketNumber;
    uint256 numberOfTickets = weiAmount/1e15;
    senderTickets.endTicket = lastTicketNumber.add(numberOfTickets);
    lastTicketNumber = lastTicketNumber.add(numberOfTickets);
    ticketsMap[msg.sender].push(senderTickets);

    contributions[msg.sender] = contributions[msg.sender].add(weiAmount);

    emit newContribution(msg.sender, weiAmount);

    if(lastIndex &gt;= numberOfPlayers) {
      executeLottery();
    }
  }
}