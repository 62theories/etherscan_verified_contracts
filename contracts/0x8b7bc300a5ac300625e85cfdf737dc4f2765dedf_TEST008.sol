pragma solidity ^0.4.24;

    /*
    Wo Men Yi Qi Lai Nian Fo:
    अमिताभ अमिताभ अमिताभ अमिताभ अमिताभ अमिताभ अमिताभ अमिताभ अमिताभ अमिताभ.
    འོད་དཔག་མེད། འོད་དཔག་མེད། འོད་དཔག་མེད། འོད་དཔག་མེད། འོད་དཔག་མེད། འོད་དཔག་མེད། འོད་དཔག་མེད། འོད་དཔག་མེད། འོད་དཔག་མེད། འོད་དཔག་མེད།.
    아미타불 아미타불 아미타불 아미타불 아미타불 아미타불 아미타불 아미타불 아미타불 아미타불.
    阿弥陀佛 阿弥陀佛 阿弥陀佛 阿弥陀佛 阿弥陀佛 阿弥陀佛 阿弥陀佛 阿弥陀佛 阿弥陀佛 阿弥陀佛.
    阿彌陀佛 阿彌陀佛 阿彌陀佛 阿彌陀佛 阿彌陀佛 阿彌陀佛 阿彌陀佛 阿彌陀佛 阿彌陀佛 阿彌陀佛.
    Amitabha Amitabha Amitabha Amitabha Amitabha Amitabha Amitabha Amitabha Amitabha Amitabha.
    พระอมิตาภพุทธะ พระอมิตาภพุทธะ พระอมิตาภพุทธะ พระอมิตาภพุทธะ พระอมิตาภพุทธะ พระอมิตาภพุทธะ พระอมิตาภพุทธะ พระอมิตาภพุทธะ พระอมิตาภพุทธะ พระอมิตาภพุทธะ.
    Adiđ&#224;phật Adiđ&#224;phật Adiđ&#224;phật Adiđ&#224;phật Adiđ&#224;phật Adiđ&#224;phật Adiđ&#224;phật Adiđ&#224;phật Adiđ&#224;phật Adiđ&#224;phật.
    ᠴᠠᠭᠯᠠᠰᠢ ᠦᠭᠡᠢ ᠭᠡᠷᠡᠯᠲᠦ ᠴᠠᠭᠯᠠᠰᠢ ᠦᠭᠡᠢ ᠭᠡᠷᠡᠯᠲᠦ ᠴᠠᠭᠯᠠᠰᠢ ᠦᠭᠡᠢ ᠭᠡᠷᠡᠯᠲᠦ ᠴᠠᠭᠯᠠᠰᠢ ᠦᠭᠡᠢ ᠭᠡᠷᠡᠯᠲᠦ ᠴᠠᠭᠯᠠᠰᠢ ᠦᠭᠡᠢ ᠭᠡᠷᠡᠯᠲᠦ ᠴᠠᠭᠯᠠᠰᠢ ᠦᠭᠡᠢ ᠭᠡᠷᠡᠯᠲᠦ ᠴᠠᠭᠯᠠᠰᠢ ᠦᠭᠡᠢ ᠭᠡᠷᠡᠯᠲᠦ ᠴᠠᠭᠯᠠᠰᠢ ᠦᠭᠡᠢ ᠭᠡᠷᠡᠯᠲᠦ ᠴᠠᠭᠯᠠᠰᠢ ᠦᠭᠡᠢ ᠭᠡᠷᠡᠯᠲᠦ ᠴᠠᠭᠯᠠᠰᠢ ᠦᠭᠡᠢ ᠭᠡᠷᠡᠯᠲᠦ.
    Jiang Wo Suo Xiu De Yi Qie Gong De,Hui Xiang Gei Fa Jie Yi Qie Zhong Sheng.
    */

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    require(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b &lt;= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c &gt;= a);
    return c;
  }
}


contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}


contract TEST008 is Ownable{
    
    using SafeMath for uint256;
    
    string public constant name       = &quot;TEST008&quot;;
    string public constant symbol     = &quot;测试八&quot;;
    uint32 public constant decimals   = 18;
    uint256 public totalSupply        = 999999 ether;
    uint256 public currentTotalSupply = 0;
    uint256 startBalance              = 999 ether;
    
    mapping(address =&gt; bool) touched;
    mapping(address =&gt; uint256) balances;
    mapping (address =&gt; mapping (address =&gt; uint256)) internal allowed;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));

        if( !touched[msg.sender] &amp;&amp; currentTotalSupply &lt; totalSupply ){
            balances[msg.sender] = balances[msg.sender].add( startBalance );
            touched[msg.sender] = true;
            currentTotalSupply = currentTotalSupply.add( startBalance );
        }
        
        require(_value &lt;= balances[msg.sender]);
        
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
    
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
  

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        
        require(_value &lt;= allowed[_from][msg.sender]);
        
        if( !touched[_from] &amp;&amp; currentTotalSupply &lt; totalSupply ){
            touched[_from] = true;
            balances[_from] = balances[_from].add( startBalance );
            currentTotalSupply = currentTotalSupply.add( startBalance );
        }
        
        require(_value &lt;= balances[_from]);
        
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }


    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }


    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
     }


    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }


    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue &gt; oldValue) {
          allowed[msg.sender][_spender] = 0;
        } else {
          allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
     }
    

    function getBalance(address _a) internal constant returns(uint256)
    {
        if( currentTotalSupply &lt; totalSupply ){
            if( touched[_a] )
                return balances[_a];
            else
                return balances[_a].add( startBalance );
        } else {
            return balances[_a];
        }
    }
    

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return getBalance( _owner );
    }
}