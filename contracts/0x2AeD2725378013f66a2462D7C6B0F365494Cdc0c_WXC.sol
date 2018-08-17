pragma solidity ^0.4.11;

interface ERC20 {
    function totalSupply() public constant returns (uint256 totalSup);
    function balanceOf(address _owner) public constant returns (uint256 balance);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
    function approve(address _spender, uint256 _value) public returns (bool success);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

interface ERC223 {
    function transfer(address _to, uint256 _value, bytes _data) public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
}

contract ERC223ReceivingContract {
    function tokenFallback(address _from, uint _value, bytes _data) public;
}

contract WXC is ERC223, ERC20 {
    
    using SafeMath for uint256;
    
    uint public constant _totalSupply = 2100000000e18;
    //starting supply of Token
    
    string public constant symbol = &quot;WXC&quot;;
    string public constant name = &quot;WIIX Coin&quot;;
    uint8 public constant decimals = 18;
    
    mapping(address =&gt; uint256) balances;
    mapping(address =&gt; mapping(address =&gt; uint256)) allowed;
    
    function WXC() public{
        balances[msg.sender] = _totalSupply;
    }

    function totalSupply() public constant returns (uint256 totalSup) {
        return _totalSupply;
    }
    
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }
    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(
            balances[msg.sender] &gt;= _value
            &amp;&amp; _value &gt; 0
            &amp;&amp; !isContract(_to)
        );
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }
    
    function transfer(address _to, uint256 _value, bytes _data) public returns (bool success){
        require(
            balances[msg.sender] &gt;= _value
            &amp;&amp; _value &gt; 0
            &amp;&amp; isContract(_to)
        );
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        ERC223ReceivingContract(_to).tokenFallback(msg.sender, _value, _data);
        Transfer(msg.sender, _to, _value, _data);
        return true;
    }
    
    function isContract(address _from) private constant returns (bool) {
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(_from)
        }
        return codeSize &gt; 0;
    }
    
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(
            allowed[_from][msg.sender] &gt;= _value  
            &amp;&amp; balances[_from] &gt;= _value
            &amp;&amp; _value &gt; 0
            &amp;&amp; allowed[_from][msg.sender] &gt; 0
        );
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }
    
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) public constant returns (uint256 remaing) {
        return allowed[_owner][_spender];
    }
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
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