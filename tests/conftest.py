
from brownie import accounts, web3, Wei, rpc
from brownie.network.transaction import TransactionReceipt
from brownie.convert import to_address
import pytest
from brownie import Contract
from settings import *

######################################
# Deploy Contracts
######################################



@pytest.fixture(scope='module', autouse=True)
def mkr_token(DSToken):
    mkr_token = DSToken.deploy(MKR_NAME, {'from': accounts[0]})
    return mkr_token


# @pytest.fixture(scope='module', autouse=True)
# def daisy(Daisy):
#     daisy = Daisy.deploy({'from': accounts[0]})
#     return daisy

