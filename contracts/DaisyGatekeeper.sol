pragma solidity ^0.5.0;

import "./Members.sol";
import "./Operated.sol";

contract DaisyGatekeeper is Operated, Members {

    function register(address _user, bytes memory _data) public {
        require(operators[msg.sender]);
        require(!isInMemberList(_user));
        _addMember(address(_user));
        require(isInMemberList(_user));
    }

    function unregister(address _user, bytes memory _data) public {
        require(operators[msg.sender]);
        require(isInMemberList(_user));
        _removeMember(address(_user));
        require(!isInMemberList(_user));
    }
}
