pragma solidity ^0.4.13;
// -------------------------------------------------
// 0.4.13+commit.0fb4cb1a
// EthPoker.io ERC20 PKT token contract
// Contact <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="29484d444047694c5d415946424c5b074046">[email&#160;protected]</a> for any query
// -------------------------------------------------
// ERC Token Standard #20 Interface https://github.com/ethereum/EIPs/issues/20
// -------------------------------------------------
// Security, functional, code reviews completed 06/October/17 [passed OK]
// Regression test cycle complete 06/October/17 [passed OK]
// -------------------------------------------------

contract safeMath {
  function safeMul(uint256 a, uint256 b) internal returns (uint256) {
      uint256 c = a * b;
      safeAssert(a == 0 || c / a == b);
      return c;
  }

  function safeDiv(uint256 a, uint256 b) internal returns (uint256) {
      safeAssert(b &gt; 0);
      uint256 c = a / b;
      safeAssert(a == b * c + a % b);
      return c;
  }

  function safeSub(uint256 a, uint256 b) internal returns (uint256) {
      safeAssert(b &lt;= a);
      return a - b;
  }

  function safeAdd(uint256 a, uint256 b) internal returns (uint256) {
      uint256 c = a + b;
      safeAssert(c&gt;=a &amp;&amp; c&gt;=b);
      return c;
  }

  function safeAssert(bool assertion) internal {
      if (!assertion) revert();
  }
}

contract ERC20Interface is safeMath {
  function balanceOf(address _owner) constant returns (uint256 balance);
  function transfer(address _to, uint256 _value) returns (bool success);
  function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
  function approve(address _spender, uint256 _value) returns (bool success);
  function increaseApproval (address _spender, uint _addedValue) returns (bool success);
  function decreaseApproval (address _spender, uint _subtractedValue) returns (bool success);
  function allowance(address _owner, address _spender) constant returns (uint256 remaining);
  event Buy(address indexed _sender, uint256 _eth, uint256 _PKT);
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract PKTToken is safeMath, ERC20Interface {
  // token setup variables
  string  public constant standard              = &quot;PKT&quot;;
  string  public constant name                  = &quot;ethPoker&quot;;
  string  public constant symbol                = &quot;PKT&quot;;
  uint8   public constant decimals              = 4;                                  // 4 decimals for usability
  uint256 public constant totalSupply           = 100000000000;                       // 10 million + 4 decimals (presale maximum capped) static supply

  // token mappings
  mapping (address =&gt; uint256) balances;
  mapping (address =&gt; mapping (address =&gt; uint256)) allowed;

  // ERC20 standard token possible events, matched to ICO and preSale contracts
  event Buy(address indexed _sender, uint256 _eth, uint256 _PKT);
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);

  // ERC20 token balanceOf query function
  function balanceOf(address _owner) constant returns (uint256 balance) {
      return balances[_owner];
  }

  // ERC20 token transfer function with additional safety
  function transfer(address _to, uint256 _amount) returns (bool success) {
      require(!(_to == 0x0));
      if ((balances[msg.sender] &gt;= _amount)
      &amp;&amp; (_amount &gt; 0)
      &amp;&amp; ((safeAdd(balances[_to],_amount) &gt; balances[_to]))) {
          balances[msg.sender] = safeSub(balances[msg.sender], _amount);
          balances[_to] = safeAdd(balances[_to], _amount);
          Transfer(msg.sender, _to, _amount);
          return true;
      } else {
          return false;
      }
  }

  // ERC20 token transferFrom function with additional safety
  function transferFrom(
      address _from,
      address _to,
      uint256 _amount) returns (bool success) {
      require(!(_to == 0x0));
      if ((balances[_from] &gt;= _amount)
      &amp;&amp; (allowed[_from][msg.sender] &gt;= _amount)
      &amp;&amp; (_amount &gt; 0)
      &amp;&amp; (safeAdd(balances[_to],_amount) &gt; balances[_to])) {
          balances[_from] = safeSub(balances[_from], _amount);
          allowed[_from][msg.sender] = safeSub((allowed[_from][msg.sender]),_amount);
          balances[_to] = safeAdd(balances[_to], _amount);
          Transfer(_from, _to, _amount);
          return true;
      } else {
          return false;
      }
  }

  // ERC20 allow _spender to withdraw, multiple times, up to the _value amount
  function approve(address _spender, uint256 _amount) returns (bool success) {
      //Fix for known double-spend https://docs.google.com/document/d/1YLPtQxZu1UAvO9cZ1O2RPXBbT0mooh4DYKjA_jp-RLM/edit#
      //Input must either set allow amount to 0, or have 0 already set, to workaround issue

      require((_amount == 0) || (allowed[msg.sender][_spender] == 0));
      allowed[msg.sender][_spender] = _amount;
      Approval(msg.sender, _spender, _amount);
      return true;
  }

  // ERC20 return allowance for given owner spender pair
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
  }

  // ERC20 Updated increase approval process (to prevent double-spend attack but remove need to zero allowance before setting)
  function increaseApproval (address _spender, uint _addedValue) returns (bool success) {
      allowed[msg.sender][_spender] = safeAdd(allowed[msg.sender][_spender],_addedValue);

      // report new approval amount
      Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
      return true;
  }

  // ERC20 Updated decrease approval process (to prevent double-spend attack but remove need to zero allowance before setting)
  function decreaseApproval (address _spender, uint _subtractedValue) returns (bool success) {
      uint oldValue = allowed[msg.sender][_spender];

      if (_subtractedValue &gt; oldValue) {
        allowed[msg.sender][_spender] = 0;
      } else {
        allowed[msg.sender][_spender] = safeSub(oldValue,_subtractedValue);
      }

      // report new approval amount
      Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
      return true;
  }

  // ERC20 Standard default function to assign initial supply variables and send balance to creator for distribution to PKT presale and ICO contract
  function PKTToken() {
      balances[msg.sender] = totalSupply;
  }
}