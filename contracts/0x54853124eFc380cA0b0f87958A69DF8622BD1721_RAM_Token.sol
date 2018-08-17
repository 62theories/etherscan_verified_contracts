pragma solidity ^0.4.18;

contract SafeMath {
  function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b &gt; 0);
    uint256 c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b &lt;= a);
    return a - b;
  }

  function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c&gt;=a &amp;&amp; c&gt;=b);
    return c;
  }


}
contract ERC20 {
    uint256 public totalSupply;
    function balanceOf(address _owner)public constant returns (uint256 balance);
    function transfer(address _to, uint256 _value)public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value)public returns (bool success);
    function approve(address _spender, uint256 _value)public returns (bool success);
    function allowance(address _owner, address _spender)public constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}


contract StdToken is ERC20,SafeMath {

    // validates an address - currently only checks that it isn&#39;t null
   modifier validAddress(address _address) {
        require(_address != 0x0);
        _;
    }

  mapping(address =&gt; uint) balances;
  mapping (address =&gt; mapping (address =&gt; uint)) allowed;
  
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
    
  function transfer(address _to, uint _value) public validAddress(_to)  returns (bool success){
    if(msg.sender != _to){
    balances[msg.sender] = safeSub(balances[msg.sender], _value);
    balances[_to] = safeAdd(balances[_to], _value);
    Transfer(msg.sender, _to, _value);
    return true;
    }
  }

    function transferFrom(address _from, address _to, uint256 _value)public validAddress(_to)  returns (bool success) {
        if (_value &lt;= 0) revert();
        if (balances[_from] &lt; _value) revert();
        if (balances[_to] + _value &lt; balances[_to]) revert();
        if (_value &gt; allowed[_from][msg.sender]) revert();
        balances[_from] = safeSub(balances[_from], _value);                           
        balances[_to] = safeAdd(balances[_to], _value);
        allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], _value);
        Transfer(_from, _to, _value);
        return true;
    }

  function balanceOf(address _owner)public constant returns (uint balance) {
    return balances[_owner];
  }

  function approve(address _spender, uint _value)public returns (bool success) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender)public constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }
}


contract Ownable {
  address public owner;

  function Ownable()public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner)public onlyOwner {
    if (newOwner != owner) {
      owner = newOwner;
    }
  }
}


contract RAM_Token is StdToken,Ownable{
    string public name=&quot;RAM Token&quot;;
    string public symbol=&quot;RAM&quot;;
    uint public decimals = 18;
    uint256 TokenValue;
    uint256 public minToken=1000;
    uint256 public rate;
    address stockWallet=0x7F5C9d6C36AB4BCC7Abd0054809bA88CF9Fed513;
    address EthWallet=0x82FF0759301dd646C2bE5e27FDEcDF53a43568fd;
    uint256 public limit;
    uint public startTime;
    uint public endTime;
    bool public active;

    
    modifier isActive{
        if(now&gt;=startTime &amp;&amp; now&lt;=endTime &amp;&amp; limit&gt;0){
        _;
        }else{ if(now&gt;endTime  || limit==0){
                active=false;
            }
        revert();
        }
    }
    function changeRate(uint _rate)external onlyOwner{
        rate= _rate;
    }
    function changeMinToken(uint _minToken)external onlyOwner{
        minToken=_minToken;
    }
    function activeEnd()external onlyOwner{
        active=false;
        startTime=0;
        endTime=0;
        limit=0;
    }
    
    function RAM_Token()public onlyOwner{
        rate=15000;
        totalSupply= 700 * (10**6) * (10**decimals);
        balances[stockWallet]= 200 * (10**6) * (10**decimals);
        balances[owner] = 500 * (10**6) * (10**decimals);
    }    
    
    function Mint(uint _value)public onlyOwner returns(uint256){
        if(_value&gt;0){
        balances[owner] = safeAdd(balances[owner],_value);
        totalSupply =safeAdd(totalSupply, _value);
        return totalSupply;
        }
    }
        
    function burn(uint _value)public onlyOwner returns(uint256){
        if(_value&gt;0 &amp;&amp; balances[msg.sender] &gt;= _value){
            balances[owner] = safeSub(balances[owner],_value);
            totalSupply = safeSub(totalSupply,_value);
            return totalSupply;
        }
    }
   
    function wihtdraw()public onlyOwner returns(bool success){
        if(this.balance &gt; 0){
            msg.sender.transfer(this.balance);
            return true;
        }
    }
    
    function crowdsale(uint256 _limit,uint _startTime,uint _endTime)external onlyOwner{
    if(active){ revert();}
        endTime = _endTime;
    if(now&gt;=endTime){ revert();}
    if(_limit==0 || _limit &gt; balances[owner]){revert();}
        startTime= _startTime;
        limit = _limit * (10**decimals);
        active=true;
    }

    function ()public isActive payable{
        if(!active)revert();
        if(msg.value&lt;=0)revert();
        TokenValue=msg.value*rate;
        if(TokenValue&lt;minToken*(10**decimals))revert();
        if(limit -TokenValue&lt;0)revert();
        balances[msg.sender]=safeAdd(balances[msg.sender],TokenValue);
        balances[owner]=safeSub(balances[owner],TokenValue);
        limit = safeSub(limit,TokenValue);
        Transfer(owner,msg.sender,TokenValue);
        EthWallet.transfer(msg.value);
    }
}