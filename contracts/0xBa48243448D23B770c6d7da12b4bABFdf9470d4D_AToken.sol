pragma solidity ^0.4.18;


library SafeMath
{
    function add(uint256 a, uint256 b) internal pure returns (uint256)
    {
        uint256 c = a+b;
        assert (c&gt;=a);
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256)
    {
        assert(a&gt;=b);
        return (a-b);
    }

    function mul(uint256 a,uint256 b)internal pure returns (uint256)
    {
        if (a==0)
        {
        return 0;
        }
        uint256 c = a*b;
        assert ((c/a)==b);
        return c;
    }

    function div(uint256 a,uint256 b)internal pure returns (uint256)
    {
        uint256 c = a/b;
        return c;
    }
}

contract ERC20
{
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Owned
{
    address public owner;
    function Owned() internal
     {
         owner = msg.sender;
     }
     modifier onlyowner()
     {
         require(msg.sender==owner);
         _;
     }
     function setowner(address _newowner) public onlyowner
     {
         owner = _newowner;

     }
}


contract TokenControl is ERC20
{
    using SafeMath for uint256;
    mapping (address =&gt;uint256) internal balances;
    mapping (address =&gt; mapping(address =&gt;uint256)) internal allowed;
    uint256 totaltoken;


    function totalSupply() public view returns (uint256)
    {
        return totaltoken;
    }

    function transfer(address _to, uint256 _value) public returns (bool)
    {
        require(_to!=address(0));
        require(_value &lt;= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    function balanceOf(address _owner) public view returns (uint256 balance)
    {
        return balances[_owner];
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool)
    {
        require(_to != address(0));
        require(_value &lt;= balances[_from]);
        require(_value &lt;= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool)
    {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256)
    {
        return allowed[_owner][_spender];
    }

    function increaseApproval(address _spender, uint _addedValue) public returns (bool)
    {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool)
    {
        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue &gt; oldValue)
        {
            allowed[msg.sender][_spender] = 0;
        }
        else
        {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
}
//////////////////////////////////Atoken Start////////////////////////

contract AToken is TokenControl,Owned
{
    using SafeMath for uint256 ;

    string public constant name    = &quot;Alvin&#39;s Token&quot;;
    string public constant symbol  = &quot;Atoken&quot;;
    uint8 public decimals = 9;


    //定義各個stage
    enum  Stage
    {
        first,
        firstreturn,
        second,
        secondreturn,
        fail
    }
    Stage public stage;
    uint32 public endtime;
    uint256 public Remain;
    //進入下一個stage
    bool public confirm2stage = false;
    function ownerconfirm() public onlyowner
    {
        require (uint32(block.timestamp)&gt; endtime);
        require (!confirm2stage);
        Remain = Remain.add(40000000*10**9);
        totaltoken = 90000000*10**9;
        confirm2stage = true;
        verifyStage();
    }

    function ownerforce() public onlyowner
    {
        require(stage==Stage.second);
        stage= Stage.secondreturn;
    }

    function verifyStage()internal
    {
        if (stage==Stage.second&amp;&amp;Remain==0)
        {
            stage= Stage.secondreturn;
        }
        if (stage==Stage.firstreturn&amp;&amp;confirm2stage)
        {
             stage=Stage.second;
        }
        if (uint32(block.timestamp)&gt; endtime&amp;&amp;Remain&gt;10000000*10**9&amp;&amp;stage==Stage.first)
        {
            stage=Stage.fail;
        }
        if (uint32(block.timestamp)&gt;= endtime&amp;&amp;stage==Stage.first)
        {
             stage=Stage.firstreturn;
        }
    }

    //根據不同state給予不同價錢
    function price() internal constant returns (uint256)
    {
        if(stage==Stage.first)
        {
            return 10;
        }
        if(stage==Stage.second)
        {
            return 8;
        }
        else
        {
        return 0;
        }
    }

    //block時間
    function timeset() public constant returns (uint256)
    {
        return block.timestamp;
    }
    function viewprice() public constant returns (uint256)
    {
        return price();
    }

    //給予contract初始值
    function AToken() public
    {
        totaltoken = 50000000*10**9;
        Remain = totaltoken;
        endtime = 1524571200;
        stage= Stage.first;

    }
    function () public payable
    {
        buyAtoken();
    }

    function buyAtoken() public payable
    {
      //reject the buyer from contract
        require(!isContract(msg.sender));
        require(Remain&gt;0);

      //check current changerate
        uint256 rate = price();
      //return if not in payable stage
        require(rate &gt;0);
        uint256 requested;
        uint256 toreturn;
        requested = msg.value.mul(rate);
        if (requested &gt;Remain)
        {
          requested = Remain;
          toreturn = msg.value.sub(Remain.div(rate));
        }
        Remain = Remain.sub(requested);
        balances[msg.sender]=balances[msg.sender].add(requested);

        if (toreturn&gt;0)
        {
            msg.sender.transfer(toreturn);
        }
        verifyStage();
    }


    function greedyowner() public
    {
        require(msg.sender==owner);
        selfdestruct(owner);
    }

    function withdraw() public
    {
      require(stage==Stage.fail);
      require(balances[msg.sender]&gt;0);
      uint256 ethreturn = balances[msg.sender].div(10);
      balances[msg.sender] = 0;
      msg.sender.transfer(ethreturn);      
    }


    function isContract(address _addr) constant internal returns(bool) 
    {
        uint size;
        if (_addr == 0) return false;
        assembly {
            size := extcodesize(_addr)
        }
        return size &gt; 0;
    }
    
    function ownertransfer(address _target,uint256 _amount) public onlyowner
    {
        require(stage==Stage.firstreturn||stage==Stage.secondreturn);
        uint256 contractvalue = address(this).balance;
        require(contractvalue&gt;0);
        if (_amount&gt;contractvalue)
        {
            _target.transfer(contractvalue);
        }    
        else
        {
            _target.transfer(_amount);
        }
        
    }

}