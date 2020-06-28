pragma solidity ^0.5.16;

import "./DSChief.sol";

contract DSChiefFab {
    function newChief(DSToken gov, uint MAX_YAYS) public returns (DSChief chief) {
        DSToken iou = new DSToken('IOU');
        chief = new DSChief(gov, iou, MAX_YAYS);
        iou.setOwner(address(chief));
    }
}
