pragma solidity ^0.4.18;

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of &quot;user permissions&quot;.
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

// File: openzeppelin-solidity/contracts/ownership/HasNoEther.sol

/**
 * @title Contracts that should not own Ether
 * @author Remco Bloemen &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="f684939b9599b6c4">[email&#160;protected]</a>π.com&gt;
 * @dev This tries to block incoming ether to prevent accidental loss of Ether. Should Ether end up
 * in the contract, it will allow the owner to reclaim this ether.
 * @notice Ether can still be send to this contract by:
 * calling functions labeled `payable`
 * `selfdestruct(contract_address)`
 * mining directly to the contract address
*/
contract HasNoEther is Ownable {

  /**
  * @dev Constructor that rejects incoming Ether
  * @dev The `payable` flag is added so we can access `msg.value` without compiler warning. If we
  * leave out payable, then Solidity will allow inheriting contracts to implement a payable
  * constructor. By doing it this way we prevent a payable constructor from working. Alternatively
  * we could use assembly to access msg.value.
  */
  function HasNoEther() public payable {
    require(msg.value == 0);
  }

  /**
   * @dev Disallows direct send by settings a default function without the `payable` flag.
   */
  function() external {
  }

  /**
   * @dev Transfer all Ether held by the contract to the owner.
   */
  function reclaimEther() external onlyOwner {
    assert(owner.send(this.balance));
  }
}

// File: contracts/TweedentityRegistry.sol

contract Pausable {

  bool public paused;
}


/**
 * @title TweedentityRegistry
 * @author Francesco Sullo &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="9ef8ecfff0fdfbedfdf1deedebf2f2f1b0fdf1">[email&#160;protected]</a>&gt;
 * @dev It store the tweedentities contracts addresses to allows dapp to be updated
 */


contract TweedentityRegistry
is HasNoEther
{

  string public version = &quot;1.4.0&quot;;

  uint public totalStores;
  mapping (bytes32 =&gt; address) private stores;

  address public manager;
  address public claimer;

  event ContractRegistered(
    bytes32 indexed key,
    string spec,
    address addr
  );


  function setManager(
    address _manager
  )
  external
  onlyOwner
  {
    require(_manager != address(0));
    manager = _manager;
    ContractRegistered(keccak256(&quot;manager&quot;), &quot;&quot;, _manager);
  }


  function setClaimer(
    address _claimer
  )
  external
  onlyOwner
  {
    require(_claimer != address(0));
    claimer = _claimer;
    ContractRegistered(keccak256(&quot;claimer&quot;), &quot;&quot;, _claimer);
  }


  function setManagerAndClaimer(
    address _manager,
    address _claimer
  )
  external
  onlyOwner
  {
    require(_manager != address(0));
    require(_claimer != address(0));
    manager = _manager;
    claimer = _claimer;
    ContractRegistered(keccak256(&quot;manager&quot;), &quot;&quot;, _manager);
    ContractRegistered(keccak256(&quot;claimer&quot;), &quot;&quot;, _claimer);
  }


  function setAStore(
    string _appNickname,
    address _store
  )
  external
  onlyOwner
  {
    require(_store != address(0));
    if (getStore(_appNickname) == address(0)) {
      totalStores++;
    }
    stores[keccak256(_appNickname)] = _store;
    ContractRegistered(keccak256(&quot;store&quot;), _appNickname, _store);
  }


  /**
   * @dev Gets the store managing the specified app
   * @param _appNickname The nickname of the app
   */
  function getStore(
    string _appNickname
  )
  public
  constant returns(address)
  {
    return stores[keccak256(_appNickname)];
  }


  /**
   * @dev Returns true if the registry looks ready
   */
  function isReady()
  external
  constant returns(bool)
  {
    Pausable pausable = Pausable(manager);
    return totalStores &gt; 0 &amp;&amp; manager != address(0) &amp;&amp; claimer != address(0) &amp;&amp; pausable.paused() == false;
  }

}