pragma solidity ^0.4.24;

contract secondContract {
    uint time = block.timestamp;
    uint timeWindow = time + 24 hours;
    function BirthdayBoyClickHere() public view returns(string) {
        require(time &lt; timeWindow);
        return &quot;Happy Birthday Harrison! Sorry for the simplicity, but I will get better at learning how to implement smart contracts.&quot;;
    }

}