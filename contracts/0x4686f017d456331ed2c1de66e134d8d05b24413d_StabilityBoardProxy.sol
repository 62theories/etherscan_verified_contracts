/**
* @title SafeMath
* @dev Math operations with safety checks that throw on error
*/
pragma solidity 0.4.24;


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

contract MultiSig {
    using SafeMath for uint256;

    uint public constant CHUNK_SIZE = 100;

    mapping(address =&gt; bool) public isSigner;
    address[] public allSigners; // all signers, even the disabled ones
                                // NB: it can contain duplicates when a signer is added, removed then readded again
                                //   the purpose of this array is to being able to iterate on signers in isSigner
    uint public activeSignersCount;

    enum ScriptState {New, Approved, Done, Cancelled, Failed}

    struct Script {
        ScriptState state;
        uint signCount;
        mapping(address =&gt; bool) signedBy;
        address[] allSigners;
    }

    mapping(address =&gt; Script) public scripts;
    address[] public scriptAddresses;

    event SignerAdded(address signer);
    event SignerRemoved(address signer);

    event ScriptSigned(address scriptAddress, address signer);
    event ScriptApproved(address scriptAddress);
    event ScriptCancelled(address scriptAddress);

    event ScriptExecuted(address scriptAddress, bool result);

    constructor() public {
        // deployer address is the first signer. Deployer can configure new contracts by itself being the only &quot;signer&quot;
        // The first script which sets the new contracts live should add signers and revoke deployer&#39;s signature right
        isSigner[msg.sender] = true;
        allSigners.push(msg.sender);
        activeSignersCount = 1;
        emit SignerAdded(msg.sender);
    }

    function sign(address scriptAddress) public {
        require(isSigner[msg.sender], &quot;sender must be signer&quot;);
        Script storage script = scripts[scriptAddress];
        require(script.state == ScriptState.Approved || script.state == ScriptState.New,
                &quot;script state must be New or Approved&quot;);
        require(!script.signedBy[msg.sender], &quot;script must not be signed by signer yet&quot;);

        if(script.allSigners.length == 0) {
            // first sign of a new script
            scriptAddresses.push(scriptAddress);
        }

        script.allSigners.push(msg.sender);
        script.signedBy[msg.sender] =  true;
        script.signCount = script.signCount.add(1);

        emit ScriptSigned(scriptAddress, msg.sender);

        if(checkQuorum(script.signCount)){
            script.state = ScriptState.Approved;
            emit ScriptApproved(scriptAddress);
        }
    }

    function execute(address scriptAddress) public returns (bool result) {
        // only allow execute to signers to avoid someone set an approved script failed by calling it with low gaslimit
        require(isSigner[msg.sender], &quot;sender must be signer&quot;);
        Script storage script = scripts[scriptAddress];
        require(script.state == ScriptState.Approved, &quot;script state must be Approved&quot;);

        /* init to failed because if delegatecall rans out of gas we won&#39;t have enough left to set it.
           NB: delegatecall leaves 63/64 part of gasLimit for the caller.
                Therefore the execute might revert with out of gas, leaving script in Approved state
                when execute() is called with small gas limits.
        */
        script.state = ScriptState.Failed;

        // passing scriptAddress to allow called script access its own public fx-s if needed
        if(scriptAddress.delegatecall(bytes4(keccak256(&quot;execute(address)&quot;)), scriptAddress)) {
            script.state = ScriptState.Done;
            result = true;
        } else {
            result = false;
        }
        emit ScriptExecuted(scriptAddress, result);
    }

    function cancelScript(address scriptAddress) public {
        require(msg.sender == address(this), &quot;only callable via MultiSig&quot;);
        Script storage script = scripts[scriptAddress];
        require(script.state == ScriptState.Approved || script.state == ScriptState.New,
                &quot;script state must be New or Approved&quot;);

        script.state= ScriptState.Cancelled;

        emit ScriptCancelled(scriptAddress);
    }

    /* requires quorum so it&#39;s callable only via a script executed by this contract */
    function addSigners(address[] signers) public {
        require(msg.sender == address(this), &quot;only callable via MultiSig&quot;);
        for (uint i= 0; i &lt; signers.length; i++) {
            if (!isSigner[signers[i]]) {
                require(signers[i] != address(0), &quot;new signer must not be 0x0&quot;);
                activeSignersCount++;
                allSigners.push(signers[i]);
                isSigner[signers[i]] = true;
                emit SignerAdded(signers[i]);
            }
        }
    }

    /* requires quorum so it&#39;s callable only via a script executed by this contract */
    function removeSigners(address[] signers) public {
        require(msg.sender == address(this), &quot;only callable via MultiSig&quot;);
        for (uint i= 0; i &lt; signers.length; i++) {
            if (isSigner[signers[i]]) {
                require(activeSignersCount &gt; 1, &quot;must not remove last signer&quot;);
                activeSignersCount--;
                isSigner[signers[i]] = false;
                emit SignerRemoved(signers[i]);
            }
        }
    }

    /* implement it in derived contract */
    function checkQuorum(uint signersCount) internal view returns(bool isQuorum);

    function getAllSignersCount() view external returns (uint allSignersCount) {
        return allSigners.length;
    }

    // UI helper fx - Returns signers from offset as [signer id (index in allSigners), address as uint, isActive 0 or 1]
    function getAllSigners(uint offset) external view returns(uint[3][CHUNK_SIZE] signersResult) {
        for (uint8 i = 0; i &lt; CHUNK_SIZE &amp;&amp; i + offset &lt; allSigners.length; i++) {
            address signerAddress = allSigners[i + offset];
            signersResult[i] = [ i + offset, uint(signerAddress), isSigner[signerAddress] ? 1 : 0 ];
        }
    }

    function getScriptsCount() view external returns (uint scriptsCount) {
        return scriptAddresses.length;
    }

    // UI helper fx - Returns scripts from offset as
    //  [scriptId (index in scriptAddresses[]), address as uint, state, signCount]
    function getAllScripts(uint offset) external view returns(uint[4][CHUNK_SIZE] scriptsResult) {
        for (uint8 i = 0; i &lt; CHUNK_SIZE &amp;&amp; i + offset &lt; scriptAddresses.length; i++) {
            address scriptAddress = scriptAddresses[i + offset];
            scriptsResult[i] = [ i + offset, uint(scriptAddress), uint(scripts[scriptAddress].state),
                            scripts[scriptAddress].signCount ];
        }
    }

}

contract StabilityBoardProxy is MultiSig {

    function checkQuorum(uint signersCount) internal view returns(bool isQuorum) {
        isQuorum = signersCount &gt; activeSignersCount / 2 ;
    }
}