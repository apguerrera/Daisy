from brownie import *
from .poseidon import *
import time



def deploy_poseidon_3():

    # tx = PoseidonT6.at({'from': accounts[0]})
    tx = accounts[0].transfer(data=poseidon_3)
    return tx

def deploy_poseidon_6():

    # tx = PoseidonT6.at({'from': accounts[0]})
    tx = accounts[0].transfer(data=poseidon_6)
    return tx.contract_address


def main():
    # add accounts if active network is ropsten
    if network.show_active() in ['ropsten']:
        # 0x2A40019ABd4A61d71aBB73968BaB068ab389a636
        accounts.add('4ca89ec18e37683efa18e0434cd9a28c82d461189c477f5622dae974b43baebf')
        # 0x1F3389Fc75Bf55275b03347E4283f24916F402f7
        accounts.add('fa3c06c67426b848e6cef377a2dbd2d832d3718999fbe377236676c9216d8ec0')


    poseidon_3 = deploy_poseidon_3()
    #Ropsten 0x0D6184972DA10Bc06671aEDde0da2B2284adBf53

    poseidon_6 = deploy_poseidon_6()
    #Ropsten 0xEbeb42FB0E0063461583Fe793Ed443D65f5cD54e