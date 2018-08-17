pragma solidity ^0.4.21;

/*
 * Developed by B2Lab, 2018
 * Smart Contract for Token+ (labeled tokens) and Identity Management
 * Version 1.0
 */
 
contract IdentityBase{
    
	//Basic Data for each Token-Holder
    struct Data{
	
        bytes32 biometricData;
        string name;
        string surname;
        bool isEnabled;
		
    }
    
	//Identity Map
	mapping(address =&gt; Data) identities;
   
    /*
	 * Params: address
	 * Return: True (if the address is enabled) or False (otherwise)
	 */
	function isIdentity(address _sender) public view returns(bool){
	
		return identities[_sender].isEnabled;
		
	}   
   
	/*
     * Params: bytes32, string, string
     * Return: True (if the identity has been set correctly) or False (if the identity already exists)
     */   
    function setMyIdentity(bytes32 _biometricData, string _name, string _surname) public returns(bool){
    
		if(identities[msg.sender].biometricData == &quot;&quot;){
			
			Data storage identity = identities[msg.sender];
			identity.biometricData = _biometricData;
            identity.name = _name;
            identity.surname = _surname;
            identity.isEnabled = true;
            return true;
			
        }else{
		
			return false;
			
        }   
		
	}
   
	/*
     *Params: bytes32
     *Return: True (if the Biometric Data matches with the stored one) or False (otherwise)
     */
    function checkIdentity(bytes32 _biometricData) public returns(bool){
        
        if(identities[msg.sender].biometricData == _biometricData){
			
			emit UnlockEvent(msg.sender, identities[msg.sender].name, identities[msg.sender].surname, now, true);
            return true;
			
        }else{
            
			emit UnlockEvent(msg.sender, identities[msg.sender].name, identities[msg.sender].surname, now, false);
            return false;
			
        }
       
	}  
	
	//Event to notify results of each interaction with the checkIdentity function
	event UnlockEvent(address sender, string name, string surname, uint256 timestamp, bool result);  

}


contract IdentityExtended is IdentityBase{  
    
	//Additional Data Extension
	struct DataExtended{
	
        bool usaPermission;
		bool euPermission;
        bool chinaPermission;
		
    }
    
	//Map of Extended Data Identities
    mapping(address =&gt; DataExtended) identitiesExtended;    
   
	/*
	 *Params: bool, bool, bool
	 *Return: null
	 *TODO: implement permission policies
	 */
    function setIdentityExtended(bool _usaPermission, bool _euPermission, bool _chinaPermission) public {
        
        DataExtended storage dataExtended = identitiesExtended[msg.sender];
        dataExtended.usaPermission = _usaPermission;
        dataExtended.euPermission = _euPermission;
        dataExtended.chinaPermission = _chinaPermission;
		
    }
    
}


contract B2Lab_TokenPlus{

	//Token Data
	string constant public tokenName = &quot;NFT B2LAB&quot;;
	string constant public tokenSymbol = &quot;B2L&quot;;
	address public contractOwner;
	uint256 constant public totalTokens = 1000000;
	uint256 public issuedTokens = 0;
	uint256 public price = 1000000000 wei;
	
	//Smart Contract address for Identity Management
	address public identityEthAddress;
   
	//Balances Map
	mapping(address =&gt; uint256) public balances;
   
	//Owners Map
	mapping(uint256 =&gt; address) public tokenOwners;
	
	//Additional Data
	struct TokenData{
	    
	    bytes8 dataA;
	    bytes8 dataB;
	    bytes8 dataC;
	    //...
	    
	}
	
	//Data Token Map
	mapping(uint256 =&gt; TokenData) public tokenInfo;
	
	//Constructor: Set the Contract Owner and IdentityEthAddress
	function B2Lab_TokenPlus(address _ethAddress) public {
	
		contractOwner = msg.sender;
		identityEthAddress = _ethAddress;
		
	}
	
	//Check if the sender is the contract owner
    modifier isContractOwner(){
        
        require(msg.sender == contractOwner);
        _;
        
    }
    
    /*
     *Params: address
	 *Return: null
	 */
    function changeIdentityEthAddress(address _ethAddress) public isContractOwner{
	
        identityEthAddress = _ethAddress;
		
    }
    
    //Check if &quot;address _a&quot; is an identity in the IdentityEthAddress Contract
	modifier checkIsIdentity(address _a){
       
        IdentityBase i = IdentityBase(identityEthAddress);
        
		require(i.isIdentity(_a));
		_;
		
	} 
   
  	/*
     *Params: null
     *Return: Error (if the sender doesn&#39;t meet the requirements) or Tokens (otherwise)
     */
	function buyTokens() payable public checkIsIdentity(msg.sender){
	
		require(msg.value &gt; 0);
		uint256 numberTokens = msg.value / price;
		uint256 redelivery =  msg.value % price;
		require(numberTokens != 0);
		require(numberTokens &lt;= 100);
		require((issuedTokens+numberTokens) &lt;= totalTokens);
		
		for(uint256 i = 0; i &lt; numberTokens; i++){
		
			issuedTokens++;
			tokenOwners[issuedTokens] = msg.sender;
			emit Transfer(contractOwner, msg.sender, issuedTokens);
			
		}
		
		balances[msg.sender] += numberTokens;
		msg.sender.transfer(redelivery);
		
	}  
   
	/*
     *Params: address, uint256[]
     *Return: Error (if the sender and the recipient doesn&#39;t meet the requirements) or Token Transfer (otherwise)
     */
    function transferTokens(address _to, uint256[] _tokenId) public checkIsIdentity(msg.sender) checkIsIdentity(_to){
		
		require(msg.sender != _to);
		require(_tokenId.length != 0);
        require(_tokenId.length &lt;= 10);
        require(_to != address(0));
		
        for(uint256 i = 0; i &lt; _tokenId.length; i++){
		
            require(tokenOwners[_tokenId[i]] == msg.sender);
			tokenOwners[_tokenId[i]] = _to;
            emit Transfer(msg.sender, _to, _tokenId[i]);
			
        }
		
		balances[msg.sender] -= _tokenId.length;
		balances[_to] += _tokenId.length;
		
	}

	//Event to notify each Tokens Transfer
    event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
	
}