pragma solidity ^0.5.0;

import "./Members.sol";

contract DaisyGatekeeper is Members {
    address public operator; 
    bool initialised;

    function initGatekeeper (address _maci) public {
        require(!initialised);
        initialised = true;
        operator = _maci;

    }

    function register(address _user, bytes memory _data) public {
        require(operator == msg.sender);
        require(!isInMemberList(_user));
        _addMember(address(_user));
        require(isInMemberList(_user));
    }

    function unregister(address _user, bytes memory _data) public {
        require(operator == msg.sender);
        require(isInMemberList(_user));
        _removeMember(address(_user));
        require(!isInMemberList(_user));
    }
}
