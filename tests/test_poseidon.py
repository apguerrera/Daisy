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


def test_init_poseidon_6(poseidon_6):
    # hash of [0,2]
    hash02 = 15735137149728108807376621572167846217155769480058005968520407761537030824584
    assert poseidon_6.poseidon([0,2], {'from': accounts[0]}) == hash02

def test_init_poseidon_3(poseidon_3):
    # hash of [0,2]
    hash02 = 18635185184867746607110802977171684668136057276303097997434215497625612938641
    assert poseidon_3.poseidon([0,2], {'from': accounts[0]}) == hash02
