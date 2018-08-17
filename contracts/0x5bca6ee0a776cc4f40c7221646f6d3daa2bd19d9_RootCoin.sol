/**
* solc --abi  RootCoin.sol &gt; ./RootCoin.abi
**/
pragma solidity 0.4.18;

contract RootCoin {
    mapping(address =&gt; uint256) balances;
    mapping(address =&gt; mapping (address =&gt; uint256)) allowed;
    uint256 _totalSupply = 250000000000;
    address public owner;
    string public constant name = &quot;Root Blockchain&quot;;
    string public constant symbol = &quot;RBC&quot;;
    uint8 public constant decimals = 2;

    function RootCoin(){
        balances[msg.sender] = _totalSupply;
    }

    function totalSupply() constant returns (uint256 theTotalSupply) {
        theTotalSupply = _totalSupply;
        return theTotalSupply;
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _amount) returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    function transfer(address _to, uint256 _amount) returns (bool success) {
        if (balances[msg.sender] &gt;= _amount &amp;&amp; _amount &gt; 0) {
            balances[msg.sender] -= _amount;
            balances[_to] += _amount;

            Transfer(msg.sender, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    function transferFrom(address _from, address _to, uint256 _amount) returns (bool success) {
        if (balances[_from] &gt;= _amount
        &amp;&amp; allowed[_from][msg.sender] &gt;= _amount
        &amp;&amp; _amount &gt; 0
        &amp;&amp; balances[_to] + _amount &gt; balances[_to]) {
            balances[_from] -= _amount;
            balances[_to] += _amount;
            Transfer(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
}