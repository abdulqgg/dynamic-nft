from brownie import accounts, network, config

forked_local_enviroment = ["mainnet-fork-dev"]
local_blockchain_env = ["development", "ganache-local"]

def get_account(index=None, id=None):
    # account[0]
    # accounts.add('env')
    # accounts.load('id')
    if index:
        return accounts[index]
    if id:
        return accounts.load(id)
    if (
        network.show_active() in local_blockchain_env
        or network.show_active() in forked_local_enviroment
    ):
        return accounts[0]
    
    return accounts.add(config["wallets"]["from_key"])