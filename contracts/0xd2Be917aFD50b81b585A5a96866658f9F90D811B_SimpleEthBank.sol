pragma solidity ^0.4.19;

contract SimpleEthBank {
    address public director;
    mapping (address =&gt; uint) accountBalances;
    mapping (address =&gt; bool) accountExists;

    event Deposit(address from, uint amount);
    event Withdrawal(address from, uint amount);
    event Transfer(address from, address to, uint amount);

    function SimpleEthBank() {
        director = msg.sender;
    }

    function() public payable {
        deposit();
    }

    function getBalanceOf(address addr) public constant returns(int) {
        if (accountExists[addr])
            return int(accountBalances[addr]);
        return -1;
    }

    function deposit() public payable {
        require(msg.value &gt;= 0.5 ether);
        accountBalances[msg.sender] += msg.value;
        accountExists[msg.sender] = true;
        Deposit(msg.sender, msg.value);
    }

    function withdraw(uint amount) public {
        require(accountExists[msg.sender] &amp;&amp; accountBalances[msg.sender] &gt;= amount);
        accountBalances[msg.sender] -= amount;
        msg.sender.call.value(amount);
        Withdrawal(msg.sender, amount);
    }

    function transfer(address to, uint amount) public {
        require(accountExists[msg.sender] &amp;&amp; accountExists[to]);
        require(msg.sender != to);
        require(accountBalances[msg.sender] &gt;= amount);
        accountBalances[to] += amount;
        Transfer(msg.sender, to, amount);
    }

    function kill() public {
        require(msg.sender == director);
        selfdestruct(director);
    }
}