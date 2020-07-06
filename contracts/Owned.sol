pragma solidity ^0.5.16;

// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address payable public owner;
    address public newOwner;
    bool private initialised;

     event OwnershipTransferred(address indexed from, address indexed to);

    function initOwned(address  _owner) internal {
        require(!initialised);
        owner = address(uint160(_owner));
        initialised = true;
    }
    function transferOwnership(address _newOwner) public {
        require(msg.sender == owner);
        newOwner = _newOwner;
    }
    function acceptOwnership()  public  {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = address(uint160(newOwner));
        newOwner = address(0);
    }
    function transferOwnershipImmediately(address _newOwner) public {
        require(msg.sender == owner);
        emit OwnershipTransferred(owner, _newOwner);
        owner = address(uint160(_newOwner));
    }
}
