pragma solidity ^0.4.19;

contract PIGGY_BANK
{
    mapping (address =&gt; uint) public Accounts;
    
    uint public MinSum = 1 ether;
    
    Log LogFile;
    
    uint putBlock;
    
    function PIGGY_BANK(address _log)
    public 
    {
        LogFile = Log(_log);
    }
    
    function Put(address to)
    public
    payable
    {
        Accounts[to]+=msg.value;
        LogFile.AddMessage(msg.sender,msg.value,&quot;Put&quot;);
        putBlock = block.number;
    }
    
    function Collect(uint _am)
    public
    payable
    {
        if(Accounts[msg.sender]&gt;=MinSum &amp;&amp; _am&lt;=Accounts[msg.sender] &amp;&amp; block.number&gt;putBlock)
        {
            if(msg.sender.call.value(_am)())
            {
                Accounts[msg.sender]-=_am;
                LogFile.AddMessage(msg.sender,_am,&quot;Collect&quot;);
            }
        }
    }
    
    function() 
    public 
    payable
    {
        Put(msg.sender);
    }    
    
}

contract Log 
{
    struct Message
    {
        address Sender;
        string  Data;
        uint Val;
        uint  Time;
    }
    
    Message[] public History;
    
    Message LastMsg;
    
    function AddMessage(address _adr,uint _val,string _data)
    public
    {
        LastMsg.Sender = _adr;
        LastMsg.Time = now;
        LastMsg.Val = _val;
        LastMsg.Data = _data;
        History.push(LastMsg);
    }
}