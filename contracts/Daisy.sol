

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

    function signUp (uint256 wad) public {
        _addMember(address(msg.sender));
        _lock(wad);
    }

    function withdraw(uint256 wad) public {
        _removeMember(address(msg.sender));
        _free(wad);
    }

    function _lock(uint256 wad) internal {
        isInMemberList(msg.sender);
        gov.pull(msg.sender, wad);   // mkr from user
        // add to maci state tree
        chief.lock(wad);       // mkr out, ious in
        iou.push(msg.sender, wad);   // iou to user
    }

    function _free(uint256 wad) internal {
        isInMemberList(msg.sender);
        iou.pull(msg.sender, wad);   // iou from user
        // remove from maci state tree
        chief.free(wad);       // ious out, mkr in
        gov.push(msg.sender, wad);   // mkr to user
    }


}