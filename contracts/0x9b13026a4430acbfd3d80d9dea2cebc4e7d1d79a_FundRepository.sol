pragma solidity 0.4.24;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b &gt; 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn&#39;t hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b &lt;= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c &gt;= a);
    return c;
  }
}

/// @dev `Owned` is a base level contract that assigns an `owner` that can be
///  later changed
contract Owned {

    /// @dev `owner` is the only address that can call a function with this
    /// modifier
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    address public owner;

    /// @notice The Constructor assigns the message sender to be `owner`
    function Owned() public {owner = msg.sender;}

    /// @notice `owner` can step down and assign some other address to this role
    /// @param _newOwner The address of the new owner. 0x0 can be used to create
    ///  an unowned neutral vault, however that cannot be undone
    function changeOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }
}

contract Callable is Owned {

    //sender =&gt; _allowed
    mapping(address =&gt; bool) public callers;

    //modifiers
    modifier onlyCaller {
        require(callers[msg.sender]);
        _;
    }

    //management of the repositories
    function updateCaller(address _caller, bool allowed) public onlyOwner {
        callers[_caller] = allowed;
    }
}

contract EternalStorage is Callable {

    mapping(bytes32 =&gt; uint) uIntStorage;
    mapping(bytes32 =&gt; string) stringStorage;
    mapping(bytes32 =&gt; address) addressStorage;
    mapping(bytes32 =&gt; bytes) bytesStorage;
    mapping(bytes32 =&gt; bool) boolStorage;
    mapping(bytes32 =&gt; int) intStorage;

    // *** Getter Methods ***
    function getUint(bytes32 _key) external view returns (uint) {
        return uIntStorage[_key];
    }

    function getString(bytes32 _key) external view returns (string) {
        return stringStorage[_key];
    }

    function getAddress(bytes32 _key) external view returns (address) {
        return addressStorage[_key];
    }

    function getBytes(bytes32 _key) external view returns (bytes) {
        return bytesStorage[_key];
    }

    function getBool(bytes32 _key) external view returns (bool) {
        return boolStorage[_key];
    }

    function getInt(bytes32 _key) external view returns (int) {
        return intStorage[_key];
    }

    // *** Setter Methods ***
    function setUint(bytes32 _key, uint _value) onlyCaller external {
        uIntStorage[_key] = _value;
    }

    function setString(bytes32 _key, string _value) onlyCaller external {
        stringStorage[_key] = _value;
    }

    function setAddress(bytes32 _key, address _value) onlyCaller external {
        addressStorage[_key] = _value;
    }

    function setBytes(bytes32 _key, bytes _value) onlyCaller external {
        bytesStorage[_key] = _value;
    }

    function setBool(bytes32 _key, bool _value) onlyCaller external {
        boolStorage[_key] = _value;
    }

    function setInt(bytes32 _key, int _value) onlyCaller external {
        intStorage[_key] = _value;
    }

    // *** Delete Methods ***
    function deleteUint(bytes32 _key) onlyCaller external {
        delete uIntStorage[_key];
    }

    function deleteString(bytes32 _key) onlyCaller external {
        delete stringStorage[_key];
    }

    function deleteAddress(bytes32 _key) onlyCaller external {
        delete addressStorage[_key];
    }

    function deleteBytes(bytes32 _key) onlyCaller external {
        delete bytesStorage[_key];
    }

    function deleteBool(bytes32 _key) onlyCaller external {
        delete boolStorage[_key];
    }

    function deleteInt(bytes32 _key) onlyCaller external {
        delete intStorage[_key];
    }
}

/*
 * Database Contract
 * Davy Van Roy
 * Quinten De Swaef
 */
contract FundRepository is Callable {

    using SafeMath for uint256;

    EternalStorage public db;

    //platform -&gt; platformId =&gt; _funding
    mapping(bytes32 =&gt; mapping(string =&gt; Funding)) funds;

    struct Funding {
        address[] funders; //funders that funded tokens
        address[] tokens; //tokens that were funded
        mapping(address =&gt; TokenFunding) tokenFunding;
    }

    struct TokenFunding {
        mapping(address =&gt; uint256) balance;
        uint256 totalTokenBalance;
    }

    constructor(address _eternalStorage) public {
        db = EternalStorage(_eternalStorage);
    }

    function updateFunders(address _from, bytes32 _platform, string _platformId) public onlyCaller {
        bool existing = db.getBool(keccak256(abi.encodePacked(&quot;funds.userHasFunded&quot;, _platform, _platformId, _from)));
        if (!existing) {
            uint funderCount = getFunderCount(_platform, _platformId);
            db.setAddress(keccak256(abi.encodePacked(&quot;funds.funders.address&quot;, _platform, _platformId, funderCount)), _from);
            db.setUint(keccak256(abi.encodePacked(&quot;funds.funderCount&quot;, _platform, _platformId)), funderCount.add(1));
        }
    }

    function updateBalances(address _from, bytes32 _platform, string _platformId, address _token, uint256 _value) public onlyCaller {
        if (balance(_platform, _platformId, _token) &lt;= 0) {
            //add to the list of tokens for this platformId
            uint tokenCount = getFundedTokenCount(_platform, _platformId);
            db.setAddress(keccak256(abi.encodePacked(&quot;funds.token.address&quot;, _platform, _platformId, tokenCount)), _token);
            db.setUint(keccak256(abi.encodePacked(&quot;funds.tokenCount&quot;, _platform, _platformId)), tokenCount.add(1));
        }

        //add to the balance of this platformId for this token
        db.setUint(keccak256(abi.encodePacked(&quot;funds.tokenBalance&quot;, _platform, _platformId, _token)), balance(_platform, _platformId, _token).add(_value));

        //add to the balance the user has funded for the request
        db.setUint(keccak256(abi.encodePacked(&quot;funds.amountFundedByUser&quot;, _platform, _platformId, _from, _token)), amountFunded(_platform, _platformId, _from, _token).add(_value));

        //add the fact that the user has now funded this platformId
        db.setBool(keccak256(abi.encodePacked(&quot;funds.userHasFunded&quot;, _platform, _platformId, _from)), true);
    }

    function claimToken(bytes32 platform, string platformId, address _token) public onlyCaller returns (uint256) {
        require(!issueResolved(platform, platformId), &quot;Can&#39;t claim token, issue is already resolved.&quot;);
        uint256 totalTokenBalance = balance(platform, platformId, _token);
        db.deleteUint(keccak256(abi.encodePacked(&quot;funds.tokenBalance&quot;, platform, platformId, _token)));
        return totalTokenBalance;
    }

    function finishResolveFund(bytes32 platform, string platformId) public onlyCaller returns (bool) {
        db.setBool(keccak256(abi.encodePacked(&quot;funds.issueResolved&quot;, platform, platformId)), true);
        db.deleteUint(keccak256(abi.encodePacked(&quot;funds.funderCount&quot;, platform, platformId)));
        return true;
    }

    //constants
    function getFundInfo(bytes32 _platform, string _platformId, address _funder, address _token) public view returns (uint256, uint256, uint256) {
        return (
        getFunderCount(_platform, _platformId),
        balance(_platform, _platformId, _token),
        amountFunded(_platform, _platformId, _funder, _token)
        );
    }

    function issueResolved(bytes32 _platform, string _platformId) public view returns (bool) {
        return db.getBool(keccak256(abi.encodePacked(&quot;funds.issueResolved&quot;, _platform, _platformId)));
    }

    function getFundedTokenCount(bytes32 _platform, string _platformId) public view returns (uint256) {
        return db.getUint(keccak256(abi.encodePacked(&quot;funds.tokenCount&quot;, _platform, _platformId)));
    }

    function getFundedTokensByIndex(bytes32 _platform, string _platformId, uint _index) public view returns (address) {
        return db.getAddress(keccak256(abi.encodePacked(&quot;funds.token.address&quot;, _platform, _platformId, _index)));
    }

    function getFunderCount(bytes32 _platform, string _platformId) public view returns (uint) {
        return db.getUint(keccak256(abi.encodePacked(&quot;funds.funderCount&quot;, _platform, _platformId)));
    }

    function getFunderByIndex(bytes32 _platform, string _platformId, uint index) external view returns (address) {
        return db.getAddress(keccak256(abi.encodePacked(&quot;funds.funders.address&quot;, _platform, _platformId, index)));
    }

    function amountFunded(bytes32 _platform, string _platformId, address _funder, address _token) public view returns (uint256) {
        return db.getUint(keccak256(abi.encodePacked(&quot;funds.amountFundedByUser&quot;, _platform, _platformId, _funder, _token)));
    }

    function balance(bytes32 _platform, string _platformId, address _token) view public returns (uint256) {
        return db.getUint(keccak256(abi.encodePacked(&quot;funds.tokenBalance&quot;, _platform, _platformId, _token)));
    }
}