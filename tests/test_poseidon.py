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
    # not the hat yet
    assert poseidon_6.hash([0,2], {'from': accounts[0]}) == 0

# def test_init_iou_token(iou_token):
#     assert iou_token.symbol() == IOU_NAME
