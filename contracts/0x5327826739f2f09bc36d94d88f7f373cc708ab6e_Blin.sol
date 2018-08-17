pragma solidity ^0.4.18;

library SafeMath {
    
  function mul(uint256 a, uint256 b) internal  pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b &gt; 0); // Solidity automatically throws when dividing by 0
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

contract Ownable {
    
    address public owner;
    
    function Ownable() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    
}

contract Blin is Ownable {
     using SafeMath for uint256;
    string public  name = &quot;Afonja&quot;;
    
    string public  symbol = &quot;GROSH&quot;;
    
    uint32 public  decimals = 0;
    
    uint public totalSupply = 0;
    
    mapping (address =&gt; uint) balances;
    
  
	uint rate = 100000;
	
	function Blin()public {

	
	
	}
    
    function mint(address _to, uint _value) internal{
        assert(totalSupply + _value &gt;= totalSupply &amp;&amp; balances[_to] + _value &gt;= balances[_to]);
        balances[_to] += _value;
        totalSupply += _value;
    }
    
    function balanceOf(address _owner) public constant returns (uint balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint _value) public returns (bool success) {
        if(balances[msg.sender] &gt;= _value &amp;&amp; balances[_to] + _value &gt;= balances[_to]) {
            balances[msg.sender] -= _value; 
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } 
        return false;
    }
    

 
    
    event Transfer(address indexed _from, address indexed _to, uint _value);
    

    
	
    function createTokens()  public payable {
     //  transfer(msg.sender,msg.value);
	   owner.transfer(msg.value);
       uint tokens = rate.mul(msg.value).div(1 ether);
        mint(msg.sender, tokens);
    }

    function() external payable {
        createTokens();
    }
	
}