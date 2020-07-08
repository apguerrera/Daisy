/*
 * Hasher object to abstract out hashing logic
 * to be shared between multiple files
 *
 * This file is part of maci
 */

pragma solidity ^0.5.0;

import {PoseidonT3, PoseidonT6} from "../../interfaces/Poseidon.sol";

import {SnarkConstants} from "./SnarkConstants.sol";


contract Hasher is SnarkConstants {
    PoseidonT3 public poseidon3;
    PoseidonT6 public poseidon6;

    function setPoseidon3(PoseidonT3 _poseidon3) public {
        poseidon3 = _poseidon3;
    }
    function setPoseidon6(PoseidonT6 _poseidon6) public {
        poseidon6 = _poseidon6;
    }

    function hash5(uint256[] memory array) public view returns (uint256) {
        return poseidon6.poseidon(array);
    }

    function hash11(uint256[] memory array) public view returns (uint256) {
        uint256[] memory input11 = new uint256[](11);
        uint256[] memory first5 = new uint256[](5);
        uint256[] memory second5 = new uint256[](5);
        for (uint256 i = 0; i < array.length; i++) {
            input11[i] = array[i];
        }

        for (uint256 i = array.length; i < 11; i++) {
            input11[i] = 0;
        }

        for (uint256 i = 0; i < 5; i++) {
            first5[i] = input11[i];
            second5[i] = input11[i + 5];
        }

        uint256[] memory first2 = new uint256[](2);
        first2[0] = poseidon6.poseidon(first5);
        first2[1] = poseidon6.poseidon(second5);
        uint256[] memory second2 = new uint256[](2);
        second2[0] = poseidon3.poseidon(first2);
        second2[1] = input11[10];
        return poseidon3.poseidon(second2);
    }

    function hashLeftRight(uint256 _left, uint256 _right)
        public
        view
        returns (uint256)
    {
        uint256[] memory input = new uint256[](2);
        input[0] = _left;
        input[1] = _right;
        return poseidon3.poseidon(input);
    }
}
