from web3 import Web3
import json

# 连接到 anvil 本地节点
w3 = Web3(Web3.HTTPProvider('http://localhost:8545'))
assert w3.is_connected(), "无法连接到 anvil 节点"

# 合约地址（替换为你实际部署的合约地址）
contract_address = "0x5FbDB2315678afecb367f032d93F642f64180aa3"

# 合约 ABI（从 abi.json 文件中获取）
with open('/Users/dengfengqi/web3/upchain/foundry_practice/my-token-project/out/TokenBank.sol/TokenBank.json', 'r') as f:
    data = json.load(f)
    abi = data['abi']

# 获取合约实例
contract = w3.eth.contract(address=contract_address, abi=abi)

# 账户信息
private_key = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
account = w3.eth.account.from_key(private_key)
w3.eth.default_account = account.address

# 获取余额
def get_balance():
    balance = contract.functions.getBalance().call()
    print(f"当前账户余额: {w3.from_wei(balance, 'ether')} ETH")

# 存款
def deposit(amount_ether):
    amount_wei = w3.to_wei(amount_ether, 'ether')
    txn = contract.functions.deposit().build_transaction({
        'chainId': w3.eth.chain_id,
        'gas': 2000000,
        'gasPrice': w3.eth.gas_price,
        'nonce': w3.eth.get_transaction_count(account.address),
        'value': amount_wei
    })
    signed_txn = account.sign_transaction(txn)
    txn_hash = w3.eth.send_raw_transaction(signed_txn.raw_transaction)
    w3.eth.wait_for_transaction_receipt(txn_hash)
    print(f"成功存入 {amount_ether} ETH")

# 取款
def withdraw(amount_ether):
    amount_wei = w3.to_wei(amount_ether, 'ether')
    txn = contract.functions.withdraw(amount_wei).build_transaction({
        'chainId': w3.eth.chain_id,
        'gas': 2000000,
        'gasPrice': w3.eth.gas_price,
        'nonce': w3.eth.get_transaction_count(account.address)
    })
    signed_txn = account.sign_transaction(txn)
    txn_hash = w3.eth.send_raw_transaction(signed_txn.raw_transaction)
    w3.eth.wait_for_transaction_receipt(txn_hash)
    print(f"成功取出 {amount_ether} ETH")
if __name__ == '__main__':

    # 示例操作
    get_balance()
    deposit(1)
    get_balance()
    withdraw(0.5)
    get_balance()
