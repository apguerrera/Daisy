from brownie import accounts, web3, Wei, reverts
from brownie.network.transaction import TransactionReceipt
from brownie.convert import to_address
import pytest
from brownie import Contract
from settings import *


# reset the chain after every test case
@pytest.fixture(autouse=True)
def isolation(fn_isolation):
    pass


# def test_init_mini_maci(mini_maci):
#     # not the hat yet
#     assert mkr_chief.numSignUps({'from': accounts[0]}) == 0

