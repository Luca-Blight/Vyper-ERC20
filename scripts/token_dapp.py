import os
from web3 import Web3
from dotenv import load_dotenv
import json

load_dotenv()

node_provider = os.environ['NODE_PROVIDER']
web3_connection = Web3(Web3.HTTPProvider(node_provider))

def are_we_connected():
    return web3_connection.isConnected()

def build_contract(contract_address,abi_path):
    with open(abi_path) as f:
        abiJson = json.load(f)
    contract = web3_connection.eth.contract(address=contract_address,abi=abiJson['abi'])
    return contract
def get_address(private_key):
    return web3_connection.eth.account.from_key(private_key).address
def transfer(_contract, _to, _amount, _signature): 
    
    nonce = web3_connection.eth.get_transaction_count(get_address(_signature))
    function_call = _contract.functions.transfer(_to,_amount).buildTransaction({'nonce':nonce,'from': '0x288EFe0aB0aFCAd79112b3854Fa2014A69b68F4d', 'gas': 20000000,'gasPrice': web3_connection.toWei('50', 'gwei')})
    signed_transaction = web3_connection.eth.account.sign_transaction(function_call,_signature)
    result = web3_connection.eth.send_raw_transaction(signed_transaction.rawTransaction)
    return result

def allowanceUp(_contract, _to, _amount, _signature): 
    
    nonce = web3_connection.eth.get_transaction_count(get_address(_signature))
    function_call = _contract.functions.increasedAllowance(_to,_amount).buildTransaction({'nonce':nonce,'from': '0x288EFe0aB0aFCAd79112b3854Fa2014A69b68F4d',"gasPrice": web3_connection.eth.gas_price})
    signed_transaction = web3_connection.eth.account.sign_transaction(function_call,_signature)
    result = web3_connection.eth.send_raw_transaction(signed_transaction.rawTransaction)
    return result
    
    
if __name__ == "__main__":
    token = build_contract(os.environ['ADDRESS'],os.environ['ABI_PATH'])
    transfer()
    
    