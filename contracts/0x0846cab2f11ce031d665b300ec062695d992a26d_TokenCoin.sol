pragma solidity ^0.4.4;

/// Ever wondered why some cryptocurrencies are coins and others are tokens? Ever tried to explain the difference to someone who has no idea about crypto? 
/// Well now the problem has been solved! Here we have an Ethereum token that can be handed out to the common person without needing to explain to them why or how it is different from bitcoin. It just is. Forget the technical details, or risk 20 minutes of conversation where
/// you know you&#39;ve lost the person within the first 10 seconds but they just keep nodding and saying they understand.

///   Parent 1: &quot;My son has been trying to get me into this cryptocurrency scene, but I have no idea what he&#39;s talking about. Do I buy an ethereums or a bitcoins? What if I get the wrong tokens when I buy a bitcoin?&quot;
///   Parent 2: &quot;God knows I can&#39;t keep track of the 3 passwords I use now, let alone remembering passwords for all these different wallets. I want a coin that just has one wallet.&quot;
///   Cryptogrumbo: &quot;Don&#39;t worry Generation X! Check out this new fandangled cryptocurrency that solves all your problems.... it&#39;s the only cryptocurrency you will ever need.&quot;

contract Token {

    /// @return total amount of tokens
    function totalSupply() constant returns (uint256 supply) {}

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant returns (uint256 balance) {}

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) returns (bool success) {}

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}

    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) returns (bool success) {}

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
}



contract StandardToken is Token {

    function transfer(address _to, uint256 _value) returns (bool success) {
        //Default assumes totalSupply can&#39;t be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn&#39;t wrap.
        //Replace the if with this one instead.
        //if (balances[msg.sender] &gt;= _value &amp;&amp; balances[_to] + _value &gt; balances[_to]) {
        if (balances[msg.sender] &gt;= _value &amp;&amp; _value &gt; 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        //if (balances[_from] &gt;= _value &amp;&amp; allowed[_from][msg.sender] &gt;= _value &amp;&amp; balances[_to] + _value &gt; balances[_to]) {
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



contract TokenCoin is StandardToken {

    function () {
        //if ether is sent to this address, send it back.
        throw;
    }


    string public name = &quot;TokenCoin&quot;;                   
    uint8 public decimals = 12;                
    string public symbol = &quot;TKN&quot;;                 
    string public version = &#39;H1.0&#39;;       



    function TokenCoin(
        ) {
        balances[msg.sender] = 120000000000000000000;              
        totalSupply = 120000000000000000000;                      
        name = &quot;TokenCoin&quot;;                               
        decimals = 12;                           
        symbol = &quot;TKN&quot;;                             
    }


    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

               if(!_spender.call(bytes4(bytes32(sha3(&quot;receiveApproval(address,uint256,address,bytes)&quot;))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}