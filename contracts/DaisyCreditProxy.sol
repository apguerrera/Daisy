pragma solidity ^0.5.0;

import "./Maker/DSChief.sol";
import "./Maci/InitialVoiceCreditProxy.sol";

contract DaisyCreditProxy is InitialVoiceCreditProxy {

    DSToken public gov;
    DSToken public iou;
    DSChief public chief;

    /// @dev set both the DSChief tokens and MACI voting contracts
    constructor(DSChief _chief) public {
        chief = _chief;
        gov = chief.GOV();
        iou = chief.IOU();
    }

    /// @dev Voting weights are done based on number ot tokens deposited.
    function getVoiceCredits(address _user, bytes memory _data)
        public view returns (uint256)
    {
        return iou.balanceOf(msg.sender);
    }

}
