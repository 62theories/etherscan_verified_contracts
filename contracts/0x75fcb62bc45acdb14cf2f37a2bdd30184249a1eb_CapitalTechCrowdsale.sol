/*
Capital Technologies &amp; Research - Capital (CALL) &amp; CapitalGAS (CALLG) - Crowdsale Smart Contract
https://www.mycapitalco.in
*/
pragma solidity ^0.4.18;
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
    uint256 c = a / b;
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
contract Ownable {
    address public owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function Ownable() public {
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}
interface Token {
    function transfer(address _to, uint256 _amount) external returns (bool success);
    function balanceOf(address _owner) external returns (uint256 balance);
}
contract FiatContract {
    function USD(uint _id) public constant returns (uint256);
}
contract Crowdsale {
  using SafeMath for uint256;
  Token public token_call;
  Token public token_callg;
  FiatContract public fiat_contract;
  uint256 public maxContributionPerAddress;
  uint256 public startTime;
  uint256 public endTime;
  uint256 public weiRaised;
  uint256 public sale_period;
  uint256 public minInvestment;
  uint256 public softCap;
  bool public sale_state = false;
  string public stage;
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
  modifier nonZeroAddress(address _to) {
    require(_to != 0x0);
    _;
  }
  modifier nonZeroEth() {
	require(msg.value &gt; 0);
    _;
  }
  function Crowdsale(address _token_call, address _token_callg) public nonZeroAddress(_token_call) nonZeroAddress(_token_callg) {
    token_call = Token(_token_call);
    token_callg = Token(_token_callg);
    fiat_contract = FiatContract(0x8055d0504666e2B6942BeB8D6014c964658Ca591);
  }
  function calculateRate(uint256 _amount) public view returns(uint256) {
        uint256 tokenPrice = fiat_contract.USD(0);
        if(startTime.add(15 days) &gt;= block.timestamp) {
            tokenPrice = tokenPrice.mul(200).div(10 ** 8);
        } else if(startTime.add(45 days) &gt;= block.timestamp) {
            tokenPrice = tokenPrice.mul(300).div(10 ** 8);
        } else if(startTime.add(52 days) &gt;= block.timestamp) {
            tokenPrice = tokenPrice.mul(330).div(10 ** 8);
        } else if(startTime.add(59 days) &gt;= block.timestamp) {
            tokenPrice = tokenPrice.mul(360).div(10 ** 8);
        } else if(startTime.add(66 days) &gt;= block.timestamp) {
            tokenPrice = tokenPrice.mul(400).div(10 ** 8);
        } else {
            tokenPrice = tokenPrice.mul(150).div(10 ** 8);
        }
        return _amount.div(tokenPrice).mul(10 ** 10);
  }
  function () external payable {
    buyTokens(msg.sender);
  }
  function compareStages (string a, string b) internal pure returns (bool){
    return keccak256(a) == keccak256(b);
  }
  function buyTokens(address beneficiary) public payable nonZeroAddress(beneficiary) {
    require(validPurchase());
	uint256 weiAmount = msg.value;
    uint256 tokenPrice = fiat_contract.USD(0);
    if(startTime.add(15 days) &gt;= block.timestamp) {
        tokenPrice = tokenPrice.mul(200).div(10 ** 8);
		if(!compareStages(stage, &quot;pre&quot;)){
			stage = &quot;pre&quot;;
		}
    } else if(startTime.add(45 days) &gt;= block.timestamp) {
        tokenPrice = tokenPrice.mul(300).div(10 ** 8);		
		if(!compareStages(stage, &quot;main_first&quot;)){
			stage = &quot;main_first&quot;;
		}
    } else if(startTime.add(52 days) &gt;= block.timestamp) {
        tokenPrice = tokenPrice.mul(330).div(10 ** 8);		
		if(!compareStages(stage, &quot;main_second&quot;)){
			stage = &quot;main_second&quot;;
		}
    } else if(startTime.add(59 days) &gt;= block.timestamp) {
        tokenPrice = tokenPrice.mul(360).div(10 ** 8);
		if(!compareStages(stage, &quot;main_third&quot;)){
			stage = &quot;main_third&quot;;
		}
    } else if(startTime.add(66 days) &gt;= block.timestamp) {
        tokenPrice = tokenPrice.mul(400).div(10 ** 8);
		if(!compareStages(stage, &quot;main_fourth&quot;)){
			stage = &quot;main_fourth&quot;;
		}
    } else {
        tokenPrice = tokenPrice.mul(150).div(10 ** 8);
		if(!compareStages(stage, &quot;private&quot;)){
			stage = &quot;private&quot;;
		}
    }
    uint256 call_units = weiAmount.div(tokenPrice).mul(10 ** 10);
    uint256 callg_units = call_units.mul(200);
    forwardFunds();
    weiRaised = weiRaised.add(weiAmount);
    emit TokenPurchase(msg.sender, beneficiary, weiAmount, call_units);
    require(token_call.transfer(beneficiary, call_units));
    require(token_callg.transfer(beneficiary, callg_units));
  }
  function forwardFunds() internal;
  function hasEnded() public view returns (bool) {
    require(sale_state);
    return block.timestamp &gt; endTime;
  }
  function validPurchase() internal view returns (bool);
}
contract FinalizableCrowdsale is Crowdsale, Ownable {
  using SafeMath for uint256;
  event Finalized();  
  function FinalizableCrowdsale(address _token_call, address _token_callg) Crowdsale(_token_call, _token_callg) public {
      
  }
  function finalize() onlyOwner public {
    require(hasEnded());
    finalization();
    emit Finalized();
	stage = &quot;ended&quot;;
    sale_state = false;
  }
  function finalization() internal ;
}
contract CapitalTechCrowdsale is FinalizableCrowdsale {
  using SafeMath for uint256;
  RefundVault public vault; 
  event BurnedUnsold();
  function CapitalTechCrowdsale( address _wallet, address _token_call, address _token_callg) FinalizableCrowdsale( _token_call, _token_callg) public nonZeroAddress(_wallet) {
    vault = new RefundVault(_wallet);
  }
  function powerUpContract() public onlyOwner{
    require(!sale_state);
	startTime = block.timestamp;
	sale_period = 75 days;
    endTime = block.timestamp.add(sale_period);    
    sale_state = true;
	stage = &quot;private&quot;;
	softCap = 2231250000000000000000000;
	maxContributionPerAddress = 1500 ether;	
	minInvestment = 0.01 ether;
  }
  function transferTokens(address _to, uint256 amount) public onlyOwner nonZeroAddress(_to) {
    require(hasEnded());
    token_call.transfer(_to, amount);
    token_callg.transfer(_to, amount.mul(200));  
  }  
  function forwardFunds() internal {
    vault.deposit.value(msg.value)(msg.sender);
  }
  function claimRefund() public {
    require(!sale_state);
    require(!goalReached());
    vault.refund(msg.sender);
  }
  function withdrawFunds() public onlyOwner{
    require(!sale_state);
    require(goalReached());
    vault.withdrawToWallet();
  }
  function finalization() internal {
    if (goalReached()) {
      burnUnsold();
      vault.close();
    } else {
      vault.enableRefunds();
    }
  }
  function burnUnsold() internal {
    require(!sale_state);
    require(!goalReached());
    token_call.transfer(address(0), token_call.balanceOf(this));
    token_callg.transfer(address(0), token_callg.balanceOf(this));
    emit BurnedUnsold();
  }
  function validPurchase() internal view returns (bool) {
    require(!hasEnded());
    require(msg.value &gt;= minInvestment);
	require(vault.deposited(msg.sender).add(msg.value) &lt;= maxContributionPerAddress); 
    return true;
  }
  function goalReached() public view returns (bool) {
    return token_call.balanceOf(this) &lt;= softCap;
  }
}
contract RefundVault is Ownable {
  using SafeMath for uint256;
  enum State { Active, Refunding, Closed }
  mapping (address =&gt; uint256) public deposited;
  address public wallet;
  State public state;
  event Closed();
  event RefundsEnabled();
  event Refunded(address indexed beneficiary, uint256 weiAmount);
  function RefundVault(address _wallet) public {
    require(_wallet != address(0));
    wallet = _wallet;
    state = State.Active;
  }
  function deposit(address investor) onlyOwner public payable {
    require(state == State.Active);
    deposited[investor] = deposited[investor].add(msg.value);
  }
  function close() onlyOwner public {
    require(state == State.Active);
    state = State.Closed;
    emit Closed();
  }
  function withdrawToWallet() onlyOwner public{
    require(state == State.Closed);
    wallet.transfer(address(this).balance);
  }
  function enableRefunds() onlyOwner public {
    require(state == State.Active);
    state = State.Refunding;
    emit RefundsEnabled();
  }
  function refund(address investor) public {
    require(state == State.Refunding);
    uint256 depositedValue = deposited[investor];
    deposited[investor] = 0;
    emit Refunded(investor, depositedValue);
    investor.transfer(depositedValue);
  }
}