pragma solidity ^0.4.24;

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
     return a / b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b &lt;= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c &gt;= a);
    return c;
  }
}

contract Ownable {
	address public owner;
	address public newOwner;

	event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);

	constructor() public {
		owner = msg.sender;
		newOwner = address(0);
	}

	modifier onlyOwner() {
		require(msg.sender == owner, &quot;msg.sender == owner&quot;);
		_;
	}

	function transferOwnership(address _newOwner) public onlyOwner {
		require(address(0) != _newOwner, &quot;address(0) != _newOwner&quot;);
		newOwner = _newOwner;
	}

	function acceptOwnership() public {
		require(msg.sender == newOwner, &quot;msg.sender == newOwner&quot;);
		emit OwnershipTransferred(owner, msg.sender);
		owner = msg.sender;
		newOwner = address(0);
	}
}

contract tokenInterface {
	function balanceOf(address _owner) public constant returns (uint256 balance);
	function transfer(address _to, uint256 _value) public returns (bool);
	function burn(uint256 _value) public returns(bool);
	uint256 public totalSupply;
	uint256 public decimals;
}

contract AtomaxKycInterface {

    // false if the ico is not started, true if the ico is started and running, true if the ico is completed
    function started() public view returns(bool);

    // false if the ico is not started, false if the ico is started and running, true if the ico is completed
    function ended() public view returns(bool);

    // time stamp of the starting time of the ico, must return 0 if it depends on the block number
    function startTime() public view returns(uint256);

    // time stamp of the ending time of the ico, must retrun 0 if it depends on the block number
    function endTime() public view returns(uint256);

    // returns the total number of the tokens available for the sale, must not change when the ico is started
    function totalTokens() public view returns(uint256);

    // returns the number of the tokens available for the ico. At the moment that the ico starts it must be equal to totalTokens(),
    // then it will decrease. It is used to calculate the percentage of sold tokens as remainingTokens() / totalTokens()
    function remainingTokens() public view returns(uint256);

    // return the price as number of tokens released for each ether
    function price() public view returns(uint256);
}

contract AtomaxKyc {
    using SafeMath for uint256;

    mapping (address =&gt; bool) public isKycSigner;
    mapping (bytes32 =&gt; uint256) public alreadyPayed;

    event KycVerified(address indexed signer, address buyerAddress, bytes32 buyerId, uint maxAmount);

    constructor() internal {
        isKycSigner[0x9787295cdAb28b6640bc7e7db52b447B56b1b1f0] = true; //ATOMAX KYC 1 SIGNER
        isKycSigner[0x3b3f379e49cD95937121567EE696dB6657861FB0] = true; //ATOMAX KYC 2 SIGNER
    }

    // Must be implemented in descending contract to assign tokens to the buyers. Called after the KYC verification is passed
    function releaseTokensTo(address buyer) internal returns(bool);

    
    function buyTokensFor(address _buyerAddress, bytes32 _buyerId, uint _maxAmount, uint8 _v, bytes32 _r, bytes32 _s, uint8 _bv, bytes32 _br, bytes32 _bs) public payable returns (bool) {
        bytes32 hash = hasher ( _buyerAddress,  _buyerId,  _maxAmount );
        address signer = ecrecover(hash, _bv, _br, _bs);
        require ( signer == _buyerAddress, &quot;signer == _buyerAddress &quot; );
        
        return buyImplementation(_buyerAddress, _buyerId, _maxAmount, _v, _r, _s);
    }
    
    function buyTokens(bytes32 buyerId, uint maxAmount, uint8 v, bytes32 r, bytes32 s) public payable returns (bool) {
        return buyImplementation(msg.sender, buyerId, maxAmount, v, r, s);
    }

    function buyImplementation(address _buyerAddress, bytes32 _buyerId, uint256 _maxAmount, uint8 _v, bytes32 _r, bytes32 _s) private returns (bool) {
        // check the signature
        bytes32 hash = hasher ( _buyerAddress,  _buyerId,  _maxAmount );
        address signer = ecrecover(hash, _v, _r, _s);
		
		require( isKycSigner[signer], &quot;isKycSigner[signer]&quot;);
        
		uint256 totalPayed = alreadyPayed[_buyerId].add(msg.value);
		require(totalPayed &lt;= _maxAmount);
		alreadyPayed[_buyerId] = totalPayed;
		
		emit KycVerified(signer, _buyerAddress, _buyerId, _maxAmount);
		return releaseTokensTo(_buyerAddress);

    }
    
    function hasher (address _buyerAddress, bytes32 _buyerId, uint256 _maxAmount) public view returns ( bytes32 hash ) {
        hash = keccak256(abi.encodePacked(&quot;Atomax authorization:&quot;, this, _buyerAddress, _buyerId, _maxAmount));
    }
}

contract RC_KYC is AtomaxKycInterface, AtomaxKyc {
    using SafeMath for uint256;
    
    TokedoDaico tokenSaleContract;
    
    uint256 public startTime;
    uint256 public endTime;
    
    uint256 public etherMinimum;
    uint256 public soldTokens;
    uint256 public remainingTokens;
    uint256 public tokenPrice;
	
	mapping(address =&gt; uint256) public etherUser; // address =&gt; ether amount
	mapping(address =&gt; uint256) public pendingTokenUser; // address =&gt; token amount that will be claimed after KYC
	mapping(address =&gt; uint256) public tokenUser; // address =&gt; token amount owned
	
    constructor(address _tokenSaleContract, uint256 _tokenPrice, uint256 _remainingTokens, uint256 _etherMinimum, uint256 _startTime , uint256 _endTime) public {
        require ( _tokenSaleContract != address(0), &quot;_tokenSaleContract != address(0)&quot; );
        require ( _tokenPrice != 0, &quot;_tokenPrice != 0&quot; );
        require ( _remainingTokens != 0, &quot;_remainingTokens != 0&quot; );  
        require ( _startTime != 0, &quot;_startTime != 0&quot; );
        require ( _endTime != 0, &quot;_endTime != 0&quot; );
        
        tokenSaleContract = TokedoDaico(_tokenSaleContract);
        
        soldTokens = 0;
        remainingTokens = _remainingTokens;
        tokenPrice = _tokenPrice;
        etherMinimum = _etherMinimum;
        
        startTime = _startTime;
        endTime = _endTime;
    }
    
    modifier onlyTokenSaleOwner() {
        require(msg.sender == tokenSaleContract.owner() );
        _;
    }
    
    function setTime(uint256 _newStart, uint256 _newEnd) public onlyTokenSaleOwner {
        if ( _newStart != 0 ) startTime = _newStart;
        if ( _newEnd != 0 ) endTime = _newEnd;
    }
    
    function changeMinimum(uint256 _newEtherMinimum) public onlyTokenSaleOwner {
        etherMinimum = _newEtherMinimum;
    }
    
    function releaseTokensTo(address buyer) internal returns(bool) {
        if( msg.value &gt; 0 ) takeEther(buyer);
        giveToken(buyer);
        return true;
    }
    
    function started() public view returns(bool) {
        return now &gt; startTime || remainingTokens == 0;
    }
    
    function ended() public view returns(bool) {
        return now &gt; endTime || remainingTokens == 0;
    }
    
    function startTime() public view returns(uint) {
        return startTime;
    }
    
    function endTime() public view returns(uint) {
        return endTime;
    }
    
    function totalTokens() public view returns(uint) {
        return remainingTokens.add(soldTokens);
    }
    
    function remainingTokens() public view returns(uint) {
        return remainingTokens;
    }
    
    function price() public view returns(uint) {
        return uint256(1 ether).div( tokenPrice ).mul( 10 ** uint256(tokenSaleContract.decimals()) );
    }
	
	function () public payable{
	    takeEther(msg.sender);
	}
	
	event TakeEther(address buyer, uint256 value, uint256 soldToken, uint256 tokenPrice );
	
	function takeEther(address _buyer) internal {
	    require( now &gt; startTime, &quot;now &gt; startTime&quot; );
		require( now &lt; endTime, &quot;now &lt; endTime&quot;);
        require( msg.value &gt;= etherMinimum, &quot;msg.value &gt;= etherMinimum&quot;); 
        require( remainingTokens &gt; 0, &quot;remainingTokens &gt; 0&quot; );
        
        uint256 oneToken = 10 ** uint256(tokenSaleContract.decimals());
        uint256 tokenAmount = msg.value.mul( oneToken ).div( tokenPrice );
        
        uint256 remainingTokensGlobal = tokenInterface( tokenSaleContract.tokenContract() ).balanceOf( address(tokenSaleContract) );
        
        uint256 remainingTokensApplied;
        if ( remainingTokensGlobal &gt; remainingTokens ) { 
            remainingTokensApplied = remainingTokens;
        } else {
            remainingTokensApplied = remainingTokensGlobal;
        }
        
        uint256 refund = 0;
        if ( remainingTokensApplied &lt; tokenAmount ) {
            refund = (tokenAmount - remainingTokensApplied).mul(tokenPrice).div(oneToken);
            tokenAmount = remainingTokensApplied;
			remainingTokens = 0; // set remaining token to 0
            _buyer.transfer(refund);
        } else {
			remainingTokens = remainingTokens.sub(tokenAmount); // update remaining token without bonus
        }
        
        etherUser[_buyer] = etherUser[_buyer].add(msg.value.sub(refund));
        pendingTokenUser[_buyer] = pendingTokenUser[_buyer].add(tokenAmount);	
        
        emit TakeEther( _buyer, msg.value, tokenAmount, tokenPrice );
	}
	
	function giveToken(address _buyer) internal {
	    require( pendingTokenUser[_buyer] &gt; 0, &quot;pendingTokenUser[_buyer] &gt; 0&quot; );

		tokenUser[_buyer] = tokenUser[_buyer].add(pendingTokenUser[_buyer]);
	
		tokenSaleContract.sendTokens(_buyer, pendingTokenUser[_buyer]);
		soldTokens = soldTokens.add(pendingTokenUser[_buyer]);
		pendingTokenUser[_buyer] = 0;
		
		require( address(tokenSaleContract).call.value( etherUser[_buyer] )( bytes4( keccak256(&quot;forwardEther()&quot;) ) ) );
		etherUser[_buyer] = 0;
	}

    function refundEther(address to) public onlyTokenSaleOwner {
        to.transfer(etherUser[to]);
        etherUser[to] = 0;
        pendingTokenUser[to] = 0;
    }
    
    function withdraw(address to, uint256 value) public onlyTokenSaleOwner { 
        to.transfer(value);
    }
	
	function userBalance(address _user) public view returns( uint256 _pendingTokenUser, uint256 _tokenUser, uint256 _etherUser ) {
		return (pendingTokenUser[_user], tokenUser[_user], etherUser[_user]);
	}
}

contract TokedoDaico is Ownable {
    using SafeMath for uint256;
    
    tokenInterface public tokenContract;
    
    address public milestoneSystem;
	uint256 public decimals;
    uint256 public tokenPrice;

    mapping(address =&gt; bool) public rc;

    constructor(address _wallet, address _tokenAddress, uint256[] _time, uint256[] _funds, uint256 _tokenPrice, uint256 _activeSupply) public {
        tokenContract = tokenInterface(_tokenAddress);
        decimals = tokenContract.decimals();
        tokenPrice = _tokenPrice;
        milestoneSystem = new MilestoneSystem(_wallet,_tokenAddress, _time, _funds, _tokenPrice, _activeSupply);
    }
    
    modifier onlyRC() {
        require( rc[msg.sender], &quot;rc[msg.sender]&quot; ); //check if is an authorized rcContract
        _;
    }
    
    function forwardEther() onlyRC payable public returns(bool) {
        require(milestoneSystem.call.value(msg.value)(), &quot;wallet.call.value(msg.value)()&quot;);
        return true;
    }
    
	function sendTokens(address _buyer, uint256 _amount) onlyRC public returns(bool) {
        return tokenContract.transfer(_buyer, _amount);
    }

    event NewRC(address contr);
    
    function addRC(address _rc) onlyOwner public {
        rc[ _rc ]  = true;
        emit NewRC(_rc);
    }
    
    function withdrawTokens(address to, uint256 value) public onlyOwner returns (bool) {
        return tokenContract.transfer(to, value);
    }
    
    function setTokenContract(address _tokenContract) public onlyOwner {
        tokenContract = tokenInterface(_tokenContract);
    }
}

contract MilestoneSystem {
    using SafeMath for uint256;
    
    tokenInterface public tokenContract;
    TokedoDaico public tokenSaleContract;
    
    uint256[] public time;
    uint256[] public funds;
    
    bool public locked = false; 
    uint256 public endTimeToReturnTokens; 
    
    uint8 public step = 0;
    
    uint256 public constant timeframeMilestone = 3 days; 
    uint256 public constant timeframeDeath = 30 days; 
    
    uint256 public activeSupply;
    
    uint256 public tokenPrice;
    
    uint256 public etherReceived;
    address public wallet;
    
    mapping(address =&gt; mapping(uint8 =&gt; uint256) ) public balance;
    mapping(uint8 =&gt; uint256) public tokenDistrusted;
    
    constructor(address _wallet, address _tokenAddress, uint256[] _time, uint256[] _funds, uint256 _tokenPrice, uint256 _activeSupply) public {
        require( _wallet != address(0), &quot;_wallet != address(0)&quot; );
        require( _time.length != 0, &quot;_time.length != 0&quot; );
        require( _time.length == _funds.length, &quot;_time.length == _funds.length&quot; );
        
        wallet = _wallet;
        
        tokenContract = tokenInterface(_tokenAddress);
        tokenSaleContract = TokedoDaico(msg.sender);
        
        time = _time;
        funds = _funds;
        
        activeSupply = _activeSupply;
        tokenPrice = _tokenPrice;
    }
    
    modifier onlyTokenSaleOwner() {
        require(msg.sender == tokenSaleContract.owner(), &quot;msg.sender == tokenSaleContract.owner()&quot; );
        _;
    }
    
    event Distrust(address sender, uint256 amount);
    event Locked();
    
    function distrust(address _from, uint _value, bytes _data) public {
        require(msg.sender == address(tokenContract), &quot;msg.sender == address(tokenContract)&quot;);
        
        if ( !locked ) {
            
            uint256 startTimeMilestone = time[step].sub(timeframeMilestone);
            uint256 endTimeMilestone = time[step];
            uint256 startTimeProjectDeath = time[step].add(timeframeDeath);
            bool unclaimedFunds = funds[step] &gt; 0;
            
            require( 
                ( now &gt; startTimeMilestone &amp;&amp; now &lt; endTimeMilestone ) || 
                ( now &gt; startTimeProjectDeath &amp;&amp; unclaimedFunds ), 
                &quot;( now &gt; startTimeMilestone &amp;&amp; now &lt; endTimeMilestone ) || ( now &gt; startTimeProjectDeath &amp;&amp; unclaimedFunds )&quot; 
            );
        } else {
            require( locked &amp;&amp; now &lt; endTimeToReturnTokens ); //a timeframePost to deposit all tokens and then claim the refundMe method
        }
        
        balance[_from][step] = balance[_from][step].add(_value);
        tokenDistrusted[step] = tokenDistrusted[step].add(_value);
        
        emit Distrust(msg.sender, _value);
        
        if( tokenDistrusted[step] &gt; activeSupply &amp;&amp; !locked ) {
            locked = true;
            endTimeToReturnTokens = now.add(timeframeDeath);
            emit Locked();
        }
    }
    
    function tokenFallback(address _from, uint _value, bytes _data) public {
        distrust( _from, _value, _data);
    }
	
	function receiveApproval( address _from, uint _value, bytes _data) public {
	    require(msg.sender == address(tokenContract), &quot;msg.sender == address(tokenContract)&quot;);
		require(msg.sender.call(bytes4(keccak256(&quot;transferFrom(address,address,uint256)&quot;)), _from, this, _value));
        distrust( _from, _value, _data);
    }
    
    event Trust(address sender, uint256 amount);
    event Unlocked();
    
    function trust(uint8 _step) public {
        require( balance[msg.sender][_step] &gt; 0 , &quot;balance[msg.sender] &gt; 0&quot;);
        
        uint256 amount = balance[msg.sender][_step];
        balance[msg.sender][_step] = 0;
        
        tokenDistrusted[_step] = tokenDistrusted[_step].sub(amount);
        tokenContract.transfer(msg.sender, amount);
        
        emit Trust(msg.sender, amount);
        
        if( tokenDistrusted[step] &lt;= activeSupply &amp;&amp; locked ) {
            locked = false;
            endTimeToReturnTokens = 0;
            emit Unlocked();
        }
    }
    
    event Refund(address sender, uint256 money);
    
    function refundMe() public {
        require(locked, &quot;locked&quot;);
        require( now &gt; endTimeToReturnTokens, &quot;now &gt; endTimeToReturnTokens&quot; );
        
        uint256 ethTot = address(this).balance;
        require( ethTot &gt; 0 , &quot;ethTot &gt; 0&quot;);
        
        uint256 tknAmount = balance[msg.sender][step];
        require( tknAmount &gt; 0 , &quot;tknAmount &gt; 0&quot;);
        
        balance[msg.sender][step] = 0;
        
        tokenContract.burn(tknAmount);
        
        uint256 tknTot = tokenDistrusted[step];
        uint256 rate = tknAmount.mul(1e18).div(tknTot);
        uint256 money = ethTot.mul(rate).div(1e18);
        
        if( money &gt; address(this).balance ) {
		    money = address(this).balance;
		}
        msg.sender.transfer(money);
        
        emit Refund(msg.sender, money);
    }
    
    function ownerWithdraw() public onlyTokenSaleOwner {
        require(!locked, &quot;!locked&quot;);
        
        require(now &gt; time[step], &quot;now &gt; time[step]&quot;);
        require(funds[step] &gt; 0, &quot;funds[step] &gt; 0&quot;);
        
        uint256 amountApplied = funds[step];
        funds[step] = 0;
		step = step+1;
		
		uint256 value;
		if( amountApplied &gt; address(this).balance || time.length == step+1)
		    value = address(this).balance;
		else {
		    value = amountApplied;
		}
		
        msg.sender.transfer(value);
    }
    
    function ownerWithdrawTokens(address _tokenContract, address to, uint256 value) public onlyTokenSaleOwner returns (bool) { //for airdrop reason to distribute to Tokedo Token Holder
        require( _tokenContract != address(tokenContract), &quot;_tokenContract != address(tokenContract)&quot;); // the owner can withdraw tokens except Tokedo Tokens
        return tokenInterface(_tokenContract).transfer(to, value);
    }
    
    function setWallet(address _wallet) public onlyTokenSaleOwner returns(bool) {
        require( _wallet != address(0), &quot;_wallet != address(0)&quot; );
        wallet = _wallet;
		return true;
    }
    
    function () public payable {
        require(msg.sender == address(tokenSaleContract), &quot;msg.sender == address(tokenSaleContract)&quot;);
        
        if( etherReceived &lt; funds[0]  ) {
            require( wallet != address(0), &quot;wallet != address(0)&quot; );
            wallet.transfer(msg.value);
        }
        
        etherReceived = etherReceived.add(msg.value);
    }
}