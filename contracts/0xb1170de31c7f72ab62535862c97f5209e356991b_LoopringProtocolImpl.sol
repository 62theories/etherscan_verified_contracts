/*
  Copyright 2017 Loopring Project Ltd (Loopring Foundation).
  Licensed under the Apache License, Version 2.0 (the &quot;License&quot;);
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
  http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an &quot;AS IS&quot; BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/
pragma solidity 0.4.21;
/// @title Utility Functions for uint
/// @author Daniel Wang - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="3f5b5e51565a537f5350504f4d56515811504d58">[email&#160;protected]</a>&gt;
library MathUint {
    function mul(
        uint a,
        uint b
        )
        internal
        pure
        returns (uint c)
    {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function sub(
        uint a,
        uint b
        )
        internal
        pure
        returns (uint)
    {
        require(b &lt;= a);
        return a - b;
    }
    function add(
        uint a,
        uint b
        )
        internal
        pure
        returns (uint c)
    {
        c = a + b;
        require(c &gt;= a);
    }
    function tolerantSub(
        uint a,
        uint b
        )
        internal
        pure
        returns (uint c)
    {
        return (a &gt;= b) ? a - b : 0;
    }
    /// @dev calculate the square of Coefficient of Variation (CV)
    /// https://en.wikipedia.org/wiki/Coefficient_of_variation
    function cvsquare(
        uint[] arr,
        uint scale
        )
        internal
        pure
        returns (uint)
    {
        uint len = arr.length;
        require(len &gt; 1);
        require(scale &gt; 0);
        uint avg = 0;
        for (uint i = 0; i &lt; len; i++) {
            avg += arr[i];
        }
        avg = avg / len;
        if (avg == 0) {
            return 0;
        }
        uint cvs = 0;
        uint s;
        uint item;
        for (i = 0; i &lt; len; i++) {
            item = arr[i];
            s = item &gt; avg ? item - avg : avg - item;
            cvs += mul(s, s);
        }
        return ((mul(mul(cvs, scale), scale) / avg) / avg) / (len - 1);
    }
}
/*
  Copyright 2017 Loopring Project Ltd (Loopring Foundation).
  Licensed under the Apache License, Version 2.0 (the &quot;License&quot;);
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
  http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an &quot;AS IS&quot; BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/
/// @title Utility Functions for address
/// @author Daniel Wang - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="3551545b5c505975595a5a45475c5b521b5a4752">[email&#160;protected]</a>&gt;
library AddressUtil {
    function isContract(
        address addr
        )
        internal
        view
        returns (bool)
    {
        if (addr == 0x0) {
            return false;
        } else {
            uint size;
            assembly { size := extcodesize(addr) }
            return size &gt; 0;
        }
    }
}
/*
  Copyright 2017 Loopring Project Ltd (Loopring Foundation).
  Licensed under the Apache License, Version 2.0 (the &quot;License&quot;);
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
  http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an &quot;AS IS&quot; BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/
/*
  Copyright 2017 Loopring Project Ltd (Loopring Foundation).
  Licensed under the Apache License, Version 2.0 (the &quot;License&quot;);
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
  http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an &quot;AS IS&quot; BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/
/// @title ERC20 Token Interface
/// @dev see https://github.com/ethereum/EIPs/issues/20
/// @author Daniel Wang - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="b5d1d4dbdcd0d9f5d9dadac5c7dcdbd29bdac7d2">[email&#160;protected]</a>&gt;
contract ERC20 {
    function balanceOf(
        address who
        )
        view
        public
        returns (uint256);
    function allowance(
        address owner,
        address spender
        )
        view
        public
        returns (uint256);
    function transfer(
        address to,
        uint256 value
        )
        public
        returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 value
        )
        public
        returns (bool);
    function approve(
        address spender,
        uint256 value
        )
        public
        returns (bool);
}
/*
  Copyright 2017 Loopring Project Ltd (Loopring Foundation).
  Licensed under the Apache License, Version 2.0 (the &quot;License&quot;);
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
  http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an &quot;AS IS&quot; BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/
/// @title Loopring Token Exchange Protocol Contract Interface
/// @author Daniel Wang - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="462227282f232a062a292936342f282168293421">[email&#160;protected]</a>&gt;
/// @author Kongliang Zhong - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="6d0602030a01040c030a2d0102021d1f04030a43021f0a">[email&#160;protected]</a>&gt;
contract LoopringProtocol {
    uint8   public constant MARGIN_SPLIT_PERCENTAGE_BASE = 100;
    /// @dev Event to emit if a ring is successfully mined.
    /// _amountsList is an array of:
    /// [_amountS, _amountB, _lrcReward, _lrcFee, splitS, splitB].
    event RingMined(
        uint                _ringIndex,
        bytes32     indexed _ringHash,
        address             _feeRecipient,
        bytes32[]           _orderHashList,
        uint[6][]           _amountsList
    );
    event OrderCancelled(
        bytes32     indexed _orderHash,
        uint                _amountCancelled
    );
    event AllOrdersCancelled(
        address     indexed _address,
        uint                _cutoff
    );
    event OrdersCancelled(
        address     indexed _address,
        address             _token1,
        address             _token2,
        uint                _cutoff
    );
    /// @dev Cancel a order. cancel amount(amountS or amountB) can be specified
    ///      in orderValues.
    /// @param addresses          owner, tokenS, tokenB, wallet, authAddr
    /// @param orderValues        amountS, amountB, validSince (second),
    ///                           validUntil (second), lrcFee, and cancelAmount.
    /// @param buyNoMoreThanAmountB -
    ///                           This indicates when a order should be considered
    ///                           as &#39;completely filled&#39;.
    /// @param marginSplitPercentage -
    ///                           Percentage of margin split to share with miner.
    /// @param v                  Order ECDSA signature parameter v.
    /// @param r                  Order ECDSA signature parameters r.
    /// @param s                  Order ECDSA signature parameters s.
    function cancelOrder(
        address[5] addresses,
        uint[6]    orderValues,
        bool       buyNoMoreThanAmountB,
        uint8      marginSplitPercentage,
        uint8      v,
        bytes32    r,
        bytes32    s
        )
        external;
    /// @dev   Set a cutoff timestamp to invalidate all orders whose timestamp
    ///        is smaller than or equal to the new value of the address&#39;s cutoff
    ///        timestamp, for a specific trading pair.
    /// @param cutoff The cutoff timestamp, will default to `block.timestamp`
    ///        if it is 0.
    function cancelAllOrdersByTradingPair(
        address token1,
        address token2,
        uint cutoff
        )
        external;
    /// @dev   Set a cutoff timestamp to invalidate all orders whose timestamp
    ///        is smaller than or equal to the new value of the address&#39;s cutoff
    ///        timestamp.
    /// @param cutoff The cutoff timestamp, will default to `block.timestamp`
    ///        if it is 0.
    function cancelAllOrders(
        uint cutoff
        )
        external;
    /// @dev Submit a order-ring for validation and settlement.
    /// @param addressList  List of each order&#39;s owner, tokenS, wallet, authAddr.
    ///                     Note that next order&#39;s `tokenS` equals this order&#39;s
    ///                     `tokenB`.
    /// @param uintArgsList List of uint-type arguments in this order:
    ///                     amountS, amountB, validSince (second),
    ///                     validUntil (second), lrcFee, and rateAmountS.
    /// @param uint8ArgsList -
    ///                     List of unit8-type arguments, in this order:
    ///                     marginSplitPercentageList.
    /// @param buyNoMoreThanAmountBList -
    ///                     This indicates when a order should be considered
    /// @param vList        List of v for each order. This list is 1-larger than
    ///                     the previous lists, with the last element being the
    ///                     v value of the ring signature.
    /// @param rList        List of r for each order. This list is 1-larger than
    ///                     the previous lists, with the last element being the
    ///                     r value of the ring signature.
    /// @param sList        List of s for each order. This list is 1-larger than
    ///                     the previous lists, with the last element being the
    ///                     s value of the ring signature.
    /// @param miner        Miner address.
    /// @param feeSelections -
    ///                     Bits to indicate fee selections. `1` represents margin
    ///                     split and `0` represents LRC as fee.
    function submitRing(
        address[4][]    addressList,
        uint[6][]       uintArgsList,
        uint8[1][]      uint8ArgsList,
        bool[]          buyNoMoreThanAmountBList,
        uint8[]         vList,
        bytes32[]       rList,
        bytes32[]       sList,
        address         miner,
        uint16          feeSelections
        )
        public;
}
/*
  Copyright 2017 Loopring Project Ltd (Loopring Foundation).
  Licensed under the Apache License, Version 2.0 (the &quot;License&quot;);
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
  http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an &quot;AS IS&quot; BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/
/// @title Token Register Contract
/// @dev This contract maintains a list of tokens the Protocol supports.
/// @author Kongliang Zhong - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="f59e9a9b92999c949b92b5999a9a85879c9b92db9a8792">[email&#160;protected]</a>&gt;,
/// @author Daniel Wang - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="4f2b2e21262a230f2320203f3d26">[email&#160;protected]</a>ng.org&gt;.
contract TokenRegistry {
    event TokenRegistered(address addr, string symbol);
    event TokenUnregistered(address addr, string symbol);
    function registerToken(
        address addr,
        string  symbol
        )
        external;
    function registerMintedToken(
        address addr,
        string  symbol
        )
        external;
    function unregisterToken(
        address addr,
        string  symbol
        )
        external;
    function areAllTokensRegistered(
        address[] addressList
        )
        external
        view
        returns (bool);
    function getAddressBySymbol(
        string symbol
        )
        external
        view
        returns (address);
    function isTokenRegisteredBySymbol(
        string symbol
        )
        public
        view
        returns (bool);
    function isTokenRegistered(
        address addr
        )
        public
        view
        returns (bool);
    function getTokens(
        uint start,
        uint count
        )
        public
        view
        returns (address[] addressList);
}
/*
  Copyright 2017 Loopring Project Ltd (Loopring Foundation).
  Licensed under the Apache License, Version 2.0 (the &quot;License&quot;);
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
  http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an &quot;AS IS&quot; BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/
/// @title TokenTransferDelegate
/// @dev Acts as a middle man to transfer ERC20 tokens on behalf of different
/// versions of Loopring protocol to avoid ERC20 re-authorization.
/// @author Daniel Wang - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="9afefbf4f3fff6daf6f5f5eae8f3f4fdb4f5e8fd">[email&#160;protected]</a>&gt;.
contract TokenTransferDelegate {
    event AddressAuthorized(address indexed addr, uint32 number);
    event AddressDeauthorized(address indexed addr, uint32 number);
    // The following map is used to keep trace of order fill and cancellation
    // history.
    mapping (bytes32 =&gt; uint) public cancelledOrFilled;
    // This map is used to keep trace of order&#39;s cancellation history.
    mapping (bytes32 =&gt; uint) public cancelled;
    // A map from address to its cutoff timestamp.
    mapping (address =&gt; uint) public cutoffs;
    // A map from address to its trading-pair cutoff timestamp.
    mapping (address =&gt; mapping (bytes20 =&gt; uint)) public tradingPairCutoffs;
    /// @dev Add a Loopring protocol address.
    /// @param addr A loopring protocol address.
    function authorizeAddress(
        address addr
        )
        external;
    /// @dev Remove a Loopring protocol address.
    /// @param addr A loopring protocol address.
    function deauthorizeAddress(
        address addr
        )
        external;
    function getLatestAuthorizedAddresses(
        uint max
        )
        external
        view
        returns (address[] addresses);
    /// @dev Invoke ERC20 transferFrom method.
    /// @param token Address of token to transfer.
    /// @param from Address to transfer token from.
    /// @param to Address to transfer token to.
    /// @param value Amount of token to transfer.
    function transferToken(
        address token,
        address from,
        address to,
        uint    value
        )
        external;
    function batchTransferToken(
        address lrcTokenAddress,
        address minerFeeRecipient,
        uint8 walletSplitPercentage,
        bytes32[] batch
        )
        external;
    function isAddressAuthorized(
        address addr
        )
        public
        view
        returns (bool);
    function addCancelled(bytes32 orderHash, uint cancelAmount)
        external;
    function addCancelledOrFilled(bytes32 orderHash, uint cancelOrFillAmount)
        external;
    function setCutoffs(uint t)
        external;
    function setTradingPairCutoffs(bytes20 tokenPair, uint t)
        external;
    function checkCutoffsBatch(address[] owners, bytes20[] tradingPairs, uint[] validSince)
        external
        view;
}
/// @title An Implementation of LoopringProtocol.
/// @author Daniel Wang - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="1d797c737478715d7172726d6f74737a33726f7a">[email&#160;protected]</a>&gt;,
/// @author Kongliang Zhong - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="771c1819101b1e161910371b181807051e191059180510">[email&#160;protected]</a>&gt;
///
/// Recognized contributing developers from the community:
///     https://github.com/Brechtpd
///     https://github.com/rainydio
///     https://github.com/BenjaminPrice
///     https://github.com/jonasshen
///     https://github.com/Hephyrius
contract LoopringProtocolImpl is LoopringProtocol {
    using AddressUtil   for address;
    using MathUint      for uint;
    address public constant  lrcTokenAddress             = 0xEF68e7C694F40c8202821eDF525dE3782458639f;
    address public constant  tokenRegistryAddress        = 0x004DeF62C71992615CF22786d0b7Efb22850Df4a;
    address public constant  delegateAddress             = 0x5567ee920f7E62274284985D793344351A00142B;
    uint64  public  ringIndex                   = 0;
    uint8   public  walletSplitPercentage       = 20;
    // Exchange rate (rate) is the amount to sell or sold divided by the amount
    // to buy or bought.
    //
    // Rate ratio is the ratio between executed rate and an order&#39;s original
    // rate.
    //
    // To require all orders&#39; rate ratios to have coefficient ofvariation (CV)
    // smaller than 2.5%, for an example , rateRatioCVSThreshold should be:
    //     `(0.025 * RATE_RATIO_SCALE)^2` or 62500.
    uint    public rateRatioCVSThreshold        = 62500;
    uint    public constant MAX_RING_SIZE       = 8;
    uint    public constant RATE_RATIO_SCALE    = 10000;
    /// @param orderHash    The order&#39;s hash
    /// @param feeSelection -
    ///                     A miner-supplied value indicating if LRC (value = 0)
    ///                     or margin split is choosen by the miner (value = 1).
    ///                     We may support more fee model in the future.
    /// @param rateS        Sell Exchange rate provided by miner.
    /// @param rateB        Buy Exchange rate provided by miner.
    /// @param fillAmountS  Amount of tokenS to sell, calculated by protocol.
    /// @param lrcReward    The amount of LRC paid by miner to order owner in
    ///                     exchange for margin split.
    /// @param lrcFeeState  The amount of LR paid by order owner to miner.
    /// @param splitS      TokenS paid to miner.
    /// @param splitB      TokenB paid to miner.
    struct OrderState {
        address owner;
        address tokenS;
        address tokenB;
        address wallet;
        address authAddr;
        uint    validSince;
        uint    validUntil;
        uint    amountS;
        uint    amountB;
        uint    lrcFee;
        bool    buyNoMoreThanAmountB;
        bool    marginSplitAsFee;
        bytes32 orderHash;
        uint8   marginSplitPercentage;
        uint    rateS;
        uint    rateB;
        uint    fillAmountS;
        uint    lrcReward;
        uint    lrcFeeState;
        uint    splitS;
        uint    splitB;
    }
    /// @dev A struct to capture parameters passed to submitRing method and
    ///      various of other variables used across the submitRing core logics.
    struct RingParams {
        uint8[]       vList;
        bytes32[]     rList;
        bytes32[]     sList;
        address       miner;
        uint16        feeSelections;
        uint          ringSize;         // computed
        bytes32       ringHash;         // computed
    }
    /// @dev Disable default function.
    function ()
        payable
        public
    {
        revert();
    }
    function cancelOrder(
        address[5] addresses,
        uint[6]    orderValues,
        bool       buyNoMoreThanAmountB,
        uint8      marginSplitPercentage,
        uint8      v,
        bytes32    r,
        bytes32    s
        )
        external
    {
        uint cancelAmount = orderValues[5];
        require(cancelAmount &gt; 0); // &quot;amount to cancel is zero&quot;);
        OrderState memory order = OrderState(
            addresses[0],
            addresses[1],
            addresses[2],
            addresses[3],
            addresses[4],
            orderValues[2],
            orderValues[3],
            orderValues[0],
            orderValues[1],
            orderValues[4],
            buyNoMoreThanAmountB,
            false,
            0x0,
            marginSplitPercentage,
            0,
            0,
            0,
            0,
            0,
            0,
            0
        );
        require(msg.sender == order.owner); // &quot;cancelOrder not submitted by order owner&quot;);
        bytes32 orderHash = calculateOrderHash(order);
        verifySignature(
            order.owner,
            orderHash,
            v,
            r,
            s
        );
        TokenTransferDelegate delegate = TokenTransferDelegate(delegateAddress);
        delegate.addCancelled(orderHash, cancelAmount);
        delegate.addCancelledOrFilled(orderHash, cancelAmount);
        emit OrderCancelled(orderHash, cancelAmount);
    }
    function cancelAllOrdersByTradingPair(
        address token1,
        address token2,
        uint    cutoff
        )
        external
    {
        uint t = (cutoff == 0 || cutoff &gt;= block.timestamp) ? block.timestamp : cutoff;
        bytes20 tokenPair = bytes20(token1) ^ bytes20(token2);
        TokenTransferDelegate delegate = TokenTransferDelegate(delegateAddress);
        require(delegate.tradingPairCutoffs(msg.sender, tokenPair) &lt; t);
        // &quot;attempted to set cutoff to a smaller value&quot;
        delegate.setTradingPairCutoffs(tokenPair, t);
        emit OrdersCancelled(
            msg.sender,
            token1,
            token2,
            t
        );
    }
    function cancelAllOrders(
        uint cutoff
        )
        external
    {
        uint t = (cutoff == 0 || cutoff &gt;= block.timestamp) ? block.timestamp : cutoff;
        TokenTransferDelegate delegate = TokenTransferDelegate(delegateAddress);
        require(delegate.cutoffs(msg.sender) &lt; t); // &quot;attempted to set cutoff to a smaller value&quot;
        delegate.setCutoffs(t);
        emit AllOrdersCancelled(msg.sender, t);
    }
    function submitRing(
        address[4][]  addressList,
        uint[6][]     uintArgsList,
        uint8[1][]    uint8ArgsList,
        bool[]        buyNoMoreThanAmountBList,
        uint8[]       vList,
        bytes32[]     rList,
        bytes32[]     sList,
        address       miner,
        uint16        feeSelections
        )
        public
    {
        // Check if the highest bit of ringIndex is &#39;1&#39;.
        require((ringIndex &gt;&gt; 63) == 0); // &quot;attempted to re-ent submitRing function&quot;);
        // Set the highest bit of ringIndex to &#39;1&#39;.
        uint64 _ringIndex = ringIndex;
        ringIndex |= (1 &lt;&lt; 63);
        RingParams memory params = RingParams(
            vList,
            rList,
            sList,
            miner,
            feeSelections,
            addressList.length,
            0x0 // ringHash
        );
        verifyInputDataIntegrity(
            params,
            addressList,
            uintArgsList,
            uint8ArgsList,
            buyNoMoreThanAmountBList
        );
        // Assemble input data into structs so we can pass them to other functions.
        // This method also calculates ringHash, therefore it must be called before
        // calling `verifyRingSignatures`.
        TokenTransferDelegate delegate = TokenTransferDelegate(delegateAddress);
        OrderState[] memory orders = assembleOrders(
            params,
            delegate,
            addressList,
            uintArgsList,
            uint8ArgsList,
            buyNoMoreThanAmountBList
        );
        verifyRingSignatures(params, orders);
        verifyTokensRegistered(params, orders);
        handleRing(_ringIndex, params, orders, delegate);
        ringIndex = _ringIndex + 1;
    }
    /// @dev Validate a ring.
    function verifyRingHasNoSubRing(
        uint          ringSize,
        OrderState[]  orders
        )
        private
        pure
    {
        // Check the ring has no sub-ring.
        for (uint i = 0; i &lt; ringSize - 1; i++) {
            address tokenS = orders[i].tokenS;
            for (uint j = i + 1; j &lt; ringSize; j++) {
                require(tokenS != orders[j].tokenS); // &quot;found sub-ring&quot;);
            }
        }
    }
    /// @dev Verify the ringHash has been signed with each order&#39;s auth private
    ///      keys as well as the miner&#39;s private key.
    function verifyRingSignatures(
        RingParams params,
        OrderState[] orders
        )
        private
        pure
    {
        uint j;
        for (uint i = 0; i &lt; params.ringSize; i++) {
            j = i + params.ringSize;
            verifySignature(
                orders[i].authAddr,
                params.ringHash,
                params.vList[j],
                params.rList[j],
                params.sList[j]
            );
        }
    }
    function verifyTokensRegistered(
        RingParams params,
        OrderState[] orders
        )
        private
        view
    {
        // Extract the token addresses
        address[] memory tokens = new address[](params.ringSize);
        for (uint i = 0; i &lt; params.ringSize; i++) {
            tokens[i] = orders[i].tokenS;
        }
        // Test all token addresses at once
        require(
            TokenRegistry(tokenRegistryAddress).areAllTokensRegistered(tokens)
        ); // &quot;token not registered&quot;);
    }
    function handleRing(
        uint64       _ringIndex,
        RingParams   params,
        OrderState[] orders,
        TokenTransferDelegate delegate
        )
        private
    {
        address _lrcTokenAddress = lrcTokenAddress;
        // Do the hard work.
        verifyRingHasNoSubRing(params.ringSize, orders);
        // Exchange rates calculation are performed by ring-miners as solidity
        // cannot get power-of-1/n operation, therefore we have to verify
        // these rates are correct.
        verifyMinerSuppliedFillRates(params.ringSize, orders);
        // Scale down each order independently by substracting amount-filled and
        // amount-cancelled. Order owner&#39;s current balance and allowance are
        // not taken into consideration in these operations.
        scaleRingBasedOnHistoricalRecords(delegate, params.ringSize, orders);
        // Based on the already verified exchange rate provided by ring-miners,
        // we can furthur scale down orders based on token balance and allowance,
        // then find the smallest order of the ring, then calculate each order&#39;s
        // `fillAmountS`.
        calculateRingFillAmount(params.ringSize, orders);
        // Calculate each order&#39;s `lrcFee` and `lrcRewrard` and splict how much
        // of `fillAmountS` shall be paid to matching order or miner as margin
        // split.
        calculateRingFees(
            delegate,
            params.ringSize,
            orders,
            params.miner,
            _lrcTokenAddress
        );
        /// Make transfers.
        bytes32[] memory orderHashList;
        uint[6][] memory amountsList;
        (orderHashList, amountsList) = settleRing(
            delegate,
            params.ringSize,
            orders,
            params.miner,
            _lrcTokenAddress
        );
        emit RingMined(
            _ringIndex,
            params.ringHash,
            params.miner,
            orderHashList,
            amountsList
        );
    }
    function settleRing(
        TokenTransferDelegate delegate,
        uint          ringSize,
        OrderState[]  orders,
        address       miner,
        address       _lrcTokenAddress
        )
        private
        returns (
        bytes32[] memory orderHashList,
        uint[6][] memory amountsList)
    {
        bytes32[] memory batch = new bytes32[](ringSize * 7); // ringSize * (owner + tokenS + 4 amounts + wallet)
        orderHashList = new bytes32[](ringSize);
        amountsList = new uint[6][](ringSize);
        uint p = 0;
        for (uint i = 0; i &lt; ringSize; i++) {
            OrderState memory state = orders[i];
            uint prevSplitB = orders[(i + ringSize - 1) % ringSize].splitB;
            uint nextFillAmountS = orders[(i + 1) % ringSize].fillAmountS;
            // Store owner and tokenS of every order
            batch[p] = bytes32(state.owner);
            batch[p + 1] = bytes32(state.tokenS);
            // Store all amounts
            batch[p + 2] = bytes32(state.fillAmountS - prevSplitB);
            batch[p + 3] = bytes32(prevSplitB + state.splitS);
            batch[p + 4] = bytes32(state.lrcReward);
            batch[p + 5] = bytes32(state.lrcFeeState);
            batch[p + 6] = bytes32(state.wallet);
            p += 7;
            // Update fill records
            if (state.buyNoMoreThanAmountB) {
                delegate.addCancelledOrFilled(state.orderHash, nextFillAmountS);
            } else {
                delegate.addCancelledOrFilled(state.orderHash, state.fillAmountS);
            }
            orderHashList[i] = state.orderHash;
            amountsList[i][0] = state.fillAmountS + state.splitS;
            amountsList[i][1] = nextFillAmountS - state.splitB;
            amountsList[i][2] = state.lrcReward;
            amountsList[i][3] = state.lrcFeeState;
            amountsList[i][4] = state.splitS;
            amountsList[i][5] = state.splitB;
        }
        // Do all transactions
        delegate.batchTransferToken(
            _lrcTokenAddress,
            miner,
            walletSplitPercentage,
            batch
        );
    }
    /// @dev Verify miner has calculte the rates correctly.
    function verifyMinerSuppliedFillRates(
        uint         ringSize,
        OrderState[] orders
        )
        private
        view
    {
        uint[] memory rateRatios = new uint[](ringSize);
        uint _rateRatioScale = RATE_RATIO_SCALE;
        for (uint i = 0; i &lt; ringSize; i++) {
            uint s1b0 = orders[i].rateS.mul(orders[i].amountB);
            uint s0b1 = orders[i].amountS.mul(orders[i].rateB);
            require(s1b0 &lt;= s0b1); // &quot;miner supplied exchange rate provides invalid discount&quot;);
            rateRatios[i] = _rateRatioScale.mul(s1b0) / s0b1;
        }
        uint cvs = MathUint.cvsquare(rateRatios, _rateRatioScale);
        require(cvs &lt;= rateRatioCVSThreshold);
        // &quot;miner supplied exchange rate is not evenly discounted&quot;);
    }
    /// @dev Calculate each order&#39;s fee or LRC reward.
    function calculateRingFees(
        TokenTransferDelegate delegate,
        uint            ringSize,
        OrderState[]    orders,
        address         miner,
        address         _lrcTokenAddress
        )
        private
        view
    {
        bool checkedMinerLrcSpendable = false;
        uint minerLrcSpendable = 0;
        uint8 _marginSplitPercentageBase = MARGIN_SPLIT_PERCENTAGE_BASE;
        uint nextFillAmountS;
        for (uint i = 0; i &lt; ringSize; i++) {
            OrderState memory state = orders[i];
            uint lrcReceiable = 0;
            if (state.lrcFeeState == 0) {
                // When an order&#39;s LRC fee is 0 or smaller than the specified fee,
                // we help miner automatically select margin-split.
                state.marginSplitAsFee = true;
                state.marginSplitPercentage = _marginSplitPercentageBase;
            } else {
                uint lrcSpendable = getSpendable(
                    delegate,
                    _lrcTokenAddress,
                    state.owner
                );
                // If the order is selling LRC, we need to calculate how much LRC
                // is left that can be used as fee.
                if (state.tokenS == _lrcTokenAddress) {
                    lrcSpendable -= state.fillAmountS;
                }
                // If the order is buyign LRC, it will has more to pay as fee.
                if (state.tokenB == _lrcTokenAddress) {
                    nextFillAmountS = orders[(i + 1) % ringSize].fillAmountS;
                    lrcReceiable = nextFillAmountS;
                }
                uint lrcTotal = lrcSpendable + lrcReceiable;
                // If order doesn&#39;t have enough LRC, set margin split to 100%.
                if (lrcTotal &lt; state.lrcFeeState) {
                    state.lrcFeeState = lrcTotal;
                    state.marginSplitPercentage = _marginSplitPercentageBase;
                }
                if (state.lrcFeeState == 0) {
                    state.marginSplitAsFee = true;
                }
            }
            if (!state.marginSplitAsFee) {
                if (lrcReceiable &gt; 0) {
                    if (lrcReceiable &gt;= state.lrcFeeState) {
                        state.splitB = state.lrcFeeState;
                        state.lrcFeeState = 0;
                    } else {
                        state.splitB = lrcReceiable;
                        state.lrcFeeState -= lrcReceiable;
                    }
                }
            } else {
                // Only check the available miner balance when absolutely needed
                if (!checkedMinerLrcSpendable &amp;&amp; minerLrcSpendable &lt; state.lrcFeeState) {
                    checkedMinerLrcSpendable = true;
                    minerLrcSpendable = getSpendable(delegate, _lrcTokenAddress, miner);
                }
                // Only calculate split when miner has enough LRC;
                // otherwise all splits are 0.
                if (minerLrcSpendable &gt;= state.lrcFeeState) {
                    nextFillAmountS = orders[(i + 1) % ringSize].fillAmountS;
                    uint split;
                    if (state.buyNoMoreThanAmountB) {
                        split = (nextFillAmountS.mul(
                            state.amountS
                        ) / state.amountB).sub(
                            state.fillAmountS
                        );
                    } else {
                        split = nextFillAmountS.sub(
                            state.fillAmountS.mul(
                                state.amountB
                            ) / state.amountS
                        );
                    }
                    if (state.marginSplitPercentage != _marginSplitPercentageBase) {
                        split = split.mul(
                            state.marginSplitPercentage
                        ) / _marginSplitPercentageBase;
                    }
                    if (state.buyNoMoreThanAmountB) {
                        state.splitS = split;
                    } else {
                        state.splitB = split;
                    }
                    // This implicits order with smaller index in the ring will
                    // be paid LRC reward first, so the orders in the ring does
                    // mater.
                    if (split &gt; 0) {
                        minerLrcSpendable -= state.lrcFeeState;
                        state.lrcReward = state.lrcFeeState;
                    }
                }
                state.lrcFeeState = 0;
            }
        }
    }
    /// @dev Calculate each order&#39;s fill amount.
    function calculateRingFillAmount(
        uint          ringSize,
        OrderState[]  orders
        )
        private
        pure
    {
        uint smallestIdx = 0;
        uint i;
        uint j;
        for (i = 0; i &lt; ringSize; i++) {
            j = (i + 1) % ringSize;
            smallestIdx = calculateOrderFillAmount(
                orders[i],
                orders[j],
                i,
                j,
                smallestIdx
            );
        }
        for (i = 0; i &lt; smallestIdx; i++) {
            calculateOrderFillAmount(
                orders[i],
                orders[(i + 1) % ringSize],
                0,               // Not needed
                0,               // Not needed
                0                // Not needed
            );
        }
    }
    /// @return The smallest order&#39;s index.
    function calculateOrderFillAmount(
        OrderState state,
        OrderState next,
        uint       i,
        uint       j,
        uint       smallestIdx
        )
        private
        pure
        returns (uint newSmallestIdx)
    {
        // Default to the same smallest index
        newSmallestIdx = smallestIdx;
        uint fillAmountB = state.fillAmountS.mul(
            state.rateB
        ) / state.rateS;
        if (state.buyNoMoreThanAmountB) {
            if (fillAmountB &gt; state.amountB) {
                fillAmountB = state.amountB;
                state.fillAmountS = fillAmountB.mul(
                    state.rateS
                ) / state.rateB;
                newSmallestIdx = i;
            }
            state.lrcFeeState = state.lrcFee.mul(
                fillAmountB
            ) / state.amountB;
        } else {
            state.lrcFeeState = state.lrcFee.mul(
                state.fillAmountS
            ) / state.amountS;
        }
        if (fillAmountB &lt;= next.fillAmountS) {
            next.fillAmountS = fillAmountB;
        } else {
            newSmallestIdx = j;
        }
    }
    /// @dev Scale down all orders based on historical fill or cancellation
    ///      stats but key the order&#39;s original exchange rate.
    function scaleRingBasedOnHistoricalRecords(
        TokenTransferDelegate delegate,
        uint ringSize,
        OrderState[] orders
        )
        private
        view
    {
        for (uint i = 0; i &lt; ringSize; i++) {
            OrderState memory state = orders[i];
            uint amount;
            if (state.buyNoMoreThanAmountB) {
                amount = state.amountB.tolerantSub(
                    delegate.cancelledOrFilled(state.orderHash)
                );
                state.amountS = amount.mul(state.amountS) / state.amountB;
                state.lrcFee = amount.mul(state.lrcFee) / state.amountB;
                state.amountB = amount;
            } else {
                amount = state.amountS.tolerantSub(
                    delegate.cancelledOrFilled(state.orderHash)
                );
                state.amountB = amount.mul(state.amountB) / state.amountS;
                state.lrcFee = amount.mul(state.lrcFee) / state.amountS;
                state.amountS = amount;
            }
            require(state.amountS &gt; 0); // &quot;amountS is zero&quot;);
            require(state.amountB &gt; 0); // &quot;amountB is zero&quot;);
            uint availableAmountS = getSpendable(delegate, state.tokenS, state.owner);
            require(availableAmountS &gt; 0); // &quot;order spendable amountS is zero&quot;);
            state.fillAmountS = (
                state.amountS &lt; availableAmountS ?
                state.amountS : availableAmountS
            );
        }
    }
    /// @return Amount of ERC20 token that can be spent by this contract.
    function getSpendable(
        TokenTransferDelegate delegate,
        address tokenAddress,
        address tokenOwner
        )
        private
        view
        returns (uint)
    {
        ERC20 token = ERC20(tokenAddress);
        uint allowance = token.allowance(
            tokenOwner,
            address(delegate)
        );
        uint balance = token.balanceOf(tokenOwner);
        return (allowance &lt; balance ? allowance : balance);
    }
    /// @dev verify input data&#39;s basic integrity.
    function verifyInputDataIntegrity(
        RingParams params,
        address[4][]  addressList,
        uint[6][]     uintArgsList,
        uint8[1][]    uint8ArgsList,
        bool[]        buyNoMoreThanAmountBList
        )
        private
        pure
    {
        require(params.miner != 0x0);
        require(params.ringSize == addressList.length);
        require(params.ringSize == uintArgsList.length);
        require(params.ringSize == uint8ArgsList.length);
        require(params.ringSize == buyNoMoreThanAmountBList.length);
        // Validate ring-mining related arguments.
        for (uint i = 0; i &lt; params.ringSize; i++) {
            require(uintArgsList[i][5] &gt; 0); // &quot;order rateAmountS is zero&quot;);
        }
        //Check ring size
        require(params.ringSize &gt; 1 &amp;&amp; params.ringSize &lt;= MAX_RING_SIZE); // &quot;invalid ring size&quot;);
        uint sigSize = params.ringSize &lt;&lt; 1;
        require(sigSize == params.vList.length);
        require(sigSize == params.rList.length);
        require(sigSize == params.sList.length);
    }
    /// @dev        assmble order parameters into Order struct.
    /// @return     A list of orders.
    function assembleOrders(
        RingParams params,
        TokenTransferDelegate delegate,
        address[4][]  addressList,
        uint[6][]     uintArgsList,
        uint8[1][]    uint8ArgsList,
        bool[]        buyNoMoreThanAmountBList
        )
        private
        view
        returns (OrderState[] memory orders)
    {
        orders = new OrderState[](params.ringSize);
        for (uint i = 0; i &lt; params.ringSize; i++) {
            bool marginSplitAsFee = (params.feeSelections &amp; (uint16(1) &lt;&lt; i)) &gt; 0;
            orders[i] = OrderState(
                addressList[i][0],
                addressList[i][1],
                addressList[(i + 1) % params.ringSize][1],
                addressList[i][2],
                addressList[i][3],
                uintArgsList[i][2],
                uintArgsList[i][3],
                uintArgsList[i][0],
                uintArgsList[i][1],
                uintArgsList[i][4],
                buyNoMoreThanAmountBList[i],
                marginSplitAsFee,
                bytes32(0),
                uint8ArgsList[i][0],
                uintArgsList[i][5],
                uintArgsList[i][1],
                0,   // fillAmountS
                0,   // lrcReward
                0,   // lrcFee
                0,   // splitS
                0    // splitB
            );
            validateOrder(orders[i]);
            bytes32 orderHash = calculateOrderHash(orders[i]);
            orders[i].orderHash = orderHash;
            verifySignature(
                orders[i].owner,
                orderHash,
                params.vList[i],
                params.rList[i],
                params.sList[i]
            );
            params.ringHash ^= orderHash;
        }
        validateOrdersCutoffs(orders, delegate);
        params.ringHash = keccak256(
            params.ringHash,
            params.miner,
            params.feeSelections
        );
    }
    /// @dev validate order&#39;s parameters are OK.
    function validateOrder(
        OrderState order
        )
        private
        view
    {
        require(order.owner != 0x0); // invalid order owner
        require(order.tokenS != 0x0); // invalid order tokenS
        require(order.tokenB != 0x0); // invalid order tokenB
        require(order.amountS != 0); // invalid order amountS
        require(order.amountB != 0); // invalid order amountB
        require(order.marginSplitPercentage &lt;= MARGIN_SPLIT_PERCENTAGE_BASE);
        // invalid order marginSplitPercentage
        require(order.validSince &lt;= block.timestamp); // order is too early to match
        require(order.validUntil &gt; block.timestamp); // order is expired
    }
    function validateOrdersCutoffs(OrderState[] orders, TokenTransferDelegate delegate)
        private
        view
    {
        address[] memory owners = new address[](orders.length);
        bytes20[] memory tradingPairs = new bytes20[](orders.length);
        uint[] memory validSinceTimes = new uint[](orders.length);
        for (uint i = 0; i &lt; orders.length; i++) {
            owners[i] = orders[i].owner;
            tradingPairs[i] = bytes20(orders[i].tokenS) ^ bytes20(orders[i].tokenB);
            validSinceTimes[i] = orders[i].validSince;
        }
        delegate.checkCutoffsBatch(owners, tradingPairs, validSinceTimes);
    }
    /// @dev Get the Keccak-256 hash of order with specified parameters.
    function calculateOrderHash(
        OrderState order
        )
        private
        pure
        returns (bytes32)
    {
        return keccak256(
            delegateAddress,
            order.owner,
            order.tokenS,
            order.tokenB,
            order.wallet,
            order.authAddr,
            order.amountS,
            order.amountB,
            order.validSince,
            order.validUntil,
            order.lrcFee,
            order.buyNoMoreThanAmountB,
            order.marginSplitPercentage
        );
    }
    /// @dev Verify signer&#39;s signature.
    function verifySignature(
        address signer,
        bytes32 hash,
        uint8   v,
        bytes32 r,
        bytes32 s
        )
        private
        pure
    {
        require(
            signer == ecrecover(
                keccak256(&quot;\x19Ethereum Signed Message:\n32&quot;, hash),
                v,
                r,
                s
            )
        ); // &quot;invalid signature&quot;);
    }
    function getTradingPairCutoffs(
        address orderOwner,
        address token1,
        address token2
        )
        public
        view
        returns (uint)
    {
        bytes20 tokenPair = bytes20(token1) ^ bytes20(token2);
        TokenTransferDelegate delegate = TokenTransferDelegate(delegateAddress);
        return delegate.tradingPairCutoffs(orderOwner, tokenPair);
    }
}