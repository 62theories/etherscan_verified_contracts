pragma solidity ^0.4.24;

contract birthdayTest {
    
    uint originalTime;
    
    constructor() public{
        originalTime = now;
    }
    
    
    //prints a birthday message and then becomes impossible to execute after 23 hours
    function BirthdayBoyClickHere() public view returns(string) {
        require(now &lt; originalTime + 23 hours);
        return &quot;Happy Birthday Harrison! I know this contract is noobish but I will get better.&quot;;
    }

}