
pragma experimental ABIEncoderV2;
pragma solidity ^0.5.16;

import "./Maker/DSChief.sol";
import "./Members.sol";
import "./Maci/MiniMACI.sol";
import {MACISharedObjs} from "./Maci/MACISharedObjs.sol";


contract Daisy is Members, MACISharedObjs {

    DSToken public gov;
    DSToken public iou;
    DSChief public chief;
    MiniMACI public maci;

    constructor(DSChief _chief, MiniMACI _maci) public {
        chief = _chief;
        maci = _maci;
        gov = chief.GOV();
        iou = chief.IOU();
        gov.approve(address(chief), uint256(-1));
        iou.approve(address(chief), uint256(-1));
    }

    function publishMessage(Message memory _message,
        PubKey memory _encPubKey
        ) public {
        require(isInMemberList(msg.sender));
        maci.publishMessage(_message,_encPubKey);
    }

    function coordintorSubmit(address[] memory yays) internal returns (bytes32) {
        // require(verifyTallyResult(_depth,_index, _leaf, _pathElements,_salt));
        return chief.vote(yays);
    }

    function register(uint256 wad, PubKey memory _key) public {
        _addMember(address(msg.sender));
        maci.signUp(_key,"");
        _lock(wad);
    }

    function unregister(uint256 wad) public {
        _free(wad);
        _removeMember(address(msg.sender));
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