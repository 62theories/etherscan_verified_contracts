pragma solidity ^0.4.4;

contract SafeMath {
    function safeAdd(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c &gt;= a);
    }
    function safeSub(uint a, uint b) internal pure returns (uint c) {
        require(b &lt;= a);
        c = a - b;
    }
    function safeMul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function safeDiv(uint a, uint b) internal pure returns (uint c) {
        require(b &gt; 0);
        c = a / b;
    }
}


contract Token {

    function totalSupply() constant returns (uint256 supply) {}
    function balanceOf(address _owner) constant returns (uint256 balance) {}
    function transfer(address _to, uint256 _value) returns (bool success) {}
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}
    function approve(address _spender, uint256 _value) returns (bool success) {}
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}

contract StandardToken is Token {

    function transfer(address _to, uint256 _value) returns (bool success) {
        
        if (balances[msg.sender] &gt;= _value &amp;&amp; _value &gt; 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        
        if (balances[_from] &gt;= _value &amp;&amp; allowed[_from][msg.sender] &gt;= _value &amp;&amp; _value &gt; 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address =&gt; uint256) balances;
    mapping (address =&gt; mapping (address =&gt; uint256)) allowed;
    uint256 public totalSupply;
}

contract Arbitragebit is StandardToken, SafeMath { 

   
    string public name;                   
    uint8 public decimals;                
    string public symbol;                 
    string public version = &#39;1.0&#39;; 
    uint public startDate;
    uint public bonus1Ends;
    uint public bonus2Ends;
    uint public bonus3Ends;
    uint public endDate;
    uint256 public unitsOneEthCanBuy;     
    uint256 public totalEthInWei;         
    address public fundsWallet;           

    
    function Arbitragebit() {
        balances[msg.sender] = 25000000000000000000000000;  
        totalSupply = 25000000000000000000000000;   
        name = &quot;Arbitragebit&quot;;               
        decimals = 18;                          
        symbol = &quot;ABG&quot;;                        
        unitsOneEthCanBuy = 250;                  
        fundsWallet = msg.sender;                
        bonus1Ends = now + 45 minutes + 13 hours + 3 days + 4 weeks;
        bonus2Ends = now + 45 minutes + 13 hours + 5 days + 8 weeks;
        bonus3Ends = now + 45 minutes + 13 hours + 1 days + 13 weeks;
        endDate = now + 45 minutes + 13 hours + 4 days + 17 weeks;

    }

    function() payable{
        totalEthInWei = totalEthInWei + msg.value;
        require(balances[fundsWallet] &gt;= amount);
        require(now &gt;= startDate &amp;&amp; now &lt;= endDate);
        uint256 amount;
        

        
       
       if (now &lt;= bonus1Ends) {
            amount = msg.value * unitsOneEthCanBuy * 8;
        } 
        
         else if (now &lt;= bonus2Ends &amp;&amp; now &gt; bonus1Ends) {
            amount = msg.value * unitsOneEthCanBuy * 6;
        }
        
        else if (now &lt;= bonus3Ends &amp;&amp; now &gt; bonus2Ends) {
            amount = msg.value * unitsOneEthCanBuy * 5;
        }
        
        else {
            amount = msg.value * unitsOneEthCanBuy * 4;
        }


        balances[fundsWallet] = balances[fundsWallet] - amount;
        balances[msg.sender] = balances[msg.sender] + amount;

        Transfer(fundsWallet, msg.sender, amount); 

        fundsWallet.transfer(msg.value);                               
    }

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        if(!_spender.call(bytes4(bytes32(sha3(&quot;receiveApproval(address,uint256,address,bytes)&quot;))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}