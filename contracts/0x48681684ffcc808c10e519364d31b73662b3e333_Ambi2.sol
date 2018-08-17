// This software is a subject to Ambisafe License Agreement.
// No use or distribution is allowed without written permission from Ambisafe.
// https://www.ambisafe.com/terms-of-use/

pragma solidity ^0.4.8;

contract Ambi2 {
    bytes32 constant OWNER = &quot;__root__&quot;;
    uint constant LIFETIME = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    mapping(bytes32 =&gt; uint) rolesExpiration;
    mapping(address =&gt; bool) nodes;

    event Assign(address indexed from, bytes32 indexed role, address indexed to, uint expirationDate);
    event Unassign(address indexed from, bytes32 indexed role, address indexed to);
    event Error(bytes32 message);

    modifier onlyNodeOwner(address _node) {
        if (isOwner(_node, msg.sender)) {
            _;
        } else {
            _error(&quot;Access denied: only node owner&quot;);
        }
    }

    function claimFor(address _address, address _owner) returns(bool) {
        if (nodes[_address]) {
            _error(&quot;Access denied: already owned&quot;);
            return false;
        }
        nodes[_address] = true;
        _assignRole(_address, OWNER, _owner, LIFETIME);
        return true;
    }

    function claim(address _address) returns(bool) {
        return claimFor(_address, msg.sender);
    }

    function assignOwner(address _node, address _owner) returns(bool) {
        return assignRole(_node, OWNER, _owner);
    }

    function assignRole(address _from, bytes32 _role, address _to) returns(bool) {
        return assignRoleWithExpiration(_from, _role, _to, LIFETIME);
    }

    function assignRoleWithExpiration(address _from, bytes32 _role, address _to, uint _expirationDate) onlyNodeOwner(_from) returns(bool) {
        if (hasRole(_from, _role, _to) &amp;&amp; rolesExpiration[_getRoleSignature(_from, _role, _to)] == _expirationDate) {
            _error(&quot;Role already assigned&quot;);
            return false;
        }
        if (_isPast(_expirationDate)) {
            _error(&quot;Invalid expiration date&quot;);
            return false;
        }

        _assignRole(_from, _role, _to, _expirationDate);
        return true;
    }

    function _assignRole(address _from, bytes32 _role, address _to, uint _expirationDate) internal {
        rolesExpiration[_getRoleSignature(_from, _role, _to)] = _expirationDate;
        Assign(_from, _role, _to, _expirationDate);
    }

    function unassignOwner(address _node, address _owner) returns(bool) {
        if (_owner == msg.sender) {
            _error(&quot;Cannot remove ownership&quot;);
            return false;
        }

        return unassignRole(_node, OWNER, _owner);
    }

    function unassignRole(address _from, bytes32 _role, address _to) onlyNodeOwner(_from) returns(bool) {
        if (!hasRole(_from, _role, _to)) {
            _error(&quot;Role not assigned&quot;);
            return false;
        }

        delete rolesExpiration[_getRoleSignature(_from, _role, _to)];
        Unassign(_from, _role, _to);
        return true;
    }

    function hasRole(address _from, bytes32 _role, address _to) constant returns(bool) {
        return _isFuture(rolesExpiration[_getRoleSignature(_from, _role, _to)]);
    }

    function isOwner(address _node, address _owner) constant returns(bool) {
        return hasRole(_node, OWNER, _owner);
    }

    function _error(bytes32 _message) internal {
        Error(_message);
    }

    function _getRoleSignature(address _from, bytes32 _role, address _to) internal constant returns(bytes32) {
        return sha3(_from, _role, _to);
    }

    function _isPast(uint _timestamp) internal constant returns(bool) {
        return _timestamp &lt; now;
    }

    function _isFuture(uint _timestamp) internal constant returns(bool) {
        return !_isPast(_timestamp);
    }
}