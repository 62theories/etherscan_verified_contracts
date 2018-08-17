pragma solidity ^0.4.21;

contract CoinBundleToken {

  function add(uint256 x, uint256 y) pure internal returns (uint256 z) { assert((z = x + y) &gt;= x); }
  function sub(uint256 x, uint256 y) pure internal returns (uint256 z) { assert((z = x - y) &lt;= x); }

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Mint(address indexed to, uint256 amount);
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  address public owner;
  string public name;
  string public symbol;
  uint256 public totalSupply;
  uint8 public constant decimals = 6;
  mapping(address =&gt; uint) public balanceOf;
  mapping(address =&gt; mapping (address =&gt; uint)) public allowance;

  uint256 internal constant CAP_TO_GIVE_AWAY = 800000000 * (10 ** uint256(decimals));
  uint256 internal constant CAP_FOR_THE_TEAM = 200000000 * (10 ** uint256(decimals));
  uint256 internal constant TEAM_CAP_RELEASE_TIME = 1554000000; // 31 Mar 2019

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function CoinBundleToken() public {
    owner = msg.sender;
    totalSupply = 0;
    name = &quot;CoinBundle Token&quot;;
    symbol = &quot;BNDL&quot;;
  }

  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value &lt;= balanceOf[msg.sender]);
    balanceOf[msg.sender] = sub(balanceOf[msg.sender], _value);
    balanceOf[_to] = add(balanceOf[_to], _value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_from != address(0));
    require(_to != address(0));
    require(_value &lt;= balanceOf[_from]);
    require(_value &lt;= allowance[_from][msg.sender]);
    balanceOf[_from] = sub(balanceOf[_from], _value);
    balanceOf[_to] = add(balanceOf[_to], _value);
    allowance[_from][msg.sender] = sub(allowance[_from][msg.sender], _value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool) {
    require(_spender != address(0));
    allowance[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function increaseApproval(address _spender, uint256 _addedValue) public returns (bool) {
    require(_spender != address(0));
    allowance[msg.sender][_spender] = add(allowance[msg.sender][_spender], _addedValue);
    emit Approval(msg.sender, _spender, allowance[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool) {
    require(_spender != address(0));
    uint256 oldValue = allowance[msg.sender][_spender];
    if (_subtractedValue &gt; oldValue) {
      allowance[msg.sender][_spender] = 0;
    } else {
      allowance[msg.sender][_spender] = sub(oldValue, _subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowance[msg.sender][_spender]);
    return true;
  }

  function mint(address _to, uint256 _amount) onlyOwner public returns (bool) {
    require(_to != address(0));
    require( add(totalSupply, _amount) &lt;= (CAP_TO_GIVE_AWAY + (now &gt;= TEAM_CAP_RELEASE_TIME ? CAP_FOR_THE_TEAM : 0)) );
    totalSupply = add(totalSupply, _amount);
    balanceOf[_to] = add(balanceOf[_to], _amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }

  function transferOwnership(address _newOwner) public onlyOwner {
    require(_newOwner != address(0));
    owner = _newOwner;
    emit OwnershipTransferred(owner, _newOwner);
  }

  function rename(string _name, string _symbol) public onlyOwner {
    require(bytes(_name).length &gt; 0 &amp;&amp; bytes(_name).length &lt;= 32);
    require(bytes(_symbol).length &gt; 0 &amp;&amp; bytes(_symbol).length &lt;= 32);
    name = _name;
    symbol = _symbol;
  }

}