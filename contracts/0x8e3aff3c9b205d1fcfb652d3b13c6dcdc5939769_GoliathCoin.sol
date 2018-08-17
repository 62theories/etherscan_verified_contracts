pragma solidity ^0.4.19;

/* 
    http://thegoliathcorp.com/
    https://twitter.com/goliathcoin

    GoliathCoin; the first trustless, decentralized, pre-mined, smart contracting blockchain in the history of cryptocoins. Or something.

    “This thing is basically the new Mt Gox.” 
*/

contract Owned {
    address public owner;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function Owned() public {
        owner = msg.sender;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}

contract GoliathCoin is Owned {
    mapping (address =&gt; mapping (address =&gt; uint256)) public allowance;
    mapping (address =&gt; uint256) public balanceOf;
    uint256 public totalSupply;

    string public name = &quot;Goliath&quot;;
    string public symbol = &quot;GOL&quot;;
    uint8 public decimals = 18;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    event Mint(address indexed _to, uint256 value);
    event Burn(address indexed _from, uint256 value);

    function Token () public {
        totalSupply = 0;
    }

    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(value &lt;= allowance[from][to]);

        allowance[from][to] -= value;
        _transfer(from, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        require(0 == allowance[msg.sender][spender]);
        allowance[msg.sender][spender] = value;
        Approval(msg.sender, spender, value);
        return true;
    }

    function mint(address to, uint256 value) public onlyOwner {
        require(balanceOf[to] + value &gt;= balanceOf[to]);

        balanceOf[to] += value;
        totalSupply += value;
        Mint(to, value);
    }

    function burn(address from, uint256 value) public onlyOwner {
        require(balanceOf[from] &gt;= value);

        balanceOf[from] -= value;
        totalSupply -= value;
        Burn(from, value);
    }

    function _transfer(address from, address to, uint256 value) internal {
        // Checks for validity
        require(to != address(0));
        require(balanceOf[from] &gt;= value);
        require(balanceOf[to] + value &gt;= balanceOf[to]);

        // Actually do the transfer
        balanceOf[from] -= value;
        balanceOf[to] += value;
        Transfer(from, to, value);
    }
}