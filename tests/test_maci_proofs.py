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


def test_init_tally_verifier(tally_verifier):
    zk_input = [0,0,0,0,0,0,0,0,0]
    assert tally_verifier.verifyProof([0,0],[[0,0],[0,0]],[0,0],zk_input, {'from': accounts[0]}) == False


def test_init_batch_verifier(batch_verifier):
    zk_input = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    assert batch_verifier.verifyProof([0,0],[[0,0],[0,0]],[0,0],zk_input, {'from': accounts[0]}) == False

