from brownie import accounts, network, config, Contract, MockV3Aggregator, VRFCoordinatorMock, LinkToken

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

contract_to_mock = {
    "eth_usd_price_feed": MockV3Aggregator,
    "vrf_coordinator": VRFCoordinatorMock,
    "link_token": LinkToken
}

def get_contract(contract_name):
    contract_type = contract_to_mock[contract_name]
    contract_address = config["networks"][network.show_active()][contract_name]
    contract = Contract.from_abi(contract_type._name, contract_address,contract_type.abi)
    return contract