pragma solidity ^0.4.20;


/*
 * ERC20 interface
 * see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {
    uint public totalSupply;
    function balanceOf(address who) constant returns (uint);
    function allowance(address owner, address spender) constant returns (uint);

    function transfer(address to, uint value) returns (bool ok);
    function transferFrom(address from, address to, uint value) returns (bool ok);
    function approve(address spender, uint value) returns (bool ok);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}


/**
 * Math operations with safety checks
 */
contract SafeMath {
    function safeMul(uint a, uint b) internal returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeDiv(uint a, uint b) internal returns (uint) {
        assert(b &gt; 0);
        uint c = a / b;
        assert(a == b * c + a % b);
        return c;
    }

    function safeSub(uint a, uint b) internal returns (uint) {
        assert(b &lt;= a);
        return a - b;
    }

    function safeAdd(uint a, uint b) internal returns (uint) {
        uint c = a + b;
        assert(c &gt;= a &amp;&amp; c &gt;= b);
        return c;
    }

    function max64(uint64 a, uint64 b) internal constant returns (uint64) {
        return a &gt;= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal constant returns (uint64) {
        return a &lt; b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal constant returns (uint256) {
        return a &gt;= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal constant returns (uint256) {
        return a &lt; b ? a : b;
    }

    function assert(bool assertion) internal {
        if (!assertion) {
            throw;
        }
    }

}

/**
 * Owned contract
 */
contract Owned {
    address[] public pools;
    address public owner;

    function Owned() {
        owner = msg.sender;
        pools.push(msg.sender);
    }

    modifier onlyPool {
        require(isPool(msg.sender));
        _;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    /// add new pool address to pools
    function addPool(address newPool) onlyOwner {
        assert (newPool != 0);
        if (isPool(newPool)) throw;
        pools.push(newPool);
    }
    
    /// remove a address from pools
    function removePool(address pool) onlyOwner{
        assert (pool != 0);
        if (!isPool(pool)) throw;
        
        for (uint i=0; i&lt;pools.length - 1; i++) {
            if (pools[i] == pool) {
                pools[i] = pools[pools.length - 1];
                break;
            }
        }
        pools.length -= 1;
    }

    function isPool(address pool) internal returns (bool ok){
        for (uint i=0; i&lt;pools.length; i++) {
            if (pools[i] == pool)
                return true;
        }
        return false;
    }
    
    function transferOwnership(address newOwner) onlyOwner public {
        removePool(owner);
        addPool(newOwner);
        owner = newOwner;
    }
}

/**
 * BP crowdsale contract
*/
contract BPToken is SafeMath, Owned, ERC20 {
    string public constant name = &quot;Backpack Token&quot;;
    string public constant symbol = &quot;BP&quot;;
    uint256 public constant decimals = 18;  

    mapping (address =&gt; uint256) balances;
    mapping (address =&gt; mapping (address =&gt; uint256)) allowed;

    function BPToken() {
        totalSupply = 2000000000 * 10 ** uint256(decimals);
        balances[msg.sender] = totalSupply;
    }

    /// asset pool map
    mapping (address =&gt; address) addressPool;

    /// address base amount
    mapping (address =&gt; uint256) addressAmount;

    /// per month seconds
    uint perMonthSecond = 2592000;
    
    /// calc the balance that the user shuold hold
    function shouldHadBalance(address who) constant returns (uint256){
        if (isPool(who)) return 0;

        address apAddress = getAssetPoolAddress(who);
        uint256 baseAmount  = getBaseAmount(who);

        /// Does not belong to AssetPool contract
        if( (apAddress == address(0)) || (baseAmount == 0) ) return 0;

        /// Instantiate ap contract
        AssetPool ap = AssetPool(apAddress);

        uint startLockTime = ap.getStartLockTime();
        uint stopLockTime = ap.getStopLockTime();

        if (block.timestamp &gt; stopLockTime) {
            return 0;
        }

        if (ap.getBaseLockPercent() == 0) {
            return 0;
        }

        // base lock amount 
        uint256 baseLockAmount = safeDiv(safeMul(baseAmount, ap.getBaseLockPercent()),100);
        if (block.timestamp &lt; startLockTime) {
            return baseLockAmount;
        }
        
        /// will not linear release
        if (ap.getLinearRelease() == 0) {
            if (block.timestamp &lt; stopLockTime) {
                return baseLockAmount;
            } else {
                return 0;
            }
        }
        /// will linear release 

        /// now timestamp before start lock time 
        if (block.timestamp &lt; startLockTime + perMonthSecond) {
            return baseLockAmount;
        }
        // total lock months
        uint lockMonth = safeDiv(safeSub(stopLockTime,startLockTime),perMonthSecond);
        if (lockMonth &lt;= 0) {
            if (block.timestamp &gt;= stopLockTime) {
                return 0;
            } else {
                return baseLockAmount;
            }
        }

        // unlock amount of every month
        uint256 monthUnlockAmount = safeDiv(baseLockAmount,lockMonth);

        // current timestamp passed month 
        uint hadPassMonth = safeDiv(safeSub(block.timestamp,startLockTime),perMonthSecond);

        return safeSub(baseLockAmount,safeMul(hadPassMonth,monthUnlockAmount));
    }

    function getAssetPoolAddress(address who) internal returns(address){
        return addressPool[who];
    }

    function getBaseAmount(address who) internal returns(uint256){
        return addressAmount[who];
    }

    function getBalance() constant returns(uint){
        return balances[msg.sender];
    }

    function setPoolAndAmount(address who, uint256 amount) onlyPool returns (bool) {
        assert(balances[msg.sender] &gt;= amount);

        if (owner == who) {
            return true;
        }
        
        address apAddress = getAssetPoolAddress(who);
        uint256 baseAmount = getBaseAmount(who);

        assert((apAddress == msg.sender) || (baseAmount == 0));

        addressPool[who] = msg.sender;
        addressAmount[who] += amount;

        return true;
    }

    /// get balance of the special address
    function balanceOf(address who) constant returns (uint) {
        return balances[who];
    }

    /// @notice Transfer `value` BP tokens from sender&#39;s account
    /// `msg.sender` to provided account address `to`.
    /// @notice This function is disabled during the funding.
    /// @dev Required state: Success
    /// @param to The address of the recipient
    /// @param value The number of BPs to transfer
    /// @return Whether the transfer was successful or not
    function transfer(address to, uint256 value) returns (bool) {
        if (safeSub(balances[msg.sender],value) &lt; shouldHadBalance(msg.sender)) throw;

        uint256 senderBalance = balances[msg.sender];
        if (senderBalance &gt;= value &amp;&amp; value &gt; 0) {
            senderBalance = safeSub(senderBalance, value);
            balances[msg.sender] = senderBalance;
            balances[to] = safeAdd(balances[to], value);
            Transfer(msg.sender, to, value);
            return true;
        } else {
            throw;
        }
    }

    /// @notice Transfer `value` BP tokens from sender &#39;from&#39;
    /// to provided account address `to`.
    /// @notice This function is disabled during the funding.
    /// @dev Required state: Success
    /// @param from The address of the sender
    /// @param to The address of the recipient
    /// @param value The number of BPs to transfer
    /// @return Whether the transfer was successful or not
    function transferFrom(address from, address to, uint256 value) returns (bool) {
        // Abort if not in Success state.
        // protect against wrapping uints
        if (balances[from] &gt;= value &amp;&amp;
        allowed[from][msg.sender] &gt;= value &amp;&amp;
        safeAdd(balances[to], value) &gt; balances[to])
        {
            balances[to] = safeAdd(balances[to], value);
            balances[from] = safeSub(balances[from], value);
            allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], value);
            Transfer(from, to, value);
            return true;
        } else {
            throw;
        }
    }

    /// @notice `msg.sender` approves `spender` to spend `value` tokens
    /// @param spender The address of the account able to transfer the tokens
    /// @param value The amount of wei to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address spender, uint256 value) returns (bool) {
        if (safeSub(balances[msg.sender],value) &lt; shouldHadBalance(msg.sender)) throw;
        
        // Abort if not in Success state.
        allowed[msg.sender][spender] = value;
        Approval(msg.sender, spender, value);
        return true;
    }

    /// @param owner The address of the account owning tokens
    /// @param spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address owner, address spender) constant returns (uint) {
        uint allow = allowed[owner][spender];
        return allow;
    }
}



contract ownedPool {
    address public owner;

    function ownedPool() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

/**
 * Asset pool contract
*/
contract AssetPool is ownedPool {
    uint  baseLockPercent;
    uint  startLockTime;
    uint  stopLockTime;
    uint  linearRelease;
    address public bpTokenAddress;

    BPToken bp;

    function AssetPool(address _bpTokenAddress, uint _baseLockPercent, uint _startLockTime, uint _stopLockTime, uint _linearRelease) {
        assert(_stopLockTime &gt; _startLockTime);
        
        baseLockPercent = _baseLockPercent;
        startLockTime = _startLockTime;
        stopLockTime = _stopLockTime;
        linearRelease = _linearRelease;

        bpTokenAddress = _bpTokenAddress;
        bp = BPToken(bpTokenAddress);

        owner = msg.sender;
    }
    
    /// set role value
    function setRule(uint _baseLockPercent, uint _startLockTime, uint _stopLockTime, uint _linearRelease) onlyOwner {
        assert(_stopLockTime &gt; _startLockTime);
       
        baseLockPercent = _baseLockPercent;
        startLockTime = _startLockTime;
        stopLockTime = _stopLockTime;
        linearRelease = _linearRelease;
    }

    /// set bp token contract address
    // function setBpToken(address _bpTokenAddress) onlyOwner {
    //     bpTokenAddress = _bpTokenAddress;
    //     bp = BPToken(bpTokenAddress);
    // }
    
    /// assign BP token to another address
    function assign(address to, uint256 amount) onlyOwner returns (bool) {
        if (bp.setPoolAndAmount(to,amount)) {
            if (bp.transfer(to,amount)) {
                return true;
            }
        }
        return false;
    }

    /// get the balance of current asset pool
    function getPoolBalance() constant returns (uint) {
        return bp.getBalance();
    }
    
    function getStartLockTime() constant returns (uint) {
        return startLockTime;
    }
    
    function getStopLockTime() constant returns (uint) {
        return stopLockTime;
    }
    
    function getBaseLockPercent() constant returns (uint) {
        return baseLockPercent;
    }
    
    function getLinearRelease() constant returns (uint) {
        return linearRelease;
    }
}