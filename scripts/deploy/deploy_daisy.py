
from brownie import *
from .settings import *
from .poseidon import *

import time



def main():
    # add accounts if active network is ropsten
    if network.show_active() in ['ropsten']:
        # 0x2A40019ABd4A61d71aBB73968BaB068ab389a636
        accounts.add('4ca89ec18e37683efa18e0434cd9a28c82d461189c477f5622dae974b43baebf')
        # 0x1F3389Fc75Bf55275b03347E4283f24916F402f7
        accounts.add('fa3c06c67426b848e6cef377a2dbd2d832d3718999fbe377236676c9216d8ec0')



    mkr_token = DSToken.deploy(MKR_NAME, {'from': accounts[0]})
    mkr_token.mint(accounts[1], MKR_TOKENS_1, {'from': accounts[0]})

    iou_token = DSToken.deploy(IOU_NAME, {'from': accounts[0]})
    mkr_chief = DSChief.deploy(mkr_token, iou_token, MAX_YAYS, {'from': accounts[0]})
    iou_token.setOwner(mkr_chief, {'from': accounts[0]})

    credit_proxy = DaisyCreditProxy.deploy(mkr_chief, {'from': accounts[0]})
    gate_keeper = DaisyGatekeeper.deploy({'from': accounts[0]})



    tally_verifier = QuadVoteTallyVerifier.deploy({'from': accounts[0]})
    batch_verifier = BatchUpdateStateTreeVerifier.deploy({'from': accounts[0]})


    tx = accounts[0].transfer(data=poseidon_6_data)
    poseidon_6 = interface.PoseidonT6(tx.contract_address)

    tx = accounts[0].transfer(data=poseidon_3_data)
    poseidon_3 = interface.PoseidonT3(tx.contract_address)

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



    daisy = Daisy.deploy(mkr_chief, mini_maci, gate_keeper, {'from': accounts[0]})

