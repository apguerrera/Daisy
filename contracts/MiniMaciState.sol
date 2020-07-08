pragma experimental ABIEncoderV2;
pragma solidity ^0.5.0;

import { SignUpGatekeeper } from "./Maci/SignUpGatekeeper.sol";
import { InitialVoiceCreditProxy } from './Maci/InitialVoiceCreditProxy.sol';

import { IncrementalMerkleTree } from "./Maci/IncrementalMerkleTree.sol"; 
import { DomainObjs } from './Maci/DomainObjs.sol'; 
import { SnarkConstants } from './Maci/SnarkConstants.sol'; 
import { ComputeRoot } from './Maci/ComputeRoot.sol'; 
import { MACIParameters } from './Maci/MACIParameters.sol'; 
import { Ownable } from "@openzeppelin/contracts/ownership/Ownable.sol";
import '../../interfaces/Poseidon.sol'; 

contract MiniMaciState is Ownable, DomainObjs, ComputeRoot, MACIParameters {

    // The tree that tracks each user's public key and votes
    IncrementalMerkleTree public stateTree;

    // The Merkle root of the state tree after the sign-up period.
    // publishMessage() will not update the state tree. Rather, it will
    // directly update postSignUpStateRoot if given a valid proof and public
    // signals.
    uint256 public postSignUpStateRoot;

    // To store the Merkle root of a tree with 5 **
    // _treeDepths.voteOptionTreeDepth leaves of value 0
    uint256 public emptyVoteOptionTreeRoot;

    // The maximum number of leaves, minus one, of meaningful vote options.
    uint256 public voteOptionsMaxLeafIndex;

    // The maximum number of signups allowed
    uint256 public maxUsers;


    // Address of the SignUpGatekeeper, a contract which determines whether a
    // user may sign up to vote
    SignUpGatekeeper public signUpGatekeeper;

    // The contract which provides the values of the initial voice credit
    // balance per user
    InitialVoiceCreditProxy public initialVoiceCreditProxy;

    // The coordinator's public key
    PubKey public coordinatorPubKey;

    uint256 public numSignUps;

    TreeDepths public treeDepths;

    // Events
    event SignUp(
        PubKey indexed _userPubKey,
        uint256 indexed _stateIndex,
        uint256 indexed _voiceCreditBalance
    );


    constructor(
        TreeDepths memory _treeDepths,
        MaxValues memory _maxValues,
        SignUpGatekeeper _signUpGatekeeper,
        InitialVoiceCreditProxy _initialVoiceCreditProxy,
        PubKey memory _coordinatorPubKey,
        PoseidonT3 _poseidon3
    ) Ownable() public {

        treeDepths = _treeDepths;
        numSignUps = 0;
        // Set the sign-up gatekeeper contract
        signUpGatekeeper = _signUpGatekeeper;
        
        // Set the initial voice credit balance proxy
        initialVoiceCreditProxy = _initialVoiceCreditProxy;

        // Check and store the maximum number of signups
        // It is the user's responsibility to ensure that the state tree depth
        // is just large enough and not more, or they will waste gas.
        uint256 stateTreeMaxLeafIndex = uint256(2) ** _treeDepths.stateTreeDepth - 1;
        require(_maxValues.maxUsers <= stateTreeMaxLeafIndex, "MACI: invalid maxUsers value");
        maxUsers = _maxValues.maxUsers;


        // Calculate and store the empty vote option tree root. This value must
        // be set before we call hashedBlankStateLeaf() later
        emptyVoteOptionTreeRoot = calcEmptyVoteOptionTreeRoot(_treeDepths.voteOptionTreeDepth);


        // Compute the hash of a blank state leaf
        uint256 h = hashedBlankStateLeaf();

        // Create the state tree
        stateTree = new IncrementalMerkleTree(_treeDepths.stateTreeDepth, h, _poseidon3);

        // Make subsequent insertions start from leaf #1, as leaf #0 is only
        // updated with random data if a command is invalid.
        stateTree.insertLeaf(h);
    }



    /*
     * Allows a user who is eligible to sign up to do so. The sign-up
     * gatekeeper will prevent double sign-ups or ineligible users from signing
     * up. This function will only succeed if the sign-up deadline has not
     * passed. It also inserts a fresh state leaf into the state tree.
     * @param _userPubKey The user's desired public key.
     * @param _signUpGatekeeperData Data to pass to the sign-up gatekeeper's
     *     register() function. For instance, the POAPGatekeeper or
     *     SignUpTokenGatekeeper requires this value to be the ABI-encoded
     *     token ID.
     */

    function signUp(
        uint256 _x,
        uint256 _y,
        bytes memory _signUpGatekeeperData, 
        bytes memory _initialVoiceCreditProxyData
    ) 
    public {
        PubKey memory userPubKey = PubKey({x:_x,y:_y});
        signUp(userPubKey, _signUpGatekeeperData,_initialVoiceCreditProxyData);
    }

    function signUp(
        PubKey memory _userPubKey,
        bytes memory _signUpGatekeeperData, 
        bytes memory _initialVoiceCreditProxyData
    ) 
    public {

        require(numSignUps < maxUsers, "MACI: maximum number of signups reached");

        // Register the user via the sign-up gatekeeper. This function should
        // throw if the user has already registered or if ineligible to do so.
        signUpGatekeeper.register(msg.sender, _signUpGatekeeperData);

        uint256 voiceCreditBalance = initialVoiceCreditProxy.getVoiceCredits(
            msg.sender,
            _initialVoiceCreditProxyData
        );


        // Create, hash, and insert a fresh state leaf
        StateLeaf memory stateLeaf = StateLeaf({
            pubKey: _userPubKey,
            voteOptionTreeRoot: emptyVoteOptionTreeRoot,
            voiceCreditBalance: voiceCreditBalance,
            nonce: 0
        });

        uint256 hashedLeaf = hashStateLeaf(stateLeaf);

        stateTree.insertLeaf(hashedLeaf);

        numSignUps ++;

        // numSignUps is equal to the state index of the leaf which was just
        // added to the state tree above
        emit SignUp(_userPubKey, numSignUps, voiceCreditBalance);
    }

    
    function hashedBlankStateLeaf() public view returns (uint256) {
        StateLeaf memory stateLeaf = StateLeaf({
            pubKey: PubKey({
                x: 0,
                y: 0
            }),
            voteOptionTreeRoot: emptyVoteOptionTreeRoot,
            voiceCreditBalance: 0,
            nonce: 0
        });

        return hashStateLeaf(stateLeaf);
    }

    function calcEmptyVoteOptionTreeRoot(uint8 _levels) public view returns (uint256) {
        return computeEmptyQuinRoot(_levels, 0);
    }


    function getStateTreeRoot() public view returns (uint256) {
        return stateTree.root();
    }
}
