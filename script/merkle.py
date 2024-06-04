import csv
import argparse
import merkletools
from Crypto.Hash import keccak
from eth_utils import to_hex

parser = argparse.ArgumentParser(description='Merkle Tree Generator')
parser.add_argument('--input_file', type=str, default='./data/allocation.csv')
parser.add_argument('--output_file', type=str, default='./data/airdrop.csv')
conf = parser.parse_args()

def read_csv(file_path):
    data = []
    with open(file_path, 'r') as file:
        reader = csv.reader(file)
        next(reader)  # Skip header
        for row in reader:
            data.append((row[0], int(row[1])))
    return data

def write_csv(file_path, proofs):
    with open(file_path, 'w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(['address', 'amount', 'proof'])
        for proof in proofs:
            writer.writerow([proof['address'], proof['amount'], ','.join(proof['proof'])])

def abi_encode(address, amount):
    return b''.join([
        bytes.fromhex(address[2:].zfill(64)),
        amount.to_bytes(32, byteorder='big')
    ])

def keccak256(data):
    k = keccak.new(digest_bits=256)
    k.update(data)
    return k.digest()

class Keccak256MerkleTools(merkletools.MerkleTools):
    def _hash_function(self, value):
        return keccak256(value)

def main():
    data = read_csv(conf.input_file)
    mt = Keccak256MerkleTools()

    for address, amount in data:
        leaf = abi_encode(address, amount)
        mt.add_leaf(leaf, True)

    mt.make_tree()

    root = mt.get_merkle_root()
    print(f"Merkle Root: {to_hex(root)}")

    proofs = []
    for i, (address, amount) in enumerate(data):
        proof = mt.get_proof(i)
        proofs.append({
            'address': address,
            'amount': amount,
            'proof': [to_hex(p['right'] if 'right' in p else p['left']) for p in proof]
        })

    write_csv(conf.output_file, proofs)

if __name__ == '__main__':
    main()
