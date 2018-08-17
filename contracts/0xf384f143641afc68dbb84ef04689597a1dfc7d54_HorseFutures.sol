pragma solidity ^0.4.24;

contract BettingInterface {
    // place a bet on a coin(horse) lockBetting
    function placeBet(bytes32 horse) external payable;
    // method to claim the reward amount
    function claim_reward() external;

    mapping (bytes32 =&gt; bool) public winner_horse;
    
    function checkReward() external constant returns (uint);
}

/**
 * @dev Allows to bet on a race and receive future tokens used to withdraw winnings
*/
contract HorseFutures {
    
    event Claimed(address indexed Race, uint256 Count);
    event Selling(bytes32 Id, uint256 Amount, uint256 Price, address indexed Race, bytes32 Horse, address indexed Owner);
    event Buying(bytes32 Id, uint256 Amount, uint256 Price, address indexed Race, bytes32 Horse, address indexed Owner);
    event Canceled(bytes32 Id, address indexed Owner,address indexed Race);
    event Bought(bytes32 Id, uint256 Amount, address indexed Owner, address indexed Race);
    event Sold(bytes32 Id, uint256 Amount, address indexed Owner, address indexed Race);
    event BetPlaced(address indexed EthAddr, address indexed Race);
    
    struct Offer
    {
        uint256 Amount;
        bytes32 Horse;
        uint256 Price;
        address Race;
        bool BuyType;
    }
    
    mapping(address =&gt; mapping(address =&gt; mapping(bytes32 =&gt; uint256))) ClaimTokens;
    mapping(address =&gt; mapping (bytes32 =&gt; uint256)) TotalTokensCoinRace;
    mapping(address =&gt; bool) ClaimedRaces;
    
    mapping(address =&gt; uint256) toDistributeRace;
    //market
    mapping(bytes32 =&gt; Offer) market;
    mapping(bytes32 =&gt; address) owner;
    mapping(address =&gt; uint256) public marketBalance;
    
    function placeBet(bytes32 horse, address race) external payable
    _validRace(race) {
        BettingInterface raceContract = BettingInterface(race);
        raceContract.placeBet.value(msg.value)(horse);
        uint256 c = uint256(msg.value / 1 finney);
        ClaimTokens[msg.sender][race][horse] += c;
        TotalTokensCoinRace[race][horse] += c;

        emit BetPlaced(msg.sender, race);
    }
    
    function getOwnedAndTotalTokens(bytes32 horse, address race) external view
    _validRace(race) 
    returns(uint256,uint256) {
        return (ClaimTokens[msg.sender][race][horse],TotalTokensCoinRace[race][horse]);
    }

    // required for the claimed ether to be transfered here
    function() public payable { }
    
    function claim(address race) external
    _validRace(race) {
        BettingInterface raceContract = BettingInterface(race);
        if(!ClaimedRaces[race]) {
            toDistributeRace[race] = raceContract.checkReward();
            raceContract.claim_reward();
            ClaimedRaces[race] = true;
        }

        uint256 totalWinningTokens = 0;
        uint256 ownedWinningTokens = 0;

        bool btcWin = raceContract.winner_horse(bytes32(&quot;BTC&quot;));
        bool ltcWin = raceContract.winner_horse(bytes32(&quot;LTC&quot;));
        bool ethWin = raceContract.winner_horse(bytes32(&quot;ETH&quot;));

        if(btcWin)
        {
            totalWinningTokens += TotalTokensCoinRace[race][bytes32(&quot;BTC&quot;)];
            ownedWinningTokens += ClaimTokens[msg.sender][race][bytes32(&quot;BTC&quot;)];
            ClaimTokens[msg.sender][race][bytes32(&quot;BTC&quot;)] = 0;
        } 
        if(ltcWin)
        {
            totalWinningTokens += TotalTokensCoinRace[race][bytes32(&quot;LTC&quot;)];
            ownedWinningTokens += ClaimTokens[msg.sender][race][bytes32(&quot;LTC&quot;)];
            ClaimTokens[msg.sender][race][bytes32(&quot;LTC&quot;)] = 0;
        } 
        if(ethWin)
        {
            totalWinningTokens += TotalTokensCoinRace[race][bytes32(&quot;ETH&quot;)];
            ownedWinningTokens += ClaimTokens[msg.sender][race][bytes32(&quot;ETH&quot;)];
            ClaimTokens[msg.sender][race][bytes32(&quot;ETH&quot;)] = 0;
        }

        uint256 claimerCut = toDistributeRace[race] / totalWinningTokens * ownedWinningTokens;
        
        msg.sender.transfer(claimerCut);
        
        emit Claimed(race, claimerCut);
    }
    
    function sellOffer(uint256 amount, uint256 price, address race, bytes32 horse) external
    _validRace(race) 
    _validHorse(horse)
    returns (bytes32) {
        uint256 ownedAmount = ClaimTokens[msg.sender][race][horse];
        require(ownedAmount &gt;= amount);
        require(amount &gt; 0);
        
        bytes32 id = keccak256(abi.encodePacked(amount,price,race,horse,true,block.timestamp));
        require(owner[id] == address(0)); //must not already exist
        
        Offer storage newOffer = market[id];
        
        newOffer.Amount = amount;
        newOffer.Horse = horse;
        newOffer.Price = price;
        newOffer.Race = race;
        newOffer.BuyType = false;
        
        ClaimTokens[msg.sender][race][horse] -= amount;
        owner[id] = msg.sender;
        
        emit Selling(id,amount,price,race,horse,msg.sender);
        
        return id;
    }

    function getOffer(bytes32 id) external view returns(uint256,bytes32,uint256,address,bool) {
        Offer memory off = market[id];
        return (off.Amount,off.Horse,off.Price,off.Race,off.BuyType);
    }
    
    function buyOffer(uint256 amount, uint256 price, address race, bytes32 horse) external payable
    _validRace(race) 
    _validHorse(horse)
    returns (bytes32) {
        require(amount &gt; 0);
        require(price &gt; 0);
        require(msg.value == price * amount);
        bytes32 id = keccak256(abi.encodePacked(amount,price,race,horse,false,block.timestamp));
        require(owner[id] == address(0)); //must not already exist
        
        Offer storage newOffer = market[id];
        
        newOffer.Amount = amount;
        newOffer.Horse = horse;
        newOffer.Price = price;
        newOffer.Race = race;
        newOffer.BuyType = true;
        owner[id] = msg.sender;
        
        emit Buying(id,amount,price,race,horse,msg.sender);
        
        return id;
    }
    
    function cancelOrder(bytes32 id) external {
        require(owner[id] == msg.sender);
        
        Offer memory off = market[id];
        if(off.BuyType) {
            msg.sender.transfer(off.Amount * off.Price);
        }
        else {
            ClaimTokens[msg.sender][off.Race][off.Horse] += off.Amount;
        }
        

        emit Canceled(id,msg.sender,off.Race);
        delete market[id];
        delete owner[id];
    }
    
    function buy(bytes32 id, uint256 amount) external payable {
        require(owner[id] != address(0));
        require(owner[id] != msg.sender);
        Offer storage off = market[id];
        require(!off.BuyType);
        require(amount &lt;= off.Amount);
        uint256 cost = off.Price * amount;
        require(msg.value &gt;= cost);
        
        ClaimTokens[msg.sender][off.Race][off.Horse] += amount;
        marketBalance[owner[id]] += msg.value;

        emit Bought(id,amount,msg.sender, off.Race);
        
        if(off.Amount == amount)
        {
            delete market[id];
            delete owner[id];
        }
        else
        {
            off.Amount -= amount;
        }
    }

    function sell(bytes32 id, uint256 amount) external {
        require(owner[id] != address(0));
        require(owner[id] != msg.sender);
        Offer storage off = market[id];
        require(off.BuyType);
        require(amount &lt;= off.Amount);
        
        uint256 cost = amount * off.Price;
        ClaimTokens[msg.sender][off.Race][off.Horse] -= amount;
        ClaimTokens[owner[id]][off.Race][off.Horse] += amount;
        marketBalance[owner[id]] -= cost;
        marketBalance[msg.sender] += cost;

        emit Sold(id,amount,msg.sender,off.Race);
        
        if(off.Amount == amount)
        {
            delete market[id];
            delete owner[id];
        }
        else
        {
            off.Amount -= amount;
        }
    }
    
    function withdraw() external {
        msg.sender.transfer(marketBalance[msg.sender]);
        marketBalance[msg.sender] = 0;
    }
    
    modifier _validRace(address race) {
        require(race != address(0));
        _;
    }

    modifier _validHorse(bytes32 horse) {
        require(horse == bytes32(&quot;BTC&quot;) || horse == bytes32(&quot;ETH&quot;) || horse == bytes32(&quot;LTC&quot;));
        _;
    }
    
}