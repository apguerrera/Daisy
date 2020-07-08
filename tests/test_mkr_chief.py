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


def test_init_mkr_chief(mkr_chief):
    # not the hat yet
    assert mkr_chief.isUserRoot(accounts[0], {'from': accounts[0]}) == False

# def test_init_iou_token(iou_token):
#     assert iou_token.symbol() == IOU_NAME


def test_mkr_chief(mkr_chief, mkr_token, iou_token):
    tokens_to_test = MKR_TOKENS_1 - LOCKED_UP
    assert mkr_token.balanceOf(accounts[1], {'from': accounts[0]}) == MKR_TOKENS_1
    mkr_token.approve(mkr_chief, tokens_to_test, {'from': accounts[1]})
    mkr_chief.lock(tokens_to_test, {'from': accounts[1]})
    assert iou_token.balanceOf(accounts[1], {'from': accounts[0]}) == tokens_to_test
