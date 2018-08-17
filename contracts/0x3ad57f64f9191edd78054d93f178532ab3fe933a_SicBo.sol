pragma solidity ^0.4.16;

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c &gt;= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b &lt;= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b &gt; 0);
        c = a / b;
    }
}

contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    function Owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}


contract SicBo is Owned {
    using SafeMath for uint;

    uint public LimitBottom = 0.05 ether;
    uint public LimitTop = 0.2 ether;
    
    address public Drawer;

    struct Game {
        bytes32 Bets;
        bytes32 SecretKey_P;
        bool isPlay;
        bool isPay;
        uint Result;
        uint Time;
        address Buyer;
    }
    
    mapping (bytes32 =&gt; Game) public TicketPool;
    
    event SubmitTicket(bytes32 indexed SecretKey_D_hash, uint Bet_amount, bytes32 Bet, bytes32 SecretKey_P, address Player);   
    event Result(bytes32 indexed SecretKey_D_hash, bytes32 indexed SecretKey_D,address indexed Buyer, uint Dice1, uint Dice2, uint Dice3, uint Game_Result, uint time);
    event Pay(bytes32 indexed SecretKey_D_hash, address indexed Buyer, uint Game_Result);
    event Owe(bytes32 indexed SecretKey_D_hash, address indexed Buyer, uint Game_Result);
    event OwePay(bytes32 indexed SecretKey_D_hash, address indexed Buyer, uint Game_Result);
    
    function SicBo (address drawer_) public {
        Drawer = drawer_;
    }
    
    function submit(bytes32 Bets, bytes32 secretKey_P, bytes32 secretKey_D_hash) payable public {
        
        require(TicketPool[secretKey_D_hash].Time == 0);
        require(msg.value &gt;= LimitBottom &amp;&amp; msg.value &lt;= LimitTop);

        uint  bet_total_amount = 0;
        for (uint i = 0; i &lt; 29; i++) {
            if(Bets[i] == 0x00) continue;
            
            uint bet_amount_ = uint(Bets[i]).mul(10000000000000000);

            bet_total_amount = bet_total_amount.add(bet_amount_);
        }
        
        if(bet_total_amount == msg.value){
            SubmitTicket(secretKey_D_hash, msg.value, Bets, secretKey_P, msg.sender);
            TicketPool[secretKey_D_hash] = Game(Bets,secretKey_P,false,false,0,block.timestamp,msg.sender);
        }else{
            revert();
        }
        
    }
    
    function award(bytes32 secretKey_D) public {
        
        require(Drawer == msg.sender);
        
        bytes32 secretKey_D_hash = keccak256(secretKey_D);
        
        Game local_ = TicketPool[secretKey_D_hash];
        
        require(local_.Time != 0 &amp;&amp; !local_.isPlay);
        
        uint dice1 = uint(keccak256(&quot;Pig World ia a Awesome game place&quot;, local_.SecretKey_P, secretKey_D)) % 6 + 1;
        uint dice2 = uint(keccak256(secretKey_D, &quot;So you will like us so much!!!!&quot;, local_.SecretKey_P)) % 6 + 1;
        uint dice3 = uint(keccak256(local_.SecretKey_P, secretKey_D, &quot;Don&#39;t think this is unfair&quot;, &quot;Our game are always provably fair...&quot;)) % 6 + 1;
    
        uint amount = 0;
        uint total = dice1 + dice2 + dice3;
        
        for (uint ii = 0; ii &lt; 29; ii++) {
            if(local_.Bets[ii] == 0x00) continue;
            
            uint bet_amount = uint(local_.Bets[ii]) * 10000000000000000;
            
            if(ii&gt;=23)
                if (dice1 == ii - 22 || dice2 == ii - 22 || dice3 == ii - 22) {
                    uint8 count = 1;
                    if (dice1 == ii - 22) count++;
                    if (dice2 == ii - 22) count++;
                    if (dice3 == ii - 22) count++;
                    amount += count * bet_amount;
                }

            if(ii&lt;=22)
                if (dice1 == dice2 &amp;&amp; dice2 == dice3 &amp;&amp; dice1 == dice3) {
                    if (ii == 8) {
                        amount += 31 * bet_amount;
                    }
    
                    if(ii &gt;= 2 &amp;&amp; ii &lt;= 7)
                        if (dice1 == ii - 1) {
                            amount += 181 * bet_amount;
                        }
    
                } else {
                    
                    if (ii == 0 &amp;&amp; total &lt;= 10) {
                        amount += 2 * bet_amount;
                    }
                    
                    if (ii == 1 &amp;&amp; total &gt;= 11) {
                        amount += 2 * bet_amount;
                    }
        
                    if(ii&gt;=9){
                        if (ii == 9 &amp;&amp; total == 4) {
                            amount += 61 * bet_amount;
                        }
                        if (ii == 10 &amp;&amp; total == 5) {
                            amount += 31 * bet_amount;
                        }
                        if (ii == 11 &amp;&amp; total == 6) {
                            amount += 18 * bet_amount;
                        }
                        if (ii == 12 &amp;&amp; total == 7) {
                            amount += 13 * bet_amount;
                        }
                        if (ii == 13 &amp;&amp; total == 8) {
                            amount += 9 * bet_amount;
                        }
                        if (ii == 14 &amp;&amp; total == 9) {
                            amount += 8 * bet_amount;
                        }
                        if (ii == 15 &amp;&amp; total == 10) {
                            amount += 7 * bet_amount;
                        }
                        if (ii == 16 &amp;&amp; total == 11) {
                            amount += 7 * bet_amount;
                        }
                        if (ii == 17 &amp;&amp; total == 12) {
                            amount += 8 * bet_amount;
                        }
                        if (ii == 18 &amp;&amp; total == 13) {
                            amount += 9 * bet_amount;
                        }
                        if (ii == 19 &amp;&amp; total == 14) {
                            amount += 13 * bet_amount;
                        }
                        if (ii == 20 &amp;&amp; total == 15) {
                            amount += 18 * bet_amount;
                        }
                        if (ii == 21 &amp;&amp; total == 16) {
                            amount += 31 * bet_amount;
                        }
                        if (ii == 22 &amp;&amp; total == 17) {
                            amount += 61 * bet_amount;
                        }
                    }
                }
        }
        
        if(amount != 0){
            TicketPool[secretKey_D_hash].Result = amount;
            if (address(this).balance &gt;= amount &amp;&amp; TicketPool[secretKey_D_hash].Buyer.send(amount)) {
                TicketPool[secretKey_D_hash].isPay = true;
                Pay(secretKey_D_hash,TicketPool[secretKey_D_hash].Buyer, amount);
            } else {
                Owe(secretKey_D_hash, TicketPool[secretKey_D_hash].Buyer, amount);
                TicketPool[secretKey_D_hash].isPay = false;
            } 
         } else {
            TicketPool[secretKey_D_hash].isPay = true;
        }
        
        Result(secretKey_D_hash, secretKey_D, TicketPool[secretKey_D_hash].Buyer, dice1, dice2, dice3, amount, block.timestamp);
        TicketPool[secretKey_D_hash].isPlay = true;
    }
    
    function () public payable {
       
    }
    
    function withdraw(uint withdrawEther_) public onlyOwner {
        msg.sender.transfer(withdrawEther_);
    }
    
    function changeLimit(uint _bottom, uint _top) public onlyOwner {
        LimitBottom = _bottom;
        LimitTop = _top;
    }
    
    function changeDrawer(address drawer_) public onlyOwner {
        Drawer = drawer_;
    }
    
    function getisPlay(bytes32 secretKey_D_hash) public constant returns (bool isplay){
        return TicketPool[secretKey_D_hash].isPlay;
    }
    
    function getTicketTime(bytes32 secretKey_D_hash) public constant returns (uint Time){
        return TicketPool[secretKey_D_hash].Time;
    }
    
    function chargeOwe(bytes32 secretKey_D_hash) public {
        require(!TicketPool[secretKey_D_hash].isPay);
        require(TicketPool[secretKey_D_hash].isPlay);
        require(TicketPool[secretKey_D_hash].Result != 0);
        
        if(address(this).balance &gt;= TicketPool[secretKey_D_hash].Result){
            if (TicketPool[secretKey_D_hash].Buyer.send(TicketPool[secretKey_D_hash].Result)) {
                TicketPool[secretKey_D_hash].isPay = true;
                OwePay(secretKey_D_hash, TicketPool[secretKey_D_hash].Buyer, TicketPool[secretKey_D_hash].Result);
            }
        } 
    }
}