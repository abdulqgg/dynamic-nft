from scripts.helpful_scripts import get_account
from brownie import BullBear
import time

sample_token_uri = "https://ipfs.io/ipfs/Qmd9MCGtdVz2miNumBHDbvj8bigSgTwnr4SbyH6DNnpWdt?filename=0-PUG.json"

def deploy():
    account = get_account()
    dynamic_nft = BullBear.deploy(1, "0xECe365B379E1dD183B20fc5f022230C044d51404", 18413,{"from": account}, publish_source=True)
    #tx = dynamic_nft.safeMint(account, sample_token_uri, {"from": account})
    #tx.wait(1)
    print("success")
    return dynamic_nft

def main():
    deploy()