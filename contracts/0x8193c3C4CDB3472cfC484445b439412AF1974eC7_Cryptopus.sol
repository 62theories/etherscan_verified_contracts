//sol Cryptopus
// @authors:
// Alexandr Romanov &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="ee9c83808888c08a8b98ae978f808a8b96c09c9b">[email&#160;protected]</a>&gt;
// usage:
// use modifiers isOwner (just own owned).
pragma solidity ^0.4.10;

contract checkedMathematics {
    function checkedAddition(uint256 x, uint256 y) pure internal returns(uint256) {
      uint256 z = x + y;
      assert((z &gt;= x) &amp;&amp; (z &gt;= y));
      return z;
    }
    function checkedSubtract(uint256 x, uint256 y) pure internal returns(uint256) {
      assert(x &gt;= y);
      uint256 z = x - y;
      return z;
    }
    function checkedMultiplication(uint256 x, uint256 y) pure internal returns(uint256) {
      uint256 z = x * y;
      assert((x == 0)||(z/x == y));
      return z;
    }
    function checkedDivision(uint256 a, uint256 b) pure internal returns (uint256) {
      assert(b &gt; 0);
      uint c = a / b;
      assert(a == b * c + a % b);
      return c;
    }
}

contract ERC20Token {
    uint256 public totalSupply;
    function balanceOf(address _owner) public constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract StandardToken is ERC20Token {

    function transfer(address _to, uint256 _value) public returns (bool success) {
      if (balances[msg.sender] &gt;= _value &amp;&amp; _value &gt; 0) {
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
      } else {
        return false;
      }
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
      if (balances[_from] &gt;= _value &amp;&amp; allowed[_from][msg.sender] &gt;= _value &amp;&amp; _value &gt; 0) {
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
      } else {
        return false;
      }
    }

    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address =&gt; uint256) balances;
    mapping (address =&gt; mapping (address =&gt; uint256)) allowed;
}

contract Cryptopus is checkedMathematics, StandardToken {

    string public constant name                      = &quot;Cryptopus Token&quot;;
    string public constant symbol                    = &quot;CPP&quot;; // Still unused symbol we are using now
    uint256 public constant decimals                 = 18;
    uint256 private constant tokenCreationCapICO025  = 10000000**decimals;
    uint256 private constant tokenCreationCapICO030  = 10000000**decimals;
    uint256 public  constant tokenCreationCapOverall = 20000000**decimals;

    address public owner;

    // 1 ETH = $470 USD Date: December 1st, 2017
    uint private oneTokenInWeiSale1  = 530000000000000; // $0.25 USD
    uint private oneTokenInWeiSale2  = 590000000000000; // $0.28 USD
    uint private oneTokenInWeiSale3  = 640000000000000; // $0.30 USD
    uint private oneTokenInWeiNormal = 680000000000000; // $0.32 USD

    Phase public currentPhase = Phase.ICOweek1;

    enum Phase {
        ICOweek1,
        ICOweek2,
        ICOweek3,
        NormalLife
    }

    modifier isOwner {
        if(owner != msg.sender) revert();
        _;
    }

    event CreateCPP(address indexed _to, uint256 _value);

    function Cryptopus() public {
      owner = msg.sender;
    }

    function () public payable {
        createTokens();
    }

    function createTokens() internal {
        if (msg.value &lt;= 0) revert();

        if (currentPhase == Phase.ICOweek1) {
            if (totalSupply &lt;= tokenCreationCapICO025) {
                generateTokens(oneTokenInWeiSale1);
            }
        }
        else if (currentPhase == Phase.ICOweek2) {
            if (totalSupply &gt; tokenCreationCapICO025 &amp;&amp; totalSupply &lt;= tokenCreationCapICO030) {
                generateTokens(oneTokenInWeiSale2);
            }
        }
        else if (currentPhase == Phase.ICOweek3) {
            if (totalSupply &gt; tokenCreationCapICO030 &amp;&amp; totalSupply &lt;= tokenCreationCapOverall) {
                generateTokens(oneTokenInWeiSale3);
            }
        } else {
            revert();
        }
    }

    function generateTokens(uint _oneTokenInWei) internal {
        uint multiplier = 10**decimals;
        uint256 tokens = checkedDivision(msg.value, _oneTokenInWei)*multiplier;
        uint256 checkedSupply = checkedAddition(totalSupply, tokens);
        if (tokenCreationCapOverall &lt;= checkedSupply) revert();
        balances[msg.sender] += tokens;
        totalSupply = checkedAddition(totalSupply, tokens);
        CreateCPP(msg.sender,tokens);
    }

    function changePhaseToICOweek2() external isOwner returns (bool){
        currentPhase = Phase.ICOweek2;
        return true;
    }

    function changePhaseToICOweek3() external isOwner returns (bool){
        currentPhase = Phase.ICOweek3;
        return true;
    }

    function changePhaseToNormalLife() external isOwner returns (bool){
        currentPhase = Phase.NormalLife;
        return true;
    }

    function changeTokenPrice(uint tpico1, uint tpico2, uint tpico3) external isOwner returns (bool){
        oneTokenInWeiSale1 = tpico1;
        oneTokenInWeiSale2 = tpico2;
        oneTokenInWeiSale3 = tpico3;
        return true;
    }

    function finalize() external isOwner returns (bool){
      owner.transfer(this.balance);
      return true;
    }
}