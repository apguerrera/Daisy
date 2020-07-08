
from brownie import accounts, web3, Wei #, rpc
from brownie.network.transaction import TransactionReceipt
from brownie.convert import to_address
import pytest
from brownie import Contract, network
from settings import *
from poseidon import *

######################################
# Deploy Contracts
######################################

# add accounts if active network is ropsten
if network.show_active() in ['ropsten']:
    # 0x2A40019ABd4A61d71aBB73968BaB068ab389a636
    accounts.add('4ca89ec18e37683efa18e0434cd9a28c82d461189c477f5622dae974b43baebf')
    # 0x1F3389Fc75Bf55275b03347E4283f24916F402f7
    accounts.add('fa3c06c67426b848e6cef377a2dbd2d832d3718999fbe377236676c9216d8ec0')


@pytest.fixture(scope='module', autouse=True)
def mkr_token(DSToken):
    mkr_token = DSToken.deploy(MKR_NAME, {'from': accounts[0]})
    mkr_token.mint(accounts[1], MKR_TOKENS_1, {'from': accounts[0]})
    return mkr_token

@pytest.fixture(scope='module', autouse=True)
def iou_token(DSToken):
    iou_token = DSToken.deploy(IOU_NAME, {'from': accounts[0]})
    return iou_token


@pytest.fixture(scope='module', autouse=True)
def mkr_chief(DSChief, mkr_token, iou_token):
    mkr_chief = DSChief.deploy(mkr_token, iou_token, MAX_YAYS, {'from': accounts[0]})
    iou_token.setOwner(mkr_chief, {'from': accounts[0]})
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

@pytest.fixture(scope='module', autouse=True)
def mini_maci(MiniMACI,gate_keeper, poseidon_3, poseidon_6, batch_verifier,tally_verifier, credit_proxy):
    treeDepths = [10,10,4]
    batchSizes = [4,4]
    maxValues = [2**10 - 1, 2**10 - 1, 2**4 - 1]
    signUpGatekeeper = gate_keeper
    batchUstVerifier = batch_verifier
    qvtVerifier = tally_verifier
    signUpDurationSeconds = SIGNUP_TIME
    votingDurationSeconds = VOTING_TIME
    initialVoiceCreditProxy = credit_proxy
    coordinatorPubKey = [0,0]

    mini_maci = MiniMACI.deploy( treeDepths,
                                    batchSizes,
                                    batchUstVerifier,
                                    qvtVerifier,
                                    initialVoiceCreditProxy,
                                    coordinatorPubKey,
                                    poseidon_3, 
                                    poseidon_6,
                            {'from': accounts[0]})
    mini_maci.initMaci(signUpDurationSeconds,
                                    votingDurationSeconds, signUpGatekeeper, maxValues, {'from': accounts[0]})
    gate_keeper.initGatekeeper(mini_maci, {'from': accounts[0]})
    return mini_maci


@pytest.fixture(scope='module', autouse=True)
def daisy(Daisy, mkr_chief, mkr_token, mini_maci, gate_keeper):
    daisy = Daisy.deploy(mkr_chief, mini_maci, gate_keeper, {'from': accounts[0]})
    return daisy

