from web3 import Web3
import json
import os
import time

DealClientAddress = "0xcB56EFB85d8035145450D28076C0994114B0BB7a"

w3 = Web3(Web3.HTTPProvider('https://api.hyperspace.node.glif.io/rpc/v1'))
abi_json = "../out/DealClient.sol/DealClient.json"
try:
    abi = json.load(open(abi_json))['abi']
    bytecode = json.load(open(abi_json))['bytecode']['object']
except Exception:
    print("Run forge b to compile abi")
    raise

PA=w3.eth.account.from_key(os.environ['PRIVATE_KEY'])

def getTxInfo():
    return { 'from': PA.address,
            'nonce': w3.eth.get_transaction_count(PA.address)}

def sendTx(tx):
    tx['maxPriorityFeePerGas'] = max(tx['maxPriorityFeePerGas'], tx['maxFeePerGas']) # intermittently fails otherwise
    tx['maxFeePerGas'] = max(tx['maxPriorityFeePerGas'], tx['maxFeePerGas']) # intermittently fails otherwise
    tx_create = w3.eth.account.sign_transaction(tx, PA.privateKey)
    tx_hash = w3.eth.send_raw_transaction(tx_create.rawTransaction)
    return w3.eth.wait_for_transaction_receipt(tx_hash)


def deploy():
    DealClient = w3.eth.contract(abi=abi, bytecode=bytecode)
    tx_info = getTxInfo()
    construct_txn = DealClient.constructor().buildTransaction(tx_info)
    tx_receipt = sendTx(construct_txn)
    print(f'Contract deployed at address: { tx_receipt.contractAddress }')


def getContract():
    ContractFactory = w3.eth.contract(abi=abi)
    contract = ContractFactory(DealClientAddress)
    return contract


def wait(blockNumber):
    wait_block_count = 0
    while True:
        curBlock = w3.eth.get_block('latest')
        if curBlock.number - blockNumber > wait_block_count:
            return
        time.sleep(1)
