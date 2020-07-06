
pragma experimental ABIEncoderV2;
pragma solidity ^0.5.16;

import "./Maker/DSChief.sol";
import "./Maci/MiniMACI.sol";
import {MACISharedObjs} from "./Maci/MACISharedObjs.sol";
import "./DaisyGatekeeper.sol";


contract Daisy is MACISharedObjs {

    DSToken public gov;
    DSToken public iou;
    DSChief public chief;
    MiniMACI public maci;
    DaisyGatekeeper public gatekeeper;

    /// @dev set both the DSChief tokens and MACI voting contracts
    constructor(DSChief _chief, MiniMACI _maci, DaisyGatekeeper _gatekeeper) public {
        chief = _chief;
        maci = _maci;
        gatekeeper = _gatekeeper;
        gov = chief.GOV();
        iou = chief.IOU();
        gov.approve(address(chief), uint256(-1));
        iou.approve(address(chief), uint256(-1));
    }

// ----------------------------------------------------------------------------
// User Functions
// ----------------------------------------------------------------------------

    /// @dev Add user to members list and state tree then lock MKR tokens
    function signUp(uint256 wad, PubKey memory _key) public {
        maci.signUp(_key,"","");
        _lock(wad);
    }


    /// @dev Release voting tokens and exit the private voting contract
    function withdraw(uint256 wad) public {
        _free(wad);
        /// @dev Need to removal state leaf from the IncrementalMerkleTree 
        /// @dev Leave membership to prevent vote reenterancy
        // _removeMember(address(msg.sender));
    }

// ----------------------------------------------------------------------------
// User Publishing Messages:
// Voting + Change Pin
// ----------------------------------------------------------------------------

    /// @dev Messages are encrypted and used for both voting or to change your pin
    function publishMessage(Message memory _message,
        PubKey memory _encPubKey
        ) public {
        require(gatekeeper.isInMemberList(msg.sender));
        require(iou.balanceOf(msg.sender) > 0 );
        maci.publishMessage(_message,_encPubKey);
    }


// ----------------------------------------------------------------------------
// Coordinator Proofs
// ----------------------------------------------------------------------------

    /// @dev Coordinator counts votes within messages, with batch proofs
    function batchProcessMessage(
        uint256 _newStateRoot,
        uint256[] memory _stateTreeRoots,
        PubKey[] memory _ecdhPubKeys,
        uint256[8] memory _proof
    )   public {
        maci.batchProcessMessage(_newStateRoot,_stateTreeRoots,_ecdhPubKeys, _proof);
    }

    /// @dev Tally the final vote and submit proof of correctness
    function proveVoteTallyBatch(
        uint256 _intermediateStateRoot,
        uint256 _newResultsCommitment,
        uint256 _newSpentVoiceCreditsCommitment,
        uint256 _newPerVOSpentVoiceCreditsCommitment,
        uint256[8] memory _proof
    ) public {
        maci.proveVoteTallyBatch(
                _intermediateStateRoot,
                _newResultsCommitment,
                _newSpentVoiceCreditsCommitment,
                _newPerVOSpentVoiceCreditsCommitment,
                _proof);
    }

    /// @dev check total number votes cast for a specific salt
    function verifySpentVoiceCredits(
        uint256 _spent,
        uint256 _salt
    ) public view returns (bool) {
        return maci.verifySpentVoiceCredits(_spent, _salt);
    }


    /// @dev Once the private voting window has finished, coordinator submits yays
    function coordintorSubmit(
        uint8 _depth,
        uint256 _index,
        uint256 _leaf,
        uint256[][] memory _pathElements,
        uint256 _salt,
        address[] memory yays
    ) public returns (bytes32) {

        require(maci.verifyTallyResult(_depth,_index, _leaf, _pathElements,_salt));
        return chief.vote(yays);
    }


// ----------------------------------------------------------------------------
// Internal functions
// ----------------------------------------------------------------------------

    /// @dev Lock MKR tokens and issue IOU tokens for users to claim 
    function _lock(uint256 wad) internal {
        gatekeeper.isInMemberList(msg.sender);
        gov.pull(msg.sender, wad);   // mkr from user
        // add to maci state tree
        chief.lock(wad);       // mkr out, ious in
        iou.push(msg.sender, wad);   // iou to user
    }

    /// @dev Release MKR tokens from private voting contract
    function _free(uint256 wad) internal {
        gatekeeper.isInMemberList(msg.sender);
        iou.pull(msg.sender, wad);   // iou from user
        // remove from maci state tree
        chief.free(wad);       // ious out, mkr in
        gov.push(msg.sender, wad);   // mkr to user
    }

}