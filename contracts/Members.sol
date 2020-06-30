pragma solidity ^0.5.16;

// ----------------------------------------------------------------------------
// BokkyPooBah's Member List
// (c) BokkyPooBah / Bok Consulting Pty Ltd. The MIT Licence.
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// Members - on list or not
// ----------------------------------------------------------------------------
contract Members {
    
    mapping(address => bool) public members;

    event MemberListed(address indexed account, bool status);


    function isInMemberList(address account) public view  returns (bool) {
        return members[account];
    }


    function _addMembers(address[] memory accounts) internal {  
        require(accounts.length != 0);
        for (uint i = 0; i < accounts.length; i++) {
            require(accounts[i] != address(0));
            if (!members[accounts[i]]) {
                members[accounts[i]] = true;
                emit MemberListed(accounts[i], true);
            }
        }
    }
    function _removeMembers(address[] memory accounts) internal  {
        require(accounts.length != 0);
        for (uint i = 0; i < accounts.length; i++) {
            require(accounts[i] != address(0));
            if (members[accounts[i]]) {
                delete members[accounts[i]];
                emit MemberListed(accounts[i], false);
            }
        }
    }
}


