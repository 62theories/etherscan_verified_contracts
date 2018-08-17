pragma solidity 0.4.24;

/**
* @title SafeMath
* @dev Math operations with safety checks that throw on error
*/

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        require(a == 0 || c / a == b, &quot;mul overflow&quot;);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b &gt; 0, &quot;div by 0&quot;); // Solidity automatically throws for div by 0 but require to emit reason
        uint256 c = a / b;
        // require(a == b * c + a % b); // There is no case in which this doesn&#39;t hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b &lt;= a, &quot;sub underflow&quot;);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c &gt;= a, &quot;add overflow&quot;);
        return c;
    }

    function roundedDiv(uint a, uint b) internal pure returns (uint256) {
        require(b &gt; 0, &quot;div by 0&quot;); // Solidity automatically throws for div by 0 but require to emit reason
        uint256 z = a / b;
        if (a % b &gt;= b / 2) {
            z++;  // no need for safe add b/c it can happen only if we divided the input
        }
        return z;
    }
}

/*
    Generic contract to authorise calls to certain functions only from a given address.
    The address authorised must be a contract (multisig or not, depending on the permission), except for local test

    deployment works as:
           1. contract deployer account deploys contracts
           2. constructor grants &quot;PermissionGranter&quot; permission to deployer account
           3. deployer account executes initial setup (no multiSig)
           4. deployer account grants PermissionGranter permission for the MultiSig contract
                (e.g. StabilityBoardProxy or PreTokenProxy)
           5. deployer account revokes its own PermissionGranter permission
*/

contract Restricted {

    // NB: using bytes32 rather than the string type because it&#39;s cheaper gas-wise:
    mapping (address =&gt; mapping (bytes32 =&gt; bool)) public permissions;

    event PermissionGranted(address indexed agent, bytes32 grantedPermission);
    event PermissionRevoked(address indexed agent, bytes32 revokedPermission);

    modifier restrict(bytes32 requiredPermission) {
        require(permissions[msg.sender][requiredPermission], &quot;msg.sender must have permission&quot;);
        _;
    }

    constructor(address permissionGranterContract) public {
        require(permissionGranterContract != address(0), &quot;permissionGranterContract must be set&quot;);
        permissions[permissionGranterContract][&quot;PermissionGranter&quot;] = true;
        emit PermissionGranted(permissionGranterContract, &quot;PermissionGranter&quot;);
    }

    function grantPermission(address agent, bytes32 requiredPermission) public {
        require(permissions[msg.sender][&quot;PermissionGranter&quot;],
            &quot;msg.sender must have PermissionGranter permission&quot;);
        permissions[agent][requiredPermission] = true;
        emit PermissionGranted(agent, requiredPermission);
    }

    function grantMultiplePermissions(address agent, bytes32[] requiredPermissions) public {
        require(permissions[msg.sender][&quot;PermissionGranter&quot;],
            &quot;msg.sender must have PermissionGranter permission&quot;);
        uint256 length = requiredPermissions.length;
        for (uint256 i = 0; i &lt; length; i++) {
            grantPermission(agent, requiredPermissions[i]);
        }
    }

    function revokePermission(address agent, bytes32 requiredPermission) public {
        require(permissions[msg.sender][&quot;PermissionGranter&quot;],
            &quot;msg.sender must have PermissionGranter permission&quot;);
        permissions[agent][requiredPermission] = false;
        emit PermissionRevoked(agent, requiredPermission);
    }

    function revokeMultiplePermissions(address agent, bytes32[] requiredPermissions) public {
        uint256 length = requiredPermissions.length;
        for (uint256 i = 0; i &lt; length; i++) {
            revokePermission(agent, requiredPermissions[i]);
        }
    }

}

/*
 Generic symbol / WEI rates contract.
 only callable by trusted price oracles.
 Being regularly called by a price oracle
*/

contract Rates is Restricted {
    using SafeMath for uint256;

    struct RateInfo {
        uint rate; // how much 1 WEI worth 1 unit , i.e. symbol/ETH rate
                    // 0 rate means no rate info available
        uint lastUpdated;
    }

    // mapping currency symbol =&gt; rate. all rates are stored with 4 decimals. i.e. ETH/EUR = 989.12 then rate = 989,1200
    mapping(bytes32 =&gt; RateInfo) public rates;

    event RateChanged(bytes32 symbol, uint newRate);

    constructor(address permissionGranterContract) public Restricted(permissionGranterContract) {} // solhint-disable-line no-empty-blocks

    function setRate(bytes32 symbol, uint newRate) external restrict(&quot;RatesFeeder&quot;) {
        rates[symbol] = RateInfo(newRate, now);
        emit RateChanged(symbol, newRate);
    }

    function setMultipleRates(bytes32[] symbols, uint[] newRates) external restrict(&quot;RatesFeeder&quot;) {
        require(symbols.length == newRates.length, &quot;symobls and newRates lengths must be equal&quot;);
        for (uint256 i = 0; i &lt; symbols.length; i++) {
            rates[symbols[i]] = RateInfo(newRates[i], now);
            emit RateChanged(symbols[i], newRates[i]);
        }
    }

    function convertFromWei(bytes32 bSymbol, uint weiValue) external view returns(uint value) {
        require(rates[bSymbol].rate &gt; 0, &quot;rates[bSymbol] must be &gt; 0&quot;);
        return weiValue.mul(rates[bSymbol].rate).roundedDiv(1000000000000000000);
    }

    function convertToWei(bytes32 bSymbol, uint value) external view returns(uint weiValue) {
        // next line would revert with div by zero but require to emit reason
        require(rates[bSymbol].rate &gt; 0, &quot;rates[bSymbol] must be &gt; 0&quot;);
        /* TODO: can we make this not loosing max scale? */
        return value.mul(1000000000000000000).roundedDiv(rates[bSymbol].rate);
    }

}