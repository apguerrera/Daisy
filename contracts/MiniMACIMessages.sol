pragma experimental ABIEncoderV2;
pragma solidity ^0.5.0;


import { SignUpGatekeeper } from "./Maci/SignUpGatekeeper.sol";
import { BatchUpdateStateTreeVerifier } from "./Maci/BatchUpdateStateTreeVerifier.sol";
import { QuadVoteTallyVerifier } from "./Maci/QuadVoteTallyVerifier.sol";
import { InitialVoiceCreditProxy } from './Maci/InitialVoiceCreditProxy.sol';

import { IncrementalMerkleTree } from "./Maci/IncrementalMerkleTree.sol"; 
import { DomainObjs } from './Maci/DomainObjs.sol'; 
import { SnarkConstants } from './Maci/SnarkConstants.sol'; 
import { ComputeRoot } from './Maci/ComputeRoot.sol'; 
import { MACIParameters } from './Maci/MACIParameters.sol'; 
import { VerifyTally } from './Maci/VerifyTally.sol'; 
import { Ownable } from "@openzeppelin/contracts/ownership/Ownable.sol";
import { MiniMaciState } from "./MiniMaciState.sol";

contract MiniMACIMessage is Ownable, DomainObjs, ComputeRoot, MACIParameters, VerifyTally {

    // A nothing-up-my-sleeve zero value
    // Should be equal to 5503045433092194285660061905880311622788666850989422096966288514930349325741
    uint256 ZERO_VALUE = uint256(keccak256(abi.encodePacked('Maci'))) % SNARK_SCALAR_FIELD;

    // Verifier Contracts
    BatchUpdateStateTreeVerifier internal batchUstVerifier;
    QuadVoteTallyVerifier internal qvtVerifier;

    // The number of messages which the batch update state tree snark can
    // process per batch
    uint8 public messageBatchSize;

    // The number of state leaves to tally per batch via the vote tally snark
    uint8 public tallyBatchSize;

    // The current message batch index
    uint256 public currentMessageBatchIndex;

    // The tree that tracks the sign-up messages.
    IncrementalMerkleTree public messageTree;

    // The tree that tracks each user's public key and votes
    MiniMaciState public maciState;
    // The Merkle root of the state tree after the sign-up period.
    // publishMessage() will not update the state tree. Rather, it will
    // directly update postSignUpStateRoot if given a valid proof and public
    // signals.
    uint256 public postSignUpStateRoot;

    uint256 public stateRoot;
    // To store the Merkle root of a tree with 5 **
    // _treeDepths.voteOptionTreeDepth leaves of value 0
    uint256 public emptyVoteOptionTreeRoot;

    // To store hashLeftRight(Merkle root of 5 ** voteOptionTreeDepth zeros, 0)
    uint256 public currentResultsCommitment;

    // To store hashLeftRight(0, 0). We precompute it here to save gas.
    uint256 public currentSpentVoiceCreditsCommitment;

    // To store hashLeftRight(Merkle root of 5 ** voteOptionTreeDepth zeros, 0)
    uint256 public currentPerVOSpentVoiceCreditsCommitment;

    // The maximum number of leaves, minus one, of meaningful vote options.
    uint256 public voteOptionsMaxLeafIndex;

    // The batch # for the quote tally function
    uint256 public currentQvtBatchNum;

    // Cached results of 2 ** depth - 1 where depth is the state tree depth and
    // message tree depth
    uint256 public messageTreeMaxLeafIndex;

    // The maximum number of signups allowed
    uint256 public maxUsers;

    // The maximum number of messages allowed
    uint256 public maxMessages;

    // When the contract was deployed. We assume that the signup period starts
    // immediately upon deployment.
    uint256 public voteTimestamp;

    // Duration of the sign-up and voting periods, in seconds
    uint256 public votingDurationSeconds;


    // The contract which provides the values of the initial voice credit
    // balance per user
    // InitialVoiceCreditProxy public initialVoiceCreditProxy;

    // The coordinator's public key
    PubKey public coordinatorPubKey;

    uint256 public numSignUps;
    uint256 public numMessages = 0;

    TreeDepths public treeDepths;


    event PublishMessage(
        Message indexed _message,
        PubKey indexed _encPubKey
    );

    constructor(
        TreeDepths memory _treeDepths,
        BatchSizes memory _batchSizes,
        MaxValues memory _maxValues,
        BatchUpdateStateTreeVerifier _batchUstVerifier,
        QuadVoteTallyVerifier _qvtVerifier,
        uint256 _voteTimestamp,
        uint256 _votingDurationSeconds,
        MiniMaciState _maciState,
        // InitialVoiceCreditProxy _initialVoiceCreditProxy,
        PubKey memory _coordinatorPubKey
    ) Ownable() public {
        currentSpentVoiceCreditsCommitment = hashLeftRight(0, 0);
        treeDepths = _treeDepths;

        tallyBatchSize = _batchSizes.tallyBatchSize;
        messageBatchSize = _batchSizes.messageBatchSize;
        maciState = _maciState;
        stateRoot = getStateTreeRoot();

        // Set the verifier contracts
        batchUstVerifier = _batchUstVerifier;
        qvtVerifier = _qvtVerifier;

        // Set the sign-up duration
        voteTimestamp = _voteTimestamp;
        votingDurationSeconds = _votingDurationSeconds;
        
        // Set the coordinator's public key
        coordinatorPubKey = _coordinatorPubKey;

        // Calculate and cache the max number of leaves for each tree.
        // They are used as public inputs to the batch update state tree snark.
        messageTreeMaxLeafIndex = uint256(2) ** _treeDepths.messageTreeDepth - 1;

        // Check and store the maximum number of signups
        // It is the user's responsibility to ensure that the state tree depth
        // is just large enough and not more, or they will waste gas.
        uint256 stateTreeMaxLeafIndex = uint256(2) ** _treeDepths.stateTreeDepth - 1;
        require(_maxValues.maxUsers <= stateTreeMaxLeafIndex, "MACI: invalid maxUsers value");
        maxUsers = _maxValues.maxUsers;

        // The maximum number of messages
        require(_maxValues.maxMessages <= messageTreeMaxLeafIndex, "MACI: invalid maxMessages value");
        maxMessages = _maxValues.maxMessages;

        // The maximum number of leaves, minus one, of meaningful vote options.
        // This allows the snark to do a no-op if the user votes for an option
        // which has no meaning attached to it
        voteOptionsMaxLeafIndex = _maxValues.maxVoteOptions;

        // Create the message tree
        messageTree = new IncrementalMerkleTree(_treeDepths.messageTreeDepth, ZERO_VALUE);

        // Calculate and store the empty vote option tree root. This value must
        // be set before we call hashedBlankStateLeaf() later
        emptyVoteOptionTreeRoot = calcEmptyVoteOptionTreeRoot(_treeDepths.voteOptionTreeDepth);

        // Calculate and store a commitment to 5 ** voteOptionTreeDepth zeros,
        // and a salt of 0.
        currentResultsCommitment = hashLeftRight(emptyVoteOptionTreeRoot, 0);
        currentPerVOSpentVoiceCreditsCommitment = currentResultsCommitment;

    }


    /*
     * Returns the deadline to vote
     */
    function calcVotingDeadline() public view returns (uint256) {
        return voteTimestamp + votingDurationSeconds;
    }

    /*
     * Ensures that the calling function only continues execution if the
     * current block time is before the voting deadline.
     */
    modifier isBeforeVotingDeadline() {
        require(now < calcVotingDeadline(), "MACI: the voting period has passed");
        _;
    }

    /*
     * Ensures that the calling function only continues execution if the
     * current block time is after or equal to the voting deadline.
     */
    modifier isAfterVotingDeadline() {
        require(now >= calcVotingDeadline(), "MACI: the voting period is not over");
        _;
    }


    /*
     * Allows anyone to publish a message (an encrypted command and signature).
     * This function also inserts it into the message tree.
     * @param _userPubKey The user's desired public key.
     * @param _message The message to publish
     * @param _encPubKey An epheremal public key which can be combined with the
     *     coordinator's private key to generate an ECDH shared key which which was
     *     used to encrypt the message.
     */
    function publishMessage(
        Message memory _message,
        PubKey memory _encPubKey
    ) 
    isBeforeVotingDeadline
    public {

        require(numMessages < maxMessages, "MACI: message limit reached");

        require(numSignUps > 0, "MACI: nobody signed up");

        // When this function is called for the first time, set
        // postSignUpStateRoot to the last known state root.
        // We do so as the batchProcessMessage function can only update the
        // state root as a variable and has no way to use
        // IncrementalQuinTree.insertLeaf() anyway.
        if (postSignUpStateRoot == 0) {
            // It is exceedingly improbable that the zero value is a tree root
            assert(postSignUpStateRoot != stateRoot);

            postSignUpStateRoot = stateRoot;

            // This is exceedingly unlikely to occur
            assert(postSignUpStateRoot != 0);
        }

        // Calculate leaf value
        uint256 leaf = hashMessage(_message);

        // Insert the new leaf into the message tree
        messageTree.insertLeaf(leaf);

        numMessages ++;

        emit PublishMessage(_message, _encPubKey);
    }

    /*
     * A helper function to convert an array of 8 uint256 values into the a, b,
     * and c array values that the zk-SNARK verifier's verifyProof accepts.
     */
    function unpackProof(
        uint256[8] memory _proof
    ) public pure returns (
        uint256[2] memory,
        uint256[2][2] memory,
        uint256[2] memory
    ) {

        return (
            [_proof[0], _proof[1]],
            [
                [_proof[2], _proof[3]],
                [_proof[4], _proof[5]]
            ],
            [_proof[6], _proof[7]]
        );
    }

    /*
     * A helper function to create the publicSignals array from meaningful
     * parameters.
     * @param _newStateRoot The new state root after all messages are processed
     * @param _stateTreeRoots The intermediate state roots
     * @param _ecdhPubKeys The public key used to generated the ECDH shared key
     *                     to decrypt the message
     */
    function genBatchUstPublicSignals(
        uint256 _newStateRoot,
        uint256[] memory _stateTreeRoots,
        PubKey[] memory _ecdhPubKeys
    ) public view returns (uint256[20] memory) {

        uint256 messageBatchEndIndex;
        if (currentMessageBatchIndex + messageBatchSize <= numMessages) {
            messageBatchEndIndex = currentMessageBatchIndex + messageBatchSize - 1;
        } else {
            messageBatchEndIndex = numMessages - 1;
        }

        uint256[20] memory publicSignals;
        publicSignals[0] = _newStateRoot;
        publicSignals[1] = coordinatorPubKey.x;
        publicSignals[2] = coordinatorPubKey.y;
        publicSignals[3] = voteOptionsMaxLeafIndex;
        publicSignals[4] = messageTree.root();
        publicSignals[5] = currentMessageBatchIndex;
        publicSignals[6] = messageBatchEndIndex;
        publicSignals[7] = numSignUps;

        for (uint8 i = 0; i < messageBatchSize; i++) {
            uint8 x = 8 + i;
            uint8 y = 8 + messageBatchSize + i * 2;
            uint8 z = y + 1;
            publicSignals[x] = _stateTreeRoots[i];
            publicSignals[y] = _ecdhPubKeys[i].x;
            publicSignals[z] = _ecdhPubKeys[i].y;
        }

        return publicSignals;
    }

    function hasUnprocessedMessages() public view returns (bool) {
        return currentMessageBatchIndex < numMessages;
    }

    /*
     * Update the postSignupStateRoot if the batch update state root proof is
     * valid.
     * @param _newStateRoot The new state root after all messages are processed
     * @param _stateTreeRoots The intermediate state roots
     * @param _ecdhPubKeys The public key used to generated the ECDH shared key
     *                     to decrypt the message
     * @param _proof The zk-SNARK proof
     */
    function batchProcessMessage(
        uint256 _newStateRoot,
        uint256[] memory _stateTreeRoots,
        PubKey[] memory _ecdhPubKeys,
        uint256[8] memory _proof
    ) 
    isAfterVotingDeadline
    public {
        // Ensure that the current batch index is within range
        require(
            hasUnprocessedMessages(),
            "MACI: no more messages left to process"
        );
        
        // Ensure that the array of state tree roots and the array of ECDH
        // public keys are of the correct length
        require(
            _stateTreeRoots.length == messageBatchSize,
            "MACI: incorrect _stateTreeRoots length"
        );

        require(
            _ecdhPubKeys.length == messageBatchSize,
            "MACI: incorrect _ecdhPubKeys length"
        );

        // Ensure that currentMessageBatchIndex is within range
        require(
            currentMessageBatchIndex <= messageTreeMaxLeafIndex,
            "MACI: currentMessageBatchIndex not within range"
        );

        // Assemble the public inputs to the snark
        uint256[20] memory publicSignals = genBatchUstPublicSignals(
            _newStateRoot,
            _stateTreeRoots,
            _ecdhPubKeys
        );

        // Ensure that each public input is within range of the snark scalar
        // field.
        // TODO: consider having more granular revert reasons
        for (uint8 i=0; i < publicSignals.length; i++) {
            require(
                publicSignals[i] < SNARK_SCALAR_FIELD,
                "MACI: each public signal must be lt the snark scalar field"
            );
        }

        // Unpack the snark proof
        (
            uint256[2] memory a,
            uint256[2][2] memory b,
            uint256[2] memory c
        ) = unpackProof(_proof);

        // Verify the proof
        require(
            batchUstVerifier.verifyProof(a, b, c, publicSignals),
            "MACI: invalid batch UST proof"
        );

        // Increase the message batch start index to ensure that each message
        // batch is processed in order
        currentMessageBatchIndex += messageBatchSize;

        // Update the state root
        postSignUpStateRoot = _newStateRoot;
    }

    /*
     * Returns the public signals required to verify a quadratic vote tally
     * snark.
     */
    function genQvtPublicSignals(
        uint256 _intermediateStateRoot,
        uint256 _newResultsCommitment,
        uint256 _newSpentVoiceCreditsCommitment,
        uint256 _newPerVOSpentVoiceCreditsCommitment
    ) public view returns (uint256[9] memory) {

        uint256[9] memory publicSignals;

        publicSignals[0] = _newResultsCommitment;
        publicSignals[1] = _newSpentVoiceCreditsCommitment;
        publicSignals[2] = _newPerVOSpentVoiceCreditsCommitment;
        publicSignals[3] = postSignUpStateRoot;
        publicSignals[4] = currentQvtBatchNum;
        publicSignals[5] = _intermediateStateRoot;
        publicSignals[6] = currentResultsCommitment;
        publicSignals[7] = currentSpentVoiceCreditsCommitment;
        publicSignals[8] = currentPerVOSpentVoiceCreditsCommitment;

        return publicSignals;
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

    function hasUntalliedStateLeaves() public view returns (bool) {
        return currentQvtBatchNum < (1 + (numSignUps / tallyBatchSize));
    }

    /*
     * Tally the next batch of state leaves.
     * @param _intermediateStateRoot The intermediate state root, which is
     *     generated from the current batch of state leaves 
     * @param _newResultsCommitment A hash of the tallied results so far
     *     (cumulative)
     * @param _proof The zk-SNARK proof
     */
    function proveVoteTallyBatch(
        uint256 _intermediateStateRoot,
        uint256 _newResultsCommitment,
        uint256 _newSpentVoiceCreditsCommitment,
        uint256 _newPerVOSpentVoiceCreditsCommitment,
        uint256[8] memory _proof
    ) 
    public {

        require(numSignUps > 0, "MACI: nobody signed up");
        uint256 totalBatches = 1 + (numSignUps / tallyBatchSize);

        // Ensure that the batch # is within range
        require(
            currentQvtBatchNum < totalBatches,
            "MACI: all batches have already been tallied"
        );

        // Generate the public signals
        // public 'input' signals = [output signals, public inputs]
        uint256[9] memory publicSignals = genQvtPublicSignals(
            _intermediateStateRoot,
            _newResultsCommitment,
            _newSpentVoiceCreditsCommitment,
            _newPerVOSpentVoiceCreditsCommitment
        );

        // Unpack the snark proof
        (
            uint256[2] memory a,
            uint256[2][2] memory b,
            uint256[2] memory c
        ) = unpackProof(_proof);

        // Verify the proof
        bool isValid = qvtVerifier.verifyProof(a, b, c, publicSignals);

        require(isValid == true, "MACI: invalid quadratic vote tally proof");

        // Save the commitment to the new results for the next batch
        currentResultsCommitment = _newResultsCommitment;

        // Save the commitment to the total spent voice credits for the next batch
        currentSpentVoiceCreditsCommitment = _newSpentVoiceCreditsCommitment;

        // Save the commitment to the per voice credit spent voice credits for the next batch
        currentPerVOSpentVoiceCreditsCommitment = _newPerVOSpentVoiceCreditsCommitment;

        // Increment the batch #
        currentQvtBatchNum ++;
    }

    /*
     * Verify the result of the vote tally using a Merkle proof and the salt.
     * This function can also verify the number of voice credits spent per vote
     * option as the commitment is computed in the same way.
     */
    function verifyTallyResult(
        uint8 _depth,
        uint256 _index,
        uint256 _leaf,
        uint256[][] memory _pathElements,
        uint256 _salt
    ) public view returns (bool) {
        uint256 computedRoot = computeMerkleRootFromPath(
            _depth,
            _index,
            _leaf,
            _pathElements
        );

        uint256 computedCommitment = hashLeftRight(computedRoot, _salt);
        return computedCommitment == currentResultsCommitment;
    }

    /*
     * Verify the total number of spent voice credits.
     * @param _spent The value to verify
     * @param _salt The salt which is hashed with the value to generate the
     *              commitment to the spent voice credits.
     */
    function verifySpentVoiceCredits(
        uint256 _spent,
        uint256 _salt
    ) public view returns (bool) {
        uint256 computedCommitment = hashLeftRight(_spent, _salt);
        return computedCommitment == currentSpentVoiceCreditsCommitment;
    }

    function calcEmptyVoteOptionTreeRoot(uint8 _levels) public pure returns (uint256) {
        return computeEmptyQuinRoot(_levels, 0);
    }

    function getMessageTreeRoot() public view returns (uint256) {
        return messageTree.root();
    }

    function getStateTreeRoot() public view returns (uint256) {
        return maciState.getStateTreeRoot();
    }
}
