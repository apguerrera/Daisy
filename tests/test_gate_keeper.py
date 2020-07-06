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


def test_init_gate_keeper(gate_keeper):
    # not the hat yet
    assert gate_keeper.isInMemberList(accounts[0], {'from': accounts[0]}) == False
