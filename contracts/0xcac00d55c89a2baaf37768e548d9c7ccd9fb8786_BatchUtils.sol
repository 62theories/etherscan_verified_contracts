pragma solidity ^0.4.11;

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  uint8 public decimals;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b &gt; 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn&#39;t hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b &lt;= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
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
  function Ownable() {
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
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract BatchUtils is Ownable {
  using SafeMath for uint256;
  mapping (address =&gt; bool) public operational;
  uint256 public sendlimit = 10;
  
  function BatchUtils() {
      operational[msg.sender] = true;
  }
  
  function setLimit(uint256 _limit) onlyOwner public {
      sendlimit = _limit;
  }
  
  function setOperational(address[] addresses, bool op) onlyOwner public {
    for (uint i = 0; i &lt; addresses.length; i++) {
        operational[addresses[i]] = op;
    }
  }
  
  function batchTransfer(address[] _tokens, address[] _receivers, uint256 _value) {
    require(operational[msg.sender]); 
    require(_value &lt;= sendlimit);
    
    uint cnt = _receivers.length;
    require(cnt &gt; 0 &amp;&amp; cnt &lt;= 121);
    
    for (uint j = 0; j &lt; _tokens.length; j++) {
        ERC20Basic token = ERC20Basic(_tokens[j]);
        
        uint256 value = _value.mul(10**uint256(token.decimals()));
        uint256 amount = uint256(cnt).mul(value);
        
        require(value &gt; 0 &amp;&amp; token.balanceOf(this) &gt;= amount);
        
        for (uint i = 0; i &lt; cnt; i++) {
            token.transfer(_receivers[i], value);
        }
    }
  }
}