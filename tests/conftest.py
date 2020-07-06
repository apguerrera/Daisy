
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
def poseidon_6(Poseidon):
    poseidon_6 = PoseidonT6.deploy({'data': poseidon_6, 'from': accounts[0]})
    return poseidon_6

@pytest.fixture(scope='module', autouse=True)
def poseidon_3(PoseidonT3):
    poseidon_3 = PoseidonT3.deploy({'data': poseidon_3, 'from': accounts[0]})
    return poseidon_3


# @pytest.fixture(scope='module', autouse=True)
# def daisy(Daisy):
#     daisy = Daisy.deploy({'from': accounts[0]})
#     return daisy

