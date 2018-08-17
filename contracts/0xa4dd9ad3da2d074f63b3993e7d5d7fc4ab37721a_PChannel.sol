pragma solidity ^0.4.19;

contract Ownable {

    /**
     * @dev set `owner` of the contract to the sender
     */
    address public owner = msg.sender;

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
        owner = newOwner;
    }

}

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b &lt;= a);
        return a - b;
    }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

    mapping(address =&gt; uint256) balances;

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value &lt;= balances[msg.sender]);

        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

    mapping (address =&gt; mapping (address =&gt; uint256)) internal allowed;


    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value &lt;= balances[_from]);
        require(_value &lt;= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] += _value;
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     *
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender&#39;s allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

}

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */
contract MintableToken is StandardToken, Ownable {
    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed burner, uint value);
    event MintFinished();

    bool public mintingFinished = false;


    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    /**
     * @dev Function to mint tokens
     * @param _to The address that will receive the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
        totalSupply += _amount;
        balances[_to] += _amount;
        Mint(_to, _amount);
        Transfer(address(0), _to, _amount);
        return true;
    }

    /**
     * @dev Function to burn tokens
     * @param _addr The address that will have _amount of tokens burned.
     * @param _amount The amount of tokens to burn.
     */
    function burn(address _addr, uint _amount) onlyOwner public {
        require(_amount &gt; 0 &amp;&amp; balances[_addr] &gt;= _amount &amp;&amp; totalSupply &gt;= _amount);
        balances[_addr] -= _amount;
        totalSupply -= _amount;
        Burn(_addr, _amount);
        Transfer(_addr, address(0), _amount);
    }

    /**
     * @dev Function to stop minting new tokens.
     * @return True if the operation was successful.
     */
    function finishMinting() onlyOwner canMint public returns (bool) {
        mintingFinished = true;
        MintFinished();
        return true;
    }
}

contract WealthBuilderToken is MintableToken {

    string public name = &quot;Wealth Builder Token&quot;;

    string public symbol = &quot;WBT&quot;;

    uint32 public decimals = 18;

    /**
     *  how many {tokens*10^(-18)} get per 1wei
     */
    uint public rate = 10**7;
    /**
     *  multiplicator for rate
     */
    uint public mrate = 10**7;

    function setRate(uint _rate) onlyOwner public {
        rate = _rate;
    }

}

contract Data is Ownable {

    // node =&gt; its parent
    mapping (address =&gt; address) private parent;

    // node =&gt; its status
    mapping (address =&gt; uint8) public statuses;

    // node =&gt; sum of all his child deposits in USD cents
    mapping (address =&gt; uint) public referralDeposits;

    // client =&gt; balance in wei*10^(-6) available for withdrawal
    mapping(address =&gt; uint256) private balances;

    // investor =&gt; balance in wei*10^(-6) available for withdrawal
    mapping(address =&gt; uint256) private investorBalances;

    function parentOf(address _addr) public constant returns (address) {
        return parent[_addr];
    }

    function balanceOf(address _addr) public constant returns (uint256) {
        return balances[_addr] / 1000000;
    }

    function investorBalanceOf(address _addr) public constant returns (uint256) {
        return investorBalances[_addr] / 1000000;
    }

    /**
     * @dev The Data constructor to set up the first depositer
     */
    function Data() public {
        // DirectorOfRegion - 7
        statuses[msg.sender] = 7;
    }

    function addBalance(address _addr, uint256 amount) onlyOwner public {
        balances[_addr] += amount;
    }

    function subtrBalance(address _addr, uint256 amount) onlyOwner public {
        require(balances[_addr] &gt;= amount);
        balances[_addr] -= amount;
    }

    function addInvestorBalance(address _addr, uint256 amount) onlyOwner public {
        investorBalances[_addr] += amount;
    }

    function subtrInvestorBalance(address _addr, uint256 amount) onlyOwner public {
        require(investorBalances[_addr] &gt;= amount);
        investorBalances[_addr] -= amount;
    }

    function addReferralDeposit(address _addr, uint256 amount) onlyOwner public {
        referralDeposits[_addr] += amount;
    }

    function setStatus(address _addr, uint8 _status) onlyOwner public {
        statuses[_addr] = _status;
    }

    function setParent(address _addr, address _parent) onlyOwner public {
        parent[_addr] = _parent;
    }

}

contract Declaration {

    // threshold in USD =&gt; status
    mapping (uint =&gt; uint8) statusThreshold;

    // status =&gt; (depositsNumber =&gt; percentage)
    mapping (uint8 =&gt; mapping (uint8 =&gt; uint)) feeDistribution;

    // status thresholds in USD
    uint[8] thresholds = [
    0, 5000, 35000, 150000, 500000, 2500000, 5000000, 10000000
    ];

    uint[5] referralFees = [50, 30, 20, 10, 5];
    uint[5] serviceFees = [25, 20, 15, 10, 5];


    /**
     * @dev The Declaration constructor to define some constants
     */
    function Declaration() public {
        setFeeDistributionsAndStatusThresholds();
    }


    /**
     * @dev Set up fee distribution &amp; status thresholds
     */
    function setFeeDistributionsAndStatusThresholds() private {
        // Agent - 0
        setFeeDistributionAndStatusThreshold(0, [12, 8, 5, 2, 1], thresholds[0]);
        // SilverAgent - 1
        setFeeDistributionAndStatusThreshold(1, [16, 10, 6, 3, 2], thresholds[1]);
        // Manager - 2
        setFeeDistributionAndStatusThreshold(2, [20, 12, 8, 4, 2], thresholds[2]);
        // ManagerOfGroup - 3
        setFeeDistributionAndStatusThreshold(3, [25, 15, 10, 5, 3], thresholds[3]);
        // ManagerOfRegion - 4
        setFeeDistributionAndStatusThreshold(4, [30, 18, 12, 6, 3], thresholds[4]);
        // Director - 5
        setFeeDistributionAndStatusThreshold(5, [35, 21, 14, 7, 4], thresholds[5]);
        // DirectorOfGroup - 6
        setFeeDistributionAndStatusThreshold(6, [40, 24, 16, 8, 4], thresholds[6]);
        // DirectorOfRegion - 7
        setFeeDistributionAndStatusThreshold(7, [50, 30, 20, 10, 5], thresholds[7]);
    }


    /**
     * @dev Set up specific fee and status threshold
     * @param _st The status to set up for
     * @param _percentages Array of pecentages, which should go to member
     * @param _threshold The minimum amount of sum of children deposits to get
     *                   the status _st
     */
    function setFeeDistributionAndStatusThreshold(
        uint8 _st,
        uint8[5] _percentages,
        uint _threshold
    )
    private
    {
        statusThreshold[_threshold] = _st;
        for (uint8 i = 0; i &lt; _percentages.length; i++) {
            feeDistribution[_st][i] = _percentages[i];
        }
    }

}

contract Investors is Ownable {

    // investors
    /*
        &quot;0x418155b19d7350f5a843b826474aa2f7623e99a6&quot;,&quot;0xbeb7a29a008d69069fd10154966870ff1dda44a0&quot;,&quot;0xa9cb1b8ba1c8facb92172e459389f80d304595a3&quot;,&quot;0xf3f2bf9be0ccc8f27a15ccf18d820c0722e8996a&quot;,&quot;0xa0f36ac9f68c1a4594ef5cec29dc9b1cc67f822c&quot;,&quot;0xc319278cca404e3a479b088922e4117feb4cec9d&quot;,&quot;0xe633c933529d6fd7c6147d2b0dc51bfbe3304e56&quot;,&quot;0x5bd2c1f2f06b16e427a4ec3a6beef6263fd506da&quot;,&quot;0x52c4f101d0367c3f9933d0c14ea389e74ad00352&quot;,&quot;0xf7a0d2149f324a0b607ebf23df671acc4e9da6d2&quot;,&quot;0x0418df662bb2994262bb720d477e558a59e19490&quot;,&quot;0xf0de6520e0726ba3d84611f84867aa9987391402&quot;,&quot;0x1e895274a9570f150f11ae0ed86dd42a53208b81&quot;,&quot;0x95a247bef71f6b234e9805d1493366a302a498e4&quot;,&quot;0x9daaeaf355f69f7176a0145df6d1769d7f14553b&quot;,&quot;0x029136181d87c6f0979431255424b5fad78e8491&quot;,&quot;0x7e1f5669d9e1c593a495c5cec384ca32ad4a09fc&quot;,&quot;0x46c7e04fdaaa1a9298e63ca2fd47b0004cb236bf&quot;,&quot;0x5933fa485863da06584057494f0f6660d3c1477c&quot;,&quot;0x4290231804dd59947aff9fcef925287e44906e7b&quot;,&quot;0x2feaf2101b3f9943a81567badb56e3780946ce3f&quot;,&quot;0x5b602c34ba643913908f69a4cd5846a07ed3915b&quot;,&quot;0x146308896955030ce3bcc6030bab142afddaa1e6&quot;,&quot;0x9fc61b75451fabf5b5b78e03bacaf8bb592541fc&quot;,&quot;0x87f7636f7856466b6c6bce999574a784387e2b78&quot;,&quot;0x024db1f560327ab5174f1a737caf446b5644c709&quot;,&quot;0x715c248e621cbdb6f091bf653bb4bc331d2f9b1e&quot;,&quot;0xfe92a23b497140ba055a91ade89d91f95f8e5153&quot;,&quot;0xc3426e0e0634725a628a7a21bfd49274e1f24733&quot;,&quot;0xb12a79b9dba8bbb9ed5e329466a9c2703da38dbd&quot;,&quot;0x44d8336749ebf584a4bcd636cefe83e6e0b33e7d&quot;,&quot;0x89c91460c3bdc164250e5a27351c743c070c226a&quot;,&quot;0xe0798a1b847f450b5d4819043d27a380a4715af8&quot;,&quot;0xeac5e75252d902cb7f8473e45fff9ceb391c536b&quot;,&quot;0xea53e88876a6da2579d837a559b31b08d6750681&quot;,&quot;0x5df22fac00c45ef7b5c285c54a006798f42bbc6e&quot;,&quot;0x09899f20064b5e67d02f6a97ef412564977ee193&quot;,&quot;0xc572f18d0a4a65f6e612e6de484dbc15b8839df3&quot;,&quot;0x397b9719e720c0d33fe7dcc004958e56636cbf82&quot;,&quot;0x577de83b60299df60cc7fce7ac78d3a5d880aa95&quot;,&quot;0x9a716298949b16c4610b40ba1d19e96d3286c35c&quot;,&quot;0x60ef523f3845e38a20b63344a4e9ec689773ead6&quot;,&quot;0xe34252e3efe0514c5fb76c9fb39ff31f554d6659&quot;,&quot;0xbabfbdf4f422d36c00e448cc562ce0f5dbe47d64&quot;,&quot;0x2608cca4aff4cc3008ac6bd22e0664348ecee088&quot;,&quot;0x0dd1d3102f89d4ee7c260048cbe01933f17debde&quot;,&quot;0xdbb28fafc4ecd7736247aca7dc8e20782ca86a7a&quot;,&quot;0x6201fc413bb9292527956a70e7575436d5135ce1&quot;,&quot;0xa836f4cfb8fd3e5bccc9c7a6a678f2a5928b7c79&quot;,&quot;0x85dce799fd059d86c420eb4e3c1bd89e323b7b12&quot;,&quot;0xdef2086c6bbdc8b0f6e130907f05345b44af8cc3&quot;,&quot;0xc1004695ce07ef5efb1d218672e5cfcb659c5900&quot;,&quot;0x227a5b4bb4cffc2b907d9f586dd100989efeee56&quot;,&quot;0xd372b3d43ba8ea406f64dbc68f70ec812e54fbc8&quot;,&quot;0xdf6c417cdb27bc0c877a0e121a2c58ad884e85c6&quot;,&quot;0x090f4d53b5d7ebcb8e348709cdb708d80cd199f0&quot;,&quot;0x2499b302b6f5e57f54c1c7a326813e3dffddcd1a&quot;,&quot;0x3114024a034443e972707522d911fc709f62dd3e&quot;,&quot;0x30b864f49cef510b1173a5bfc31e77b0b59daf9e&quot;,&quot;0x9a9680f5ddee6cef96ef36ab506f4b6d3198c35e&quot;,&quot;0x08018337b9b138b631cd325168c3d5014df6e18b&quot;,&quot;0x2ac345a4ec1615c3a236099ebbed4911673bbfa5&quot;,&quot;0x2b9fd54828cd443b7c411419b058b44bd02fdc49&quot;,&quot;0x208713a63460d44e5a83ae8e8f7333496a05065e&quot;,&quot;0xe4052eb7ba8891ee7ccd7551faaa5f4c421904e7&quot;,&quot;0x74bc9db1ac813db06f771bcff359e9237b01c906&quot;,&quot;0x033dd047a042ea873ca27af36b64ca566a006e97&quot;,&quot;0xb4721808a3f2830a1708967302443b53f5943429&quot;,&quot;0xc91fbb815c2f4944d8c6846be6ac0e30f5a037df&quot;,&quot;0x19ef947c276436ac11a8be15567909a37d824e73&quot;,&quot;0x079eefd69c5a4c5e4c9ee3fa08c2a2964da3e11a&quot;,&quot;0x11fb64be296590f948d56daab6c2d102c9842b08&quot;,&quot;0x06ec97feaeb0f4b9a75f9671d6b62bfadaf18ddd&quot;,&quot;0xaeda3cff45032695fb2cf4f584cda822bd5d8b7e&quot;,&quot;0x9f377085d3da85107cd68bd08bdd9a1b862d44e0&quot;,&quot;0xb46b8d1c313c52fd422fe189dde1b4d0800a5e0f&quot;,&quot;0x99039fa34510c7321f4d19ea337c80cc14cc885d&quot;,&quot;0x378aba0f47c7790ed0e5ca61749b0025d1208a5d&quot;,&quot;0x4395e1db93d4e2f4583a4f87494eb0aea057b8fd&quot;,&quot;0xa4035578750564e48abfb5ba1d6eec1da1bf366f&quot;,&quot;0xb611b39eb6c16dae3754e514ddd5f02fcadd765f&quot;,&quot;0x67d41491ddc004e899a3faf109f526cd717fe6d8&quot;,&quot;0x58e2c10865f9a1668e800c91b6a3d7b3416fb26c&quot;,&quot;0x04e34355ced9d532c9bc01d5e569f31b6d46cd50&quot;,&quot;0xf80358cabdc9b9b79570b6f073a861cf5567bb57&quot;,&quot;0xbdacb079fc17a00d945f01f4f9bd5d03cfcd5b6c&quot;,&quot;0x387a723060bc42a7796c76197d2d3b41b4c43d19&quot;,&quot;0xa04cc8fc56c34ab8104f63c11bf211de4bb7b0aa&quot;,&quot;0x3bf8b5ede7501519d41792715215735d8f40af10&quot;,&quot;0x6c3a13bac5cf61b1927562a927e89ca6b5d034d6&quot;,&quot;0x9899aecef15de43eec04859be649ac4c50330886&quot;,&quot;0xa4d25bac971ca08b47a908a070b6362102206c12&quot;
        &quot;0xf88d963dc3f58fe6e71879543e57734e8152f70d&quot;,&quot;0x7b30a000f7ae56ee6206cbd9fb20c934b4bbb5d1&quot;,&quot;0xb2f0e5330e90559a738eda0df156635e18a145fd&quot;,&quot;0x5b2c07b6cce506f2293f1b32dc33d9928b8c9ada&quot;,&quot;0x5a967c0e38cb3bfad90df288ce238699cc47b5e3&quot;,&quot;0x0e686d6f3c897cae3984b80b5f6a7c785c708718&quot;,&quot;0xa8ea0b6bc70502644c0644fb4c0810540a1fa261&quot;,&quot;0xc70e278819ef5aec6b3ededc21e2981557e14443&quot;,&quot;0x477b5ae32ffcd34eb25f0c52866d4f602982dc6f&quot;,&quot;0x3e72a45fbc6a0858b506a0c7bedff79af75ae37c&quot;,&quot;0x1430e272a50703ef46d8ed5aa01e1ced71245341&quot;,&quot;0xc87d0bb90a6105a66fd5105c6746218d381b8207&quot;,&quot;0x0ed7f98b6177d0c15e27704f2bae4d068b8594d5&quot;,&quot;0x09a627b57879eb625cd8b7c59ffa363222553c23&quot;,&quot;0x0fdbc41046590ef7ee2a73b9808fd5bd7e189ac4&quot;,&quot;0x6a4b68af67a3b4a98fe1a59210dd3d775e567729&quot;,&quot;0x442a3daf774329fee3e904e86ddec1191f4be3ce&quot;,&quot;0x9efa8fe7fa51c8b36ab902046f879b035520f556&quot;,&quot;0x510e8e58b8ce4acaa6866e59dfc0fa339ea358e5&quot;,&quot;0x374831251283aa63aee6506ac6580479aaf3c22b&quot;,&quot;0xf758c498d020c0b92f2116d09d7ef6509c2c71bd&quot;,&quot;0xd83e8281ffcfb0ff96236e99ba66aabb8dcc7920&quot;,&quot;0x3670c3a5e65b757db8c82b12dd92057ac19d41fa&quot;,&quot;0xfd28eb7e3e5e3406ce6b82045d487c2be294cd38&quot;,&quot;0x2d23cd492096b903e4595ccdac74e49692a6ea8e&quot;,&quot;0x94d3a0a19ed5448052c549fd1f69f54c5f1fd8c5&quot;,&quot;0x8e5354ac59cee09d252e379a3534053306022ebe&quot;,&quot;0xa66f3700dda0147c56c2970202768c956c644ffd&quot;,&quot;0xf11d32baef6221f36916c58844cd8e9813c0af47&quot;,&quot;0x384a9bc1de23b36c2a23b963e57c8cd85b0d592c&quot;,&quot;0xbd00dfbaaa1abaa7948c7b2a6bed6e644293cc1c&quot;,&quot;0xa99a28afcbd4ab09a2ef2c0932becd0368225ee6&quot;,&quot;0xe554084d77bc6e510eed7276cb6033865375b669&quot;,&quot;0xe7582fa53531915a2fef5a81b98969d0091d8d44&quot;,&quot;0x5f15db1d209fa6fd3c667fb086d3d89e3793511f&quot;,&quot;0x7e9ff5348d57d3427e24b7e104ad5acf039edaf2&quot;,&quot;0xb4fb1a01483454d75a0cdfa983b99236c4c91111&quot;,&quot;0x4a7cc5eebfe019efab06c1fa9ae8453dc63ba84e&quot;,&quot;0xb6fc08d5043b51ac05cdbd88afaab0e4422762d0&quot;,&quot;0xb18365f4f1e95287a5f85c8a67cebee9e6164c31&quot;,&quot;0xaf575cfb94d65eaeaace749868282d0e26e4608a&quot;,&quot;0x3d07e5ff3a2d29ee17584dff60cc99bb4cd79c3d&quot;,&quot;0x08f0afc93fbc8188150f4bcab004e259cd4785aa&quot;,&quot;0x65ac3ed81f101e5651c72c4cc2d74650378b5b0c&quot;,&quot;0x58aef4fc6b54cb53683a6481655021109b8d4dce&quot;,&quot;0x6aa43e24604577574a0632524a1f4c21d70a61e2&quot;,&quot;0xbee55aa5ad9953294ecac83a6b62f10c8155444b&quot;,&quot;0x99dc885ac6ec9873e2409d5a31e7f525c1897e09&quot;,&quot;0x53a0622034680d64bd0f139df5e989d70b194a4d&quot;,&quot;0xa6ba4966f1fdd0e8560516e53490b25cf0c4fbd1&quot;,&quot;0xbd1b95ee4621ecda41961da61277e17e52f37dbf&quot;,&quot;0xf6481b881eea526ae36cbe11d58d641f96f04a77&quot;,&quot;0xd158d53d75eac0dda9d2dedf3418d071a2fd44ee&quot;,&quot;0xb22697e3f33544da7782c8197d07704e1906a3bf&quot;,&quot;0xa3237e67df409dca45930c1f5f671251adc202be&quot;,&quot;0x72b26f2dded753a01f391322b00f9a85a77c7fda&quot;,&quot;0x203fbf3a77bdf35f7aca220b363272896db91d57&quot;,&quot;0xb1be2f4d72eb87dfcf7ed93c8ec16e4040e52560&quot;,&quot;0xc60d8a0313ede22194ebe6285471f72f9bcdcda0&quot;,&quot;0x9888e7423ea48413a4c90a10c76ca5f90d065e1f&quot;,&quot;0x0be856768ad0ec5b45464ce5202e2c337224cebf&quot;,&quot;0x3b54ea00a74b116510c4f73a3fc19a62991aaf64&quot;,&quot;0xe72aa06ffe7058f73622f219af164369c03e3a41&quot;,&quot;0x7e71fada017d9af455f38db4957d527f51fe1bc5&quot;,&quot;0x78430e58934220f37ca6b9dbe622f076ad0eb3f5&quot;,&quot;0x0c765e201bb43d49ab5b44d40d3cf1d219424821&quot;,&quot;0x4739d251b40028761bbd8034a21919d926f23b45&quot;,&quot;0x00a7c7bc71022032f6ef3f699b212c9450875740&quot;,&quot;0x0d4f50b0d43d34a163b8dd7c33fbcc92a19cfa59&quot;,&quot;0x9284fbc0cc35d9b835de2b00b6b7093075527f6b&quot;,&quot;0x3564e101b32fe5f3c99e8da823ac003373c26d33&quot;,&quot;0xf5a358f228dc964fa7c703cb6ad9f6002ce77b17&quot;,&quot;0x8297a09b5dac9e60896c787f0995ac06441ab14f&quot;,&quot;0xed8c9b4fd60a6e4ae66c38f5819cffb360af5dd5&quot;,&quot;0x23009de4ec4a666ba719656d844e42e264e14c6b&quot;,&quot;0x63227f4492c6bbd9e1015f2c864a31eef1465cd3&quot;,&quot;0xf3e0ec409386ea202b15d97bb8dd2d131917e3b1&quot;,&quot;0x981154fafb3a5aeee43d984ee255e5121ce79790&quot;,&quot;0x49a4598cdf112b5848c11c465d39989fcb5cb6c1&quot;,&quot;0x575ca03f00f9e5566d85dc095165998953ab0753&quot;,&quot;0x09d87f2979c4ac6c9d4077d1f5d94cb9aadf43ca&quot;,&quot;0x0b4575867757b3982379f4d05c92fd2d019247a0&quot;,&quot;0x8c666d40e2ac961885d675e58e3115b859dac6c1&quot;,&quot;0x34a3401ebe8431d44efee9948c4b641142407aa8&quot;,&quot;0x1683512dbcce189ea6042862a2ba4abd4886623b&quot;,&quot;0x72d45f733336f6f03ef20c1ad4f51ff6b7f90186&quot;,&quot;0x569fe010fe2d40037c029537eef78aa9b0e018f9&quot;,&quot;0x061def9fab3aee4161711d4c040d138a273893b5&quot;,&quot;0xe77e2ae67e1152425c75ff56291d03d92f5d3cad&quot;,&quot;0x93ebdeb0b0c967f5cc1a10f481569e1871b7d7cd&quot;,&quot;0x6d7910f900fc3e3f2e2b6d5d8aad43bc6a232685&quot;,&quot;0xb16e28be300f579a81f2b80fdd5a95cf168bf3a4&quot;
        &quot;0xd69835daeee01601ea991efe9fd0309c64c07d42&quot;,&quot;0x30b45ed69250a160ee91dadab2986d21626d7f4b&quot;,&quot;0xd28075489da5f9ef51bcc61668c114296a8e8603&quot;,&quot;0xb63c5cb479034bacc04266536e32aeeb9f958059&quot;,&quot;0x5f81fe78b5c238afd97a32c572aa04d87b730147&quot;,&quot;0xb98c8d7d64ef60cc76410f31c19570da0c4d9f12&quot;,&quot;0x031eb1c3a9909ea26d07f194abe5ad7f6945a482&quot;,&quot;0x83691573a4fdb5ff2cdbe2df155da09810a3c2bc&quot;,&quot;0x6722a482e1f3b797e69f98a3324b6660b9c6baa5&quot;,&quot;0xbda61db5824240280ed000a57ed5e6f70d552dd6&quot;,&quot;0x58605742105060e5c3070b88b0f51eca7f022d06&quot;,&quot;0xb4754815ccfc9c98a80f71a0a2c97471188bd556&quot;,&quot;0x50503144f253e6f05103b643c082ebf215436d95&quot;,&quot;0xd0dbef9f712ee0ca05fe48b6a40f5b774a109feb&quot;
    */
    address[] public investors;

    // investor address =&gt; percentage * 10^(-2)
    /*
        3026,1500,510,462,453,302,250,250,226,220,150,129,100,100,60,50,50,50,50,50,50,50,50,50,50,40,40,30,27,26,25,25,25,25,25,25,25,25,23,20,19,15,15,15,15,15,14,14,13,13,13,13,12,12,11,11,11,11,11,11,10,10,10,10,10,10,10,10,12,9,9,8,8,8,8,7,6,6,6,6,6,6,6,6,6,6,6,6,6,5,5,5
        5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,4,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,2,1,6
        6,125,50,5,8,50,23,3,115,14,10,50,5,5
    */
    mapping (address =&gt; uint) public investorPercentages;


    /**
     * @dev Add investors
     */
    function addInvestors(address[] _investors, uint[] _investorPercentages) onlyOwner public {
        for (uint i = 0; i &lt; _investors.length; i++) {
            investors.push(_investors[i]);
            investorPercentages[_investors[i]] = _investorPercentages[i];
        }
    }


    /**
     *  @dev Get investors count
     *  @return uint count
     */
    function getInvestorsCount() public constant returns (uint) {
        return investors.length;
    }


    /**
     *  @dev Get investors&#39; fee depending on the current year
     *  @return uint8 The fee percentage, which investors get
     */
    function getInvestorsFee() public constant returns (uint8) {
        //01/01/2020
        if (now &gt;= 1577836800) {
            return 1;
        }
        //01/01/2019
        if (now &gt;= 1546300800) {
            return 5;
        }
        return 10;
    }

}

contract Referral is Declaration, Ownable {

    using SafeMath for uint;

    // reference to token contract
    WealthBuilderToken private token;

    // reference to data contract
    Data private data;

    // reference to investors contract
    Investors private investors;

    // investors balance to be distributed in wei*10^(2)
    uint public investorsBalance;

    /**
     *  how many USD cents get per ETH
     */
    uint public ethUsdRate;

    /**
     * @dev The Referral constructor to set up the first depositer,
     * reference to system token, data &amp; investors and set ethUsdRate
     */
    function Referral(uint _ethUsdRate, address _token, address _data, address _investors) public {
        ethUsdRate = _ethUsdRate;

        // instantiate token &amp; data contracts
        token = WealthBuilderToken(_token);
        data = Data(_data);
        investors = Investors(_investors);

        investorsBalance = 0;
    }

    /**
     * @dev Callback function
     */
    function() payable public {
    }

    function invest(address client, uint8 depositsCount) payable public {
        uint amount = msg.value;

        // if less then 5 deposits
        if (depositsCount &lt; 5) {

            uint serviceFee;
            uint investorsFee = 0;

            if (depositsCount == 0) {
                uint8 investorsFeePercentage = investors.getInvestorsFee();
                serviceFee = amount * (serviceFees[depositsCount].sub(investorsFeePercentage));
                investorsFee = amount * investorsFeePercentage;
                investorsBalance += investorsFee;
            } else {
                serviceFee = amount * serviceFees[depositsCount];
            }

            uint referralFee = amount * referralFees[depositsCount];

            // distribute deposit fee among users above on the branch &amp; update users&#39; statuses
            distribute(data.parentOf(client), 0, depositsCount, amount);

            // update balance &amp; number of deposits of user
            uint active = (amount * 100)
            .sub(referralFee)
            .sub(serviceFee)
            .sub(investorsFee);
            token.mint(client, active / 100 * token.rate() / token.mrate());

            // update owner`s balance
            data.addBalance(owner, serviceFee * 10000);
        } else {
            token.mint(client, amount * token.rate() / token.mrate());
        }
    }


    /**
     * @dev Recursively distribute deposit fee between parents
     * @param _node Parent address
     * @param _prevPercentage The percentage for previous parent
     * @param _depositsCount Count of depositer deposits
     * @param _amount The amount of deposit
     */
    function distribute(
        address _node,
        uint _prevPercentage,
        uint8 _depositsCount,
        uint _amount
    )
    private
    {
        address node = _node;
        uint prevPercentage = _prevPercentage;

        // distribute deposit fee among users above on the branch &amp; update users&#39; statuses
        while(node != address(0)) {
            uint8 status = data.statuses(node);

            // count fee percentage of current node
            uint nodePercentage = feeDistribution[status][_depositsCount];
            uint percentage = nodePercentage.sub(prevPercentage);
            data.addBalance(node, _amount * percentage * 10000);

            //update refferals sum amount
            data.addReferralDeposit(node, _amount * ethUsdRate / 10**18);

            //update status
            updateStatus(node, status);

            node = data.parentOf(node);
            prevPercentage = nodePercentage;
        }
    }


    /**
     * @dev Update node status if children sum amount is enough
     * @param _node Node address
     * @param _status Node current status
     */
    function updateStatus(address _node, uint8 _status) private {
        uint refDep = data.referralDeposits(_node);

        for (uint i = thresholds.length - 1; i &gt; _status; i--) {
            uint threshold = thresholds[i] * 100;

            if (refDep &gt;= threshold) {
                data.setStatus(_node, statusThreshold[threshold]);
                break;
            }
        }
    }


    /**
     * @dev Distribute fee between investors
     */
    function distributeInvestorsFee(uint start, uint end) onlyOwner public {
        for (uint i = start; i &lt; end; i++) {
            address investor = investors.investors(i);
            uint investorPercentage = investors.investorPercentages(investor);
            data.addInvestorBalance(investor, investorsBalance * investorPercentage);
        }
        if (end == investors.getInvestorsCount()) {
            investorsBalance = 0;
        }
    }


    /**
     * @dev Set token exchange rate
     * @param _rate wbt/eth rate
     */
    function setRate(uint _rate) onlyOwner public {
        token.setRate(_rate);
    }


    /**
     * @dev Set ETH exchange rate
     * @param _ethUsdRate eth/usd rate
     */
    function setEthUsdRate(uint _ethUsdRate) onlyOwner public {
        ethUsdRate = _ethUsdRate;
    }


    /**
     * @dev Add new child
     * @param _inviter parent
     * @param _invitee child
     */
    function invite(
        address _inviter,
        address _invitee
    )
    public onlyOwner
    {
        data.setParent(_invitee, _inviter);
        // Agent - 0
        data.setStatus(_invitee, 0);
    }


    /**
     * @dev Set _status for _addr
     * @param _addr address
     * @param _status ref. status
     */
    function setStatus(address _addr, uint8 _status) public onlyOwner {
        data.setStatus(_addr, _status);
    }


    /**
     * @dev Set investors contract address
     * @param _addr address
     */
    function setInvestors(address _addr) public onlyOwner {
        investors = Investors(_addr);
    }


    /**
     * @dev Withdraw _amount for _addr
     * @param _addr withdrawal address
     * @param _amount withdrawal amount
     */
    function withdraw(address _addr, uint256 _amount, bool investor) public onlyOwner {
        uint amount = investor ? data.investorBalanceOf(_addr)
        : data.balanceOf(_addr);
        require(amount &gt;= _amount &amp;&amp; this.balance &gt;= _amount);

        if (investor) {
            data.subtrInvestorBalance(_addr, _amount * 1000000);
        } else {
            data.subtrBalance(_addr, _amount * 1000000);
        }

        _addr.transfer(_amount);
    }


    /**
     * @dev Withdraw contract balance to _addr
     * @param _addr withdrawal address
     */
    function withdrawOwner(address _addr, uint256 _amount) public onlyOwner {
        require(this.balance &gt;= _amount);
        _addr.transfer(_amount);
    }


    /**
     * @dev Withdraw corresponding amount of ETH to _addr and burn _value tokens
     * @param _addr withdrawal address
     * @param _amount amount of tokens to sell
     */
    function withdrawToken(address _addr, uint256 _amount) onlyOwner public {
        token.burn(_addr, _amount);
        uint256 etherValue = _amount * token.mrate() / token.rate();
        _addr.transfer(etherValue);
    }


    /**
     * @dev Transfer ownership of token contract to _addr
     * @param _addr address
     */
    function transferTokenOwnership(address _addr) onlyOwner public {
        token.transferOwnership(_addr);
    }


    /**
     * @dev Transfer ownership of data contract to _addr
     * @param _addr address
     */
    function transferDataOwnership(address _addr) onlyOwner public {
        data.transferOwnership(_addr);
    }

}

contract PChannel is Ownable {
    
    Referral private refProgram;

    // fixed deposit amount in USD cents
    uint private depositAmount = 100000;

    // max deposit amount in USD cents
    uint private maxDepositAmount =125000;

    // investor =&gt; number of deposits
    mapping (address =&gt; uint8) private deposits; 
    
    function PChannel(address _refProgram) public {
        refProgram = Referral(_refProgram);
    }
    
    function() payable public {
        uint8 depositsCount = deposits[msg.sender];
        // check if user has already exceeded 15 deposits limit
        // if so, set deposit count to 0 and make first deposit
        if (depositsCount == 15) {
            depositsCount = 0;
            deposits[msg.sender] = 0;
        }

        uint amount = msg.value;
        uint usdAmount = amount * refProgram.ethUsdRate() / 10**18;
        // check if deposit amount is valid 
        require(usdAmount &gt;= depositAmount &amp;&amp; usdAmount &lt;= maxDepositAmount);
        
        refProgram.invest.value(amount)(msg.sender, depositsCount);
        deposits[msg.sender]++;
    }

    /**
     * @dev Set investors contract address
     * @param _addr address
     */
    function setRefProgram(address _addr) public onlyOwner {
        refProgram = Referral(_addr);
    }
    
}