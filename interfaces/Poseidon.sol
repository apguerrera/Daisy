pragma solidity ^0.5.0;


interface PoseidonT3 {
    function poseidon(uint256[] calldata input) external pure returns (uint256);
}


interface PoseidonT6 {
    function poseidon(uint256[] calldata input) external pure returns (uint256);
}
