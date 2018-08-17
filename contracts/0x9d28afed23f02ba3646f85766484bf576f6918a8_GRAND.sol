pragma solidity ^0.4.21;

contract Ownable { 
    address public owner;
    function Ownable() public { owner = address(this); }
}

contract GRAND is Ownable {
    
    string public version           = &quot;3.0.3&quot;;
    string public name              = &quot;GRAND&quot;;
    string public symbol            = &quot;G&quot;;

    uint256 public totalSupply      = 100000000000000000000000 * 1000;
    uint8 public decimals           = 15;
    
    mapping (address =&gt; uint256) public balanceOf;
       
    event Transfer(address indexed from, address indexed to, uint256 value);
   
    function GRAND () public {
        balanceOf[msg.sender]   = totalSupply;
        _transfer (msg.sender, address(this), totalSupply);
    }
   
    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != 0x0);
        require(balanceOf[_from] &gt;= _value);
        require(balanceOf[_to] + _value &gt; balanceOf[_to]);
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    function transfer(address _to, uint256 _value) public {
        if (_to == address(this)) { require(msg.sender.send(_value)); }
        _transfer(msg.sender, _to, _value);
    }
     
    function () payable public {
        uint256 amount               = msg.value;
        balanceOf[owner]             = balanceOf[owner] - amount;
        balanceOf[msg.sender]        = balanceOf[msg.sender]  + amount;
        emit Transfer(owner, msg.sender, msg.value);
    }
}