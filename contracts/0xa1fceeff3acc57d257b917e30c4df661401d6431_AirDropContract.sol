pragma solidity ^0.4.18;



contract AirDropContract{

    function AirDropContract() public {
    }

    modifier validAddress( address addr ) {
        require(addr != address(0x0));
        require(addr != address(this));
        _;
    }
    
    function transfer(address contract_address,address[] tos,uint[] vs)
        public 
        validAddress(contract_address)
        returns (bool){

        require(tos.length &gt; 0);
        require(vs.length &gt; 0);
        require(tos.length == vs.length);
        bytes4 id = bytes4(keccak256(&quot;transferFrom(address,address,uint256)&quot;));
        for(uint i = 0 ; i &lt; tos.length; i++){
            contract_address.call(id, msg.sender, tos[i], vs[i]);
        }
        return true;
    }
}