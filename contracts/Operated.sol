pragma solidity ^0.5.16;

import "./Owned.sol";


// ----------------------------------------------------------------------------
// Maintain a list of operators that are permissioned to execute certain
// functions
// ----------------------------------------------------------------------------
contract Operated is Owned {
    mapping(address => bool) public operators;

    event OperatorAdded(address _operator);
    event OperatorRemoved(address _operator);

    modifier onlyOperator() {
        require(operators[msg.sender] || owner == msg.sender);
        _;
    }

    function initOperated(address _owner) internal {
        initOwned(_owner);
    }
    function addOperator(address _operator) public  {
        require(msg.sender == owner);
        require(!operators[_operator]);
        operators[_operator] = true;
        emit OperatorAdded(_operator);
    }
    function removeOperator(address _operator) public  {
        require(msg.sender == owner);
        require(operators[_operator]);
        delete operators[_operator];
        emit OperatorRemoved(_operator);
    }
}
