pragma solidity ^0.4.19;

contract ERC20Interface {
    function totalSupply() public constant returns (uint256 supply);
    function balance() public constant returns (uint256);
    function balanceOf(address _owner) public constant returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
    function claimdram() public returns (bool success);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract EOSDRAM is ERC20Interface {
    string public constant symbol = &quot;DRAM&quot;;
    string public constant name = &quot;EOS DRAM&quot;;
    uint8 public constant decimals = 4;

    uint256 _totalSupply = 0;
    // airdrop 200Kb to each account. 1 Kb = 1 DRAM
    uint256 _airdropAmount = 200 * 10000;
    // max supply of 64GB is 64 * 1024 * 1024 Kb
    uint256 _maxSupply = 67108864 * 10000;

    mapping(address =&gt; uint256) balances;
    mapping(address =&gt; bool) claimeddram;

    // Owner of account approves the transfer of an amount to another account
    mapping(address =&gt; mapping (address =&gt; uint256)) allowed;

    address public owner;
    
    modifier onlyOwner() {
    require(msg.sender == owner);
    _;
    }
    
    function EOSDRAM() public {
        owner = msg.sender;
        claimeddram[msg.sender] = true;
        //reserved for dev and exchanges
        balances[msg.sender] = 7108864 * 10000;
        _totalSupply = balances[msg.sender];
    }
    
    function transferOwnership(address newOwner) onlyOwner public {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }

    function totalSupply() constant public returns (uint256 supply) {
        return _totalSupply;
    }

    // What&#39;s my balance?
    function balance() constant public returns (uint256) {
            return balances[msg.sender];
    }

    // What is the balance of a particular account?
    function balanceOf(address _address) constant public returns (uint256) {
        return balances[_address];
    }

    // Transfer the balance from owner&#39;s account to another account
    function transfer(address _to, uint256 _amount) public returns (bool success) {
 
        if (balances[msg.sender] &gt;= _amount
            &amp;&amp; _amount &gt; 0) {
             if (balances[_to] + _amount &gt; balances[_to]) {
                balances[msg.sender] -= _amount;
                balances[_to] += _amount;
                Transfer(msg.sender, _to, _amount);
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }

    // Send _value amount of tokens from address _from to address _to
    // The transferFrom method is used for a withdraw workflow, allowing contracts to send
    // tokens on your behalf, for example to &quot;deposit&quot; to a contract address and/or to charge
    // fees in sub-currencies; the command should fail unless the _from account has
    // deliberately authorized the sender of the message via some mechanism; we propose
    // these standardized APIs for approval:
    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success) {
        if (balances[_from] &gt;= _amount
            &amp;&amp; allowed[_from][msg.sender] &gt;= _amount
            &amp;&amp; _amount &gt; 0) {
            if (balances[_to] + _amount &gt; balances[_to]) {
                balances[_from] -= _amount;
                allowed[_from][msg.sender] -= _amount;
                balances[_to] += _amount;
                Transfer(_from, _to, _amount);
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }

    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    function approve(address _spender, uint256 _amount) public returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    // claim DRAM function
    function claimdram() public returns (bool success) {
        if (_totalSupply &lt; _maxSupply &amp;&amp; !claimeddram[msg.sender]) {
            claimeddram[msg.sender] = true;
            balances[msg.sender] += _airdropAmount;
            _totalSupply += _airdropAmount;
            return true;
        } else {
            return false;
            }
    }

}