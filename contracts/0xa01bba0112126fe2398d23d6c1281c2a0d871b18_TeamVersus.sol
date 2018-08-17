pragma solidity ^0.4.23;

library SafeMath {

    /**
     * @dev Multiplies two numbers, throws on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns(uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
     * @dev Integer division of two numbers, truncating the quotient.
     */
    function div(uint256 a, uint256 b) internal pure returns(uint256) {
        // assert(b &gt; 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn&#39;t hold
        return a / b;
    }

    /**
     * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
        assert(b &lt;= a);
        return a - b;
    }

    /**
     * @dev Adds two numbers, throws on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns(uint256 c) {
        c = a + b;
        assert(c &gt;= a);
        return c;
    }
}

contract Ownable {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
    
    function withdrawAll() public onlyOwner{
        owner.transfer(address(this).balance);
    }

    function withdrawPart(address _to,uint256 _percent) public onlyOwner{
        require(_percent&gt;0&amp;&amp;_percent&lt;=100);
        require(_to != address(0));
        uint256 _amount = address(this).balance - address(this).balance*(100 - _percent)/100;
        if (_amount&gt;0){
            _to.transfer(_amount);
        }
    }
}
contract Pausable is Ownable {

    bool public paused = false;

    modifier whenNotPaused() {
        require(!paused);
        _;
    }


    modifier whenPaused {
        require(paused);
        _;
    }

    function pause() public onlyOwner whenNotPaused returns(bool) {
        paused = true;
        return true;
    }

    function unpause() public onlyOwner whenPaused returns(bool) {
        paused = false;
        return true;
    }

}
contract WWC is Pausable {
    string[33] public teams = [
        &quot;&quot;,
        &quot;Egypt&quot;,              // 1
        &quot;Morocco&quot;,            // 2
        &quot;Nigeria&quot;,            // 3
        &quot;Senegal&quot;,            // 4
        &quot;Tunisia&quot;,            // 5
        &quot;Australia&quot;,          // 6
        &quot;IR Iran&quot;,            // 7
        &quot;Japan&quot;,              // 8
        &quot;Korea Republic&quot;,     // 9
        &quot;Saudi Arabia&quot;,       // 10
        &quot;Belgium&quot;,            // 11
        &quot;Croatia&quot;,            // 12
        &quot;Denmark&quot;,            // 13
        &quot;England&quot;,            // 14
        &quot;France&quot;,             // 15
        &quot;Germany&quot;,            // 16
        &quot;Iceland&quot;,            // 17
        &quot;Poland&quot;,             // 18
        &quot;Portugal&quot;,           // 19
        &quot;Russia&quot;,             // 20
        &quot;Serbia&quot;,             // 21
        &quot;Spain&quot;,              // 22
        &quot;Sweden&quot;,             // 23
        &quot;Switzerland&quot;,        // 24
        &quot;Costa Rica&quot;,         // 25
        &quot;Mexico&quot;,             // 26
        &quot;Panama&quot;,             // 27
        &quot;Argentina&quot;,          // 28
        &quot;Brazil&quot;,             // 29
        &quot;Colombia&quot;,           // 30
        &quot;Peru&quot;,               // 31
        &quot;Uruguay&quot;             // 32
    ];
}

contract Champion is WWC {
    event VoteSuccessful(address user,uint256 team, uint256 amount);
    
    using SafeMath for uint256;
    struct Vote {
        mapping(address =&gt; uint256) amounts;
        uint256 totalAmount;
        address[] users;
        mapping(address =&gt; uint256) weightedAmounts;
        uint256 weightedTotalAmount;
    }
    uint256 public pool;
    Vote[33] votes;
    uint256 public voteCut = 5;
    uint256 public poolCut = 30;
    
    uint256 public teamWon;
    uint256 public voteStopped;
    
    uint256 public minVote = 0.05 ether;
    uint256 public voteWeight = 4;
    
    mapping(address=&gt;uint256) public alreadyWithdraw;

    modifier validTeam(uint256 _teamno) {
        require(_teamno &gt; 0 &amp;&amp; _teamno &lt;= 32);
        _;
    }

    function setVoteWeight(uint256 _w) public onlyOwner{
        require(_w&gt;0&amp;&amp; _w&lt;voteWeight);
        voteWeight = _w;
    }
    
    function setMinVote(uint256 _min) public onlyOwner{
        require(_min&gt;=0.01 ether);
        minVote = _min;
    }
    function setVoteCut(uint256 _cut) public onlyOwner{
        require(_cut&gt;=0&amp;&amp;_cut&lt;=100);
        voteCut = _cut;
    }
    
    function setPoolCut(uint256 _cut) public onlyOwner{
        require(_cut&gt;=0&amp;&amp;_cut&lt;=100);
        poolCut = _cut;
    }
    function getVoteOf(uint256 _team) validTeam(_team) public view returns(
        uint256 totalUsers,
        uint256 totalAmount,
        uint256 meAmount,
        uint256 meWeightedAmount
    ) {
        Vote storage _v = votes[_team];
        totalAmount = _v.totalAmount;
        totalUsers = _v.users.length;
        meAmount = _v.amounts[msg.sender];
        meWeightedAmount = _v.weightedAmounts[msg.sender];
    }

    function voteFor(uint256 _team) validTeam(_team) public payable whenNotPaused {
        require(msg.value &gt;= minVote);
        require(voteStopped == 0);
        userVoteFor(msg.sender, _team, msg.value);
    }

    function userVoteFor(address _user, uint256 _team, uint256 _amount) internal{
        Vote storage _v = votes[_team];
        uint256 voteVal = _amount.sub(_amount.mul(voteCut).div(100));
        if (voteVal&lt;_amount){
            owner.transfer(_amount.sub(voteVal));
        }
        if (_v.amounts[_user] == 0) {
            _v.users.push(_user);
        }
        pool = pool.add(voteVal);
        _v.totalAmount = _v.totalAmount.add(voteVal);
        _v.amounts[_user] = _v.amounts[_user].add(voteVal);
        _v.weightedTotalAmount = _v.weightedTotalAmount.add(voteVal.mul(voteWeight));
        _v.weightedAmounts[_user] = _v.weightedAmounts[_user].add(voteVal.mul(voteWeight)); 
        emit VoteSuccessful(_user,_team,_amount);
    }

    function stopVote()  public onlyOwner {
        require(voteStopped == 0);
        voteStopped = 1;
    }
    
    function setWonTeam(uint256 _team) validTeam(_team) public onlyOwner{
        require(voteStopped == 1);
        teamWon = _team;
    }
    
    function myBonus() public view returns(uint256 _bonus,bool _isTaken){
        if (teamWon==0){
            return (0,false);
        }
        _bonus = bonusAmount(teamWon,msg.sender);
        _isTaken = alreadyWithdraw[msg.sender] == 1;
    }

    function bonusAmount(uint256 _team, address _who) internal view returns(uint256) {
        Vote storage _v = votes[_team];
        if (_v.weightedTotalAmount == 0){
            return 0;
        }
        uint256 _poolAmount = pool.mul(100-poolCut).div(100);
        uint256 _amount = _v.weightedAmounts[_who].mul(_poolAmount).div(_v.weightedTotalAmount);
        return _amount;
    }
    
    function withdrawBonus() public whenNotPaused{
        require(teamWon&gt;0);
        require(alreadyWithdraw[msg.sender]==0);
        alreadyWithdraw[msg.sender] = 1;
        uint256 _amount = bonusAmount(teamWon,msg.sender);
        require(_amount&lt;=address(this).balance);
        if(_amount&gt;0){
            msg.sender.transfer(_amount);
        }
    }
}

contract TeamVersus is WWC {
    event VoteSuccessful(address user,uint256 combatId,uint256 team, uint256 amount);
    using SafeMath for uint256;
    struct Combat{
        uint256 poolOfTeamA;
        uint256 poolOfTeamB;
        uint128 teamAID;         // team id: 1-32
        uint128 teamBID;         // team id: 1-32
        uint128 state;  // 0 not started 1 started 2 ended
        uint128 wonTeamID; // 0 not set
        uint256 errCombat;  // 0 validate 1 errCombat
    }
    mapping (uint256 =&gt; bytes32) public comments;
    
    uint256 public voteCut = 5;
    uint256 public poolCut = 20;
    uint256 public minVote = 0.05 ether;
    Combat[] combats;
    mapping(uint256=&gt;mapping(address=&gt;uint256)) forTeamAInCombat;
    mapping(uint256=&gt;mapping(address=&gt;uint256)) forTeamBInCombat;
    mapping(uint256=&gt;address[]) usersForTeamAInCombat;
    mapping(uint256=&gt;address[]) usersForTeamBInCombat;
    
    mapping(uint256=&gt;mapping(address=&gt;uint256)) public alreadyWithdraw;
    
    function init() public onlyOwner{
        addCombat(1,32,&quot;Friday 15 June&quot;);
        addCombat(2,7,&quot;Friday 15 June&quot;);
        addCombat(19,22,&quot;Friday 15 June&quot;);
        addCombat(15,6,&quot;Saturday 16 June&quot;);
        addCombat(28,17,&quot;Saturday 16 June&quot;);
        addCombat(31,13,&quot;Saturday 16 June&quot;);
        addCombat(12,3,&quot;Saturday 16 June&quot;);
        addCombat(25,21,&quot;Sunday 17 June&quot;);
        addCombat(16,26,&quot;Sunday 17 June&quot;);
        addCombat(29,24,&quot;Sunday 17 June&quot;);
        addCombat(23,9,&quot;Monday 18 June&quot;);
        addCombat(11,27,&quot;Monday 18 June&quot;);
        addCombat(5,14,&quot;Monday 18 June&quot;);
        addCombat(30,8,&quot;Tuesday 19 June&quot;);
        addCombat(18,4,&quot;Tuesday 19 June&quot;);
        addCombat(20,1,&quot;Tuesday 19 June&quot;);
        addCombat(19,2,&quot;Wednesday 20 June&quot;);
        addCombat(32,10,&quot;Wednesday 20 June&quot;);
        addCombat(7,22,&quot;Wednesday 20 June&quot;);
        addCombat(13,6,&quot;Thursday 21 June&quot;);
        addCombat(15,31,&quot;Thursday 21 June&quot;);
        addCombat(28,12,&quot;Thursday 21 June&quot;);
        addCombat(29,25,&quot;Friday 22 June&quot;);
        addCombat(3,17,&quot;Friday 22 June&quot;);
        addCombat(21,24,&quot;Friday 22 June&quot;);
        addCombat(11,5,&quot;Saturday 23 June&quot;);
        addCombat(9,26,&quot;Saturday 23 June&quot;);
        addCombat(16,23,&quot;Saturday 23 June&quot;);
        addCombat(14,27,&quot;Sunday 24 June&quot;);
        addCombat(8,4,&quot;Sunday 24 June&quot;);
        addCombat(18,30,&quot;Sunday 24 June&quot;);
        addCombat(32,20,&quot;Monday 25 June&quot;);
        addCombat(10,1,&quot;Monday 25 June&quot;);
        addCombat(22,2,&quot;Monday 25 June&quot;);
        addCombat(7,19,&quot;Monday 25 June&quot;);
        addCombat(6,31,&quot;Tuesday 26 June&quot;);
        addCombat(13,15,&quot;Tuesday 26 June&quot;);
        addCombat(3,28,&quot;Tuesday 26 June&quot;);
        addCombat(17,12,&quot;Tuesday 26 June&quot;);
        addCombat(9,16,&quot;Wednesday 27 June&quot;);
        addCombat(26,23,&quot;Wednesday 27 June&quot;);
        addCombat(21,29,&quot;Wednesday 27 June&quot;);
        addCombat(24,25,&quot;Wednesday 27 June&quot;);
        addCombat(8,18,&quot;Thursday 28 June&quot;);
        addCombat(4,30,&quot;Thursday 28 June&quot;);
        addCombat(27,5,&quot;Thursday 28 June&quot;);
        addCombat(14,11,&quot;Thursday 28 June&quot;);
    }
    function setMinVote(uint256 _min) public onlyOwner{
        require(_min&gt;=0.01 ether);
        minVote = _min;
    }
    
    function markCombatStarted(uint256 _index) public onlyOwner{
        Combat storage c = combats[_index];
        require(c.errCombat==0 &amp;&amp; c.state==0);
        c.state = 1;
    }
    
    function markCombatEnded(uint256 _index) public onlyOwner{
        Combat storage c = combats[_index];
        require(c.errCombat==0 &amp;&amp; c.state==1);
        c.state = 2;
    }  
    
    function setCombatWonTeam(uint256 _index,uint128 _won) public onlyOwner{
        Combat storage c = combats[_index];
        require(c.errCombat==0 &amp;&amp; c.state==2);
        require(c.teamAID == _won || c.teamBID == _won);
        c.wonTeamID = _won;
    }      

    function withdrawBonus(uint256 _index) public whenNotPaused{
        Combat storage c = combats[_index];
        require(c.errCombat==0 &amp;&amp; c.state ==2 &amp;&amp; c.wonTeamID&gt;0);
        require(alreadyWithdraw[_index][msg.sender]==0);
        alreadyWithdraw[_index][msg.sender] = 1;
        uint256 _amount = bonusAmount(_index,msg.sender);
        require(_amount&lt;=address(this).balance);
        if(_amount&gt;0){
            msg.sender.transfer(_amount);
        }
    }    
    function myBonus(uint256 _index) public view returns(uint256 _bonus,bool _isTaken){
        Combat storage c = combats[_index];
        if (c.wonTeamID==0){
            return (0,false);
        }
        _bonus = bonusAmount(_index,msg.sender);
        _isTaken = alreadyWithdraw[_index][msg.sender] == 1;
    }    
    
    function bonusAmount(uint256 _index,address _who) internal view returns(uint256){
        Combat storage c = combats[_index];
        uint256 _poolAmount = c.poolOfTeamA.add(c.poolOfTeamB).mul(100-poolCut).div(100);
        uint256 _amount = 0;
        if (c.teamAID ==c.wonTeamID){
            if (c.poolOfTeamA == 0){
                return 0;
            }
            _amount = forTeamAInCombat[_index][_who].mul(_poolAmount).div(c.poolOfTeamA);
        }else if (c.teamBID == c.wonTeamID) {
            if (c.poolOfTeamB == 0){
                return 0;
            }            
            _amount = forTeamBInCombat[_index][_who].mul(_poolAmount).div(c.poolOfTeamB);
        }
        return _amount;        
    }
    
    function addCombat(uint128 _teamA,uint128 _teamB,bytes32 _cmt) public onlyOwner{
        Combat memory c = Combat({
            poolOfTeamA: 0,
            poolOfTeamB: 0,
            teamAID: _teamA,
            teamBID: _teamB,
            state: 0,
            wonTeamID: 0,
            errCombat: 0
        });
        uint256 id = combats.push(c) - 1;
        comments[id] = _cmt;
    }
    
    
    function setVoteCut(uint256 _cut) public onlyOwner{
        require(_cut&gt;=0&amp;&amp;_cut&lt;=100);
        voteCut = _cut;
    }
    
    function setPoolCut(uint256 _cut) public onlyOwner{
        require(_cut&gt;=0&amp;&amp;_cut&lt;=100);
        poolCut = _cut;
    }    
    
    function getCombat(uint256 _index) public view returns(
        uint128 teamAID,
        string teamAName,
        uint128 teamBID,
        string teamBName,
        uint128 wonTeamID,
        uint256 poolOfTeamA,
        uint256 poolOfTeamB,
        uint256 meAmountForTeamA,
        uint256 meAmountForTeamB,
        uint256 state,
        bool isError,
        bytes32 comment
    ){
        Combat storage c = combats[_index];
        teamAID = c.teamAID;
        teamAName = teams[c.teamAID];
        teamBID = c.teamBID;
        teamBName = teams[c.teamBID];
        wonTeamID = c.wonTeamID;
        state = c.state;
        poolOfTeamA = c.poolOfTeamA;
        poolOfTeamB = c.poolOfTeamB;
        meAmountForTeamA = forTeamAInCombat[_index][msg.sender];
        meAmountForTeamB = forTeamBInCombat[_index][msg.sender];
        isError = c.errCombat == 1;
        comment = comments[_index];
    }
    
    function getCombatsCount() public view returns(uint256){
        return combats.length;
    }
    
    function invalidateCombat(uint256 _index) public onlyOwner{
        Combat storage c = combats[_index];
        require(c.errCombat==0);
        c.errCombat = 1;
    }
    
    function voteFor(uint256 _index,uint256 _whichTeam) public payable whenNotPaused{
        require(msg.value&gt;=minVote);
        Combat storage c = combats[_index];
        require(c.errCombat==0 &amp;&amp; c.state == 0 &amp;&amp; c.wonTeamID==0);
        userVoteFor(msg.sender, _index,_whichTeam, msg.value);
    }

    function userVoteFor(address _standFor, uint256 _index,uint256 _whichTeam, uint256 _amount) internal{
        Combat storage c = combats[_index];
        uint256 voteVal = _amount.sub(_amount.mul(voteCut).div(100));
        if (voteVal&lt;_amount){
            owner.transfer(_amount.sub(voteVal));
        }
        if (_whichTeam == c.teamAID){
            c.poolOfTeamA = c.poolOfTeamA.add(voteVal);
            if (forTeamAInCombat[_index][_standFor]==0){
                usersForTeamAInCombat[_index].push(_standFor);
            }
            forTeamAInCombat[_index][_standFor] = forTeamAInCombat[_index][_standFor].add(voteVal);
        }else {
            c.poolOfTeamB = c.poolOfTeamB.add(voteVal);
            if (forTeamBInCombat[_index][_standFor]==0){
                usersForTeamBInCombat[_index].push(_standFor);
            }
            forTeamBInCombat[_index][_standFor] = forTeamAInCombat[_index][_standFor].add(voteVal);            
        }
        emit VoteSuccessful(_standFor,_index,_whichTeam,_amount);
    }    
    
    function refundErrCombat(uint256 _index) public whenNotPaused{
        Combat storage c = combats[_index];
        require(c.errCombat == 1);
        uint256 _amount = forTeamAInCombat[_index][msg.sender].add(forTeamBInCombat[_index][msg.sender]);
        require(_amount&gt;0);

        forTeamAInCombat[_index][msg.sender] = 0;
        forTeamBInCombat[_index][msg.sender] = 0;
        msg.sender.transfer(_amount);
    }
}