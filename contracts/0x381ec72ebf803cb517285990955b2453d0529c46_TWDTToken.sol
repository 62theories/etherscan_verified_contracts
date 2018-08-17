pragma solidity ^0.4.20;

//*************** SafeMath ***************

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure  returns (uint256) {
      uint256 c = a * b;
      assert(a == 0 || c / a == b);
      return c;
  }

  function div(uint256 a, uint256 b) internal pure  returns (uint256) {
      assert(b &gt; 0);
      uint256 c = a / b;
      return c;
  }

  function sub(uint256 a, uint256 b) internal pure  returns (uint256) {
      assert(b &lt;= a);
      return a - b;
  }

  function add(uint256 a, uint256 b) internal pure  returns (uint256) {
      uint256 c = a + b;
      assert(c &gt;= a);
      return c;
  }
}

//*************** Ownable *************** 

contract Ownable {
  address public owner;
  address public admin;

  constructor() public {
      owner = msg.sender;
  }

  modifier onlyOwner() {
      require(msg.sender == owner);
      _;
  }

  modifier onlyOwnerAdmin() {
      require(msg.sender == owner || msg.sender == admin);
      _;
  }

  function transferOwnership(address newOwner)public onlyOwner {
      if (newOwner != address(0)) {
        owner = newOwner;
      }
  }
  function setAdmin(address _admin)public onlyOwner {
      admin = _admin;
  }

}

//************* ERC20 *************** 

contract ERC20 {
  
  function balanceOf(address who)public constant returns (uint256);
  function transfer(address to, uint256 value)public returns (bool);
  function transferFrom(address from, address to, uint256 value)public returns (bool);
  function allowance(address owner, address spender)public constant returns (uint256);
  function approve(address spender, uint256 value)public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

//************* TWDT Token *************

contract TWDTToken is ERC20,Ownable {
	using SafeMath for uint256;

	// Token Info.
	string public name;
	string public symbol;
	uint256 public totalSupply;
	uint256 public constant decimals = 6;
    bool public needVerified;


	mapping (address =&gt; uint256) public balanceOf;
	mapping (address =&gt; mapping (address =&gt; uint256)) allowed;
	mapping (address =&gt; bool) public frozenAccount;
	mapping (address =&gt; bool) public frozenAccountSend;
    mapping (address =&gt; bool) public verifiedAccount;
    event FrozenFunds(address target, bool frozen);
    event FrozenFundsSend(address target, bool frozen);
    event VerifiedFunds(address target, bool Verified);
	event FundTransfer(address fundWallet, uint256 amount);
	event Logs(string);
    event Error_No_Binding_Address(address _from, address _to);

	constructor() public {  	
		name=&quot;Taiwan Digital Token&quot;;
		symbol=&quot;TWDT-ETH&quot;;
		totalSupply = 100000000000*(10**decimals);
		balanceOf[msg.sender] = totalSupply;	
	    needVerified = false;
	}

	function balanceOf(address _who)public constant returns (uint256 balance) {
	    return balanceOf[_who];
	}

	function _transferFrom(address _from, address _to, uint256 _value)  internal {
		require(_from != 0x0);
	    require(_to != 0x0);
        // SafeMath 已檢查
        require(balanceOf[_from] &gt;= _value);
        require(balanceOf[_to] + _value &gt;= balanceOf[_to]);
	    require(!frozenAccount[_from]);                  
        require(!frozenAccount[_to]); 
        require(!frozenAccountSend[_from]); 
        if(!needVerified || (needVerified &amp;&amp; verifiedAccount[_from] &amp;&amp; verifiedAccount[_to])){

            uint256 previousBalances = balanceOf[_from] + balanceOf[_to];

            balanceOf[_from] = balanceOf[_from].sub(_value);
            balanceOf[_to] = balanceOf[_to].add(_value);

            emit Transfer(_from, _to, _value);

            assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
        } else {
            emit Error_No_Binding_Address(_from, _to);
        }
	}
	
	function transfer(address _to, uint256 _value) public returns (bool){	    
	    _transferFrom(msg.sender,_to,_value);
	    return true;
	}
	function transferLog(address _to, uint256 _value,string logs) public returns (bool){
		_transferFrom(msg.sender,_to,_value);
		emit Logs(logs);
	    return true;
	}
	
	function ()public {
	}


	function allowance(address _owner, address _spender)public constant returns (uint256 remaining) {
        require(_spender != 0x0);
	    return allowed[_owner][_spender];
	}

	function approve(address _spender, uint256 _value)public returns (bool) {
        require(_spender != 0x0);
	    allowed[msg.sender][_spender] = _value;
	    emit Approval(msg.sender, _spender, _value);
	    return true;
	}
	
	function transferFrom(address _from, address _to, uint256 _value)public returns (bool) {
	    require(_from != 0x0);
	    require(_to != 0x0);
	    require(_value &gt; 0);
	    require(allowed[_from][msg.sender] &gt;= _value);
	    require(balanceOf[_from] &gt;= _value);
	    require(balanceOf[_to] + _value &gt;= balanceOf[_to]);
	    require(!frozenAccount[_from]);                  
        require(!frozenAccount[_to]);
        require(!frozenAccountSend[_from]);   
        if(!needVerified || (needVerified &amp;&amp; verifiedAccount[_from] &amp;&amp; verifiedAccount[_to])){

            allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value); 
            balanceOf[_from] = balanceOf[_from].sub(_value);
            balanceOf[_to] = balanceOf[_to].add(_value);
            
            emit Transfer(_from, _to, _value);
            return true;
        } else {
            emit Error_No_Binding_Address(_from, _to);
            return false;
        }
    }
        
    function freezeAccount(address _target, bool _freeze)  onlyOwnerAdmin public {
        require(_target != 0x0);
        frozenAccount[_target] = _freeze;
        emit FrozenFunds(_target, _freeze);
    }

    function freezeAccountSend(address _target, bool _freeze)  onlyOwnerAdmin public {
        require(_target != 0x0);
        frozenAccountSend[_target] = _freeze;
        emit FrozenFundsSend(_target, _freeze);
    }

    function needVerifiedAccount(bool _needVerified)  onlyOwnerAdmin public {
        needVerified = _needVerified;
    }

    function VerifyAccount(address _target, bool _Verify)  onlyOwnerAdmin public {
        require(_target != 0x0);
        verifiedAccount[_target] = _Verify;
        emit VerifiedFunds(_target, _Verify);
    }

    function mintToken(address _target, uint256 _mintedAmount) onlyOwner public {
        require(_target != 0x0);
        require(_mintedAmount &gt; 0);
        require(!frozenAccount[_target]);
        require(totalSupply + _mintedAmount &gt; totalSupply);
        require(balanceOf[_target] + _mintedAmount &gt; balanceOf[_target]);
        balanceOf[_target] = balanceOf[_target].add(_mintedAmount);
        totalSupply = totalSupply.add(_mintedAmount);
        emit Transfer(0, this, _mintedAmount);
        emit Transfer(this, _target, _mintedAmount);
    }


	
}