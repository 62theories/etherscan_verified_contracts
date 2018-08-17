pragma solidity ^0.4.17;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function add(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a + b;
        assert(c &gt;= a);
        return c;
    }
    
    function sub(uint256 a, uint256 b) internal constant returns (uint256) {
        // Result must be a positive or zero
        assert(b &lt;= a); 
        return a - b;
    }
    
    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        // Result must be a positive or zero
        if (0 &lt; c) c = 0;   
        return c;
    }

    function div(uint256 a, uint256 b) internal constant returns (uint256) {
        // assert(b &gt; 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn&#39;t hold
        return c;
    }
}

contract Ownable {
  address public owner;

  // The Ownable constructor sets the original `owner` of the contract to the sender account.
  function Ownable() {
    owner = msg.sender;
  }

  // Throws if called by any account other than the owner.
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
}

/**
 *  Main contract: 
 *  *) You can refund eth*3 only between &quot;refundTime&quot; and &quot;ownerTime&quot;.
 *  *) The creator can only get the contract balance after &quot;ownerTime&quot;.  
 *  *) IMPORTANT! If the contract balance is less (you eth*3) then you get only half of the balance.
 *  *) For 3x refund you must pay a fee 0.1 Eth.
*/
contract Multiple3x is Ownable{

    using SafeMath for uint256;
    mapping (address=&gt;uint) public deposits;
    uint public refundTime = 1507719600;     // GMT: 11 October 2017, 11:00
    uint public ownerTime = (refundTime + 1 minutes);   // +1 minute
    uint maxDeposit = 1 ether;  
    uint minDeposit = 100 finney;   // 0.1 eth


    function() payable {
        deposit();
    }
    
    function deposit() payable { 
        require(now &lt; refundTime);
        require(msg.value &gt;= minDeposit);
        
        uint256 dep = deposits[msg.sender];
        uint256 sumDep = msg.value.add(dep);

        if (sumDep &gt; maxDeposit){
            msg.sender.send(sumDep.sub(maxDeposit)); // return of overpaid eth 
            deposits[msg.sender] = maxDeposit;
        }
        else{
            deposits[msg.sender] = sumDep;
        }
    }
    
    function refund() payable { 
        require(now &gt;= refundTime &amp;&amp; now &lt; ownerTime);
        require(msg.value &gt;= 100 finney);        // fee for refund
        
        uint256 dep = deposits[msg.sender];
        uint256 depHalf = this.balance.div(2);
        uint256 dep3x = dep.mul(3);
        deposits[msg.sender] = 0;

        if (this.balance &gt; 0 &amp;&amp; dep3x &gt; 0){
            if (dep3x &gt; this.balance){
                msg.sender.send(dep3x);     // refund 3x
            }
            else{
                msg.sender.send(depHalf);   // refund half of balance
            }
        }
    }
    
    function refundOwner() { 
        require(now &gt;= ownerTime);
        if(owner.send(this.balance)){
            suicide(owner);
        }
    }
}