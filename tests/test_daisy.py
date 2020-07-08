from brownie import accounts, web3, Wei, reverts #, rpc
from brownie.network.transaction import TransactionReceipt
from brownie.convert import to_address
import pytest
from brownie import Contract
from settings import *


# reset the chain after every test case
@pytest.fixture(autouse=True)
def isolation(fn_isolation):
    pass


def test_init_daisy(daisy, mini_maci):
    assert daisy.maci() == mini_maci


def test_daisy_lock_mkr(daisy, mkr_token):
    mkr_token.approve(daisy,LOCKED_UP,{'from': accounts[1]} )
    daisy.signUp(LOCKED_UP, 0,0, {'from': accounts[1]})

def test_daisy_withdraw_mkr(daisy, mkr_token, iou_token):
    mkr_token.approve(daisy,LOCKED_UP,{'from': accounts[1]} )
    iou_token.approve(daisy,LOCKED_UP,{'from': accounts[1]} )
    daisy.signUp(LOCKED_UP, 0,0, {'from': accounts[1]})
    daisy.withdraw(LOCKED_UP, {'from': accounts[1]})

# def test_daisy_publish_message(daisy, mkr_token):
#     mkr_token.approve(daisy,LOCKED_UP,{'from': accounts[1]} )
#     daisy.signUp(LOCKED_UP, 0,0, {'from': accounts[1]})
#     message = [0, [0,0,0,0,0,0,0,0,0,0]]
#     key = [0,0]
#     rpc.sleep(VOTING_TIME)
#     rpc.mine()
#     daisy.publishMessage(message,key, {'from': accounts[1]})
