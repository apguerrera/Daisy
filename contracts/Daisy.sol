

pragma solidity ^0.5.16;

import "./Maker/DSChief.sol";
import "./Members.sol";


contract Daisy is Members {

    DSToken public gov;
    DSToken public iou;
    DSChief public chief;

    constructor(DSChief _chief) public {
        chief = _chief;

        gov = chief.GOV();
        iou = chief.IOU();
        gov.approve(address(chief), uint256(-1));
        iou.approve(address(chief), uint256(-1));
    }

    function memberVote() public {
        require(isInMemberList(msg.sender));
    }

    function coordintorSubmit(address[] memory yays) internal returns (bytes32) {
        // zero knowledge proof for result
        return chief.vote(yays);
    }

    function lock(uint256 wad) public {
        isInMemberList(msg.sender);
        gov.pull(msg.sender, wad);   // mkr from cold
        chief.lock(wad);       // mkr out, ious in
        gov.push(msg.sender, wad);   // mkr to cold

    }

    function free(uint256 wad) public {
        isInMemberList(msg.sender);
        chief.free(wad);       // ious out, mkr in
        gov.push(msg.sender, wad);   // mkr to cold
    }


    function signUp (address[] memory account) public {
        // add MKR to be locked up
        // send IOU to holder
        _addMembers(account);
    }
}