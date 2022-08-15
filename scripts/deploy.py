from scripts.helpful_scripts import get_account
from brownie import DynamicNft

sample_token_uri = "https://ipfs.io/ipfs/Qmd9MCGtdVz2miNumBHDbvj8bigSgTwnr4SbyH6DNnpWdt?filename=0-PUG.json"

def deploy():
    account = get_account()
    dynamic_nft = DynamicNft.deploy({"from": account})
    tx = dynamic_nft.safeMint(account, sample_token_uri, {"from": account})
    tx.wait(1)
    print("success")



def main():
    deploy()