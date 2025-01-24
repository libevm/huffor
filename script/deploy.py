from web3 import Web3
import os 

from eth_account import Account

w3 = Web3(Web3.HTTPProvider("https://eth.merkle.io"))

with open(os.path.join(os.path.dirname(__file__) , 'contract.bin'), 'r') as f:
    bytecode = f.read()

acc = Account.from_key("0xc87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3")

if not bytecode.startswith("0x"):
    bytecode = '0x' + bytecode

nonce = w3.eth.get_transaction_count(acc.address)

tx = {
    "data": bytecode,
    "gas": 5_000_000,
    "gasPrice": w3.to_wei(1, 'gwei'),
    "nonce": nonce,
    "chainId": 0x01,
}
signed_tx = acc.sign_transaction(tx)
raw_tx = signed_tx.raw_transaction.hex()

if not raw_tx.startswith("0x"):
    raw_tx = "0x" + raw_tx

resp = w3.provider.make_request("eth_sendRawTransaction", [raw_tx])
print(resp)