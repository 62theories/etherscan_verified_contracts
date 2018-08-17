pragma solidity ^0.4.18;

// File: zeppelin/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b &gt; 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn&#39;t hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b &lt;= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c &gt;= a);
    return c;
  }
}

// File: zeppelin/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of &quot;user permissions&quot;.
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

// File: contracts/IFOFirstRound.sol

contract NILTokenInterface is Ownable {
  uint8 public decimals;
  bool public paused;
  bool public mintingFinished;
  uint256 public totalSupply;

  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  function balanceOf(address who) public constant returns (uint256);

  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool);

  function pause() onlyOwner whenNotPaused public;
}

// @dev Handles the pre-IFO

contract IFOFirstRound is Ownable {
  using SafeMath for uint;

  NILTokenInterface public token;

  uint public maxPerWallet = 30000;

  address public project;

  address public founders;

  uint public baseAmount = 1000;

  // pre dist

  uint public preDuration;

  uint public preStartBlock;

  uint public preEndBlock;

  // numbers

  uint public totalParticipants;

  uint public tokenSupply;

  bool public projectFoundersReserved;

  uint public projectReserve = 35;

  uint public foundersReserve = 15;

  // states

  modifier onlyState(bytes32 expectedState) {
    require(expectedState == currentState());
    _;
  }

  function currentState() public constant returns (bytes32) {
    uint bn = block.number;

    if (preStartBlock == 0) {
      return &quot;Inactive&quot;;
    }
    else if (bn &lt; preStartBlock) {
      return &quot;PreDistInitiated&quot;;
    }
    else if (bn &lt;= preEndBlock) {
      return &quot;PreDist&quot;;
    }
    else {
      return &quot;InBetween&quot;;
    }
  }

  // distribution

  function _toNanoNIL(uint amount) internal constant returns (uint) {
    return amount.mul(10 ** uint(token.decimals()));
  }

  function _fromNanoNIL(uint amount) internal constant returns (uint) {
    return amount.div(10 ** uint(token.decimals()));
  }

  // requiring NIL

  function() external payable {
    _getTokens();
  }

  // 0x7a0c396d
  function giveMeNILs() public payable {
    _getTokens();
  }

  function _getTokens() internal {
    require(currentState() == &quot;PreDist&quot; || currentState() == &quot;Dist&quot;);
    require(msg.sender != address(0));

    uint balance = token.balanceOf(msg.sender);
    if (balance == 0) {
      totalParticipants++;
    }

    uint limit = _toNanoNIL(maxPerWallet);

    require(balance &lt; limit);

    uint tokensToBeMinted = _toNanoNIL(getTokensAmount());

    if (balance &gt; 0 &amp;&amp; balance + tokensToBeMinted &gt; limit) {
      tokensToBeMinted = limit.sub(balance);
    }

    token.mint(msg.sender, tokensToBeMinted);

  }

  function getTokensAmount() public constant returns (uint) {
    if (currentState() == &quot;PreDist&quot;) {
      return baseAmount.mul(5);
    } else {
      return 0;
    }
  }

  function startPreDistribution(uint _startBlock, uint _duration, address _project, address _founders, address _token) public onlyOwner onlyState(&quot;Inactive&quot;) {
    require(_startBlock &gt; block.number);
    require(_duration &gt; 0 &amp;&amp; _duration &lt; 30000);
    require(msg.sender != address(0));
    require(_project != address(0));
    require(_founders != address(0));

    token = NILTokenInterface(_token);
    token.pause();
    require(token.paused());

    project = _project;
    founders = _founders;
    preDuration = _duration;
    preStartBlock = _startBlock;
    preEndBlock = _startBlock + _duration;
  }

  function reserveTokensProjectAndFounders() public onlyOwner onlyState(&quot;InBetween&quot;) {
    require(!projectFoundersReserved);

    tokenSupply = 2 * token.totalSupply();

    uint amount = tokenSupply.mul(projectReserve).div(100);
    token.mint(project, amount);
    amount = tokenSupply.mul(foundersReserve).div(100);
    token.mint(founders, amount);
    projectFoundersReserved = true;

    if (this.balance &gt; 0) {
      project.transfer(this.balance);
    }
  }

  function totalSupply() public constant returns (uint){
    require(currentState() != &quot;Inactive&quot;);
    return _fromNanoNIL(token.totalSupply());
  }

  function transferTokenOwnership(address _newOwner) public onlyOwner {
    require(projectFoundersReserved);
    token.transferOwnership(_newOwner);
  }

}