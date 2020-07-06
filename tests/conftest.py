
from brownie import accounts, web3, Wei, rpc
from brownie.network.transaction import TransactionReceipt
from brownie.convert import to_address
import pytest
from brownie import Contract
from settings import *
from poseidon import *

######################################
# Deploy Contracts
######################################



@pytest.fixture(scope='module', autouse=True)
def mkr_token(DSToken):
    mkr_token = DSToken.deploy(MKR_NAME, {'from': accounts[0]})
    return mkr_token

@pytest.fixture(scope='module', autouse=True)
def iou_token(DSToken):
    iou_token = DSToken.deploy(IOU_NAME, {'from': accounts[0]})
    return iou_token


@pytest.fixture(scope='module', autouse=True)
def mkr_chief(DSChief, mkr_token, iou_token):
    mkr_chief = DSChief.deploy(mkr_token, iou_token, MAX_YAYS, {'from': accounts[0]})
    return mkr_chief

@pytest.fixture(scope='module', autouse=True)
def credit_proxy(DaisyCreditProxy, mkr_chief):
    credit_proxy = DaisyCreditProxy.deploy(mkr_chief, {'from': accounts[0]})
    return credit_proxy

@pytest.fixture(scope='module', autouse=True)
def gate_keeper(DaisyGatekeeper):
    gate_keeper = DaisyGatekeeper.deploy({'from': accounts[0]})
    return gate_keeper


@pytest.fixture(scope='module', autouse=True)
def tally_verifier(QuadVoteTallyVerifier):
    tally_verifier = QuadVoteTallyVerifier.deploy({'from': accounts[0]})
    return tally_verifier

@pytest.fixture(scope='module', autouse=True)
def batch_verifier(BatchUpdateStateTreeVerifier):
    batch_verifier = BatchUpdateStateTreeVerifier.deploy({'from': accounts[0]})
    return batch_verifier

@pytest.fixture(scope='module', autouse=True)
def poseidon_6(interface):
    tx = accounts[0].transfer(data=poseidon_6_data)
    poseidon_6 = interface.PoseidonT6(tx.contract_address)
    return poseidon_6

@pytest.fixture(scope='module', autouse=True)
def poseidon_3(interface):
    tx = accounts[0].transfer(data=poseidon_3_data)
    poseidon_3 = interface.PoseidonT3(tx.contract_address)
    return poseidon_3

# @pytest.fixture(scope='module', autouse=True)
# def mini_maci(MiniMACI,gate_keeper, poseidon_3, poseidon_6, batch_verifier,tally_verifier, credit_proxy):
#     treeDepths = [4,4,4]
#     batchSizes = [4,4]
#     maxValues = [100,100,10]
#     signUpGatekeeper = gate_keeper
#     batchUstVerifier = batch_verifier
#     qvtVerifier = tally_verifier
#     signUpDurationSeconds = 600
#     votingDurationSeconds = 600
#     initialVoiceCreditProxy = credit_proxy
#     coordinatorPubKey = [0,0]

#     mini_maci = MiniMACI.deploy( treeDepths,
#                                     batchSizes,
#                                     maxValues,
#                                     signUpGatekeeper,
#                                     batchUstVerifier,
#                                     qvtVerifier,
#                                     signUpDurationSeconds,
#                                     votingDurationSeconds,
#                                     initialVoiceCreditProxy,
#                                     coordinatorPubKey,
#                                     poseidon_3, 
#                                      poseidon_6,
#                             {'from': accounts[0]})
#     return mini_maci




# @pytest.fixture(scope='module', autouse=True)
# def daisy(Daisy):
#     daisy = Daisy.deploy({'from': accounts[0]})
#     return daisy

