## Particle Token Contracts

There are three components of the token contracts: token, lockup, and airdrop.

### Token

Standard ERC20 token with the following features:

- Name: Particle
- Symbol: PTC
- Max supply of 200,000,000
- 18 decimal
- Max supply minted at deployment

### Lockup

Lockup contract to lock up unvested tokens. The contract is Ownable, controlled by a timelock.

### Airdrop

Airdrop contract to distribute tokens to a list of addresses using Merkle tree.

### Unit Tests

```
forge test -vv --fork-url https://rpc.ankr.com/blast --fork-block-number 4000000
```

### Deployment

```
forge script script/Deploy.s.sol --rpc-url 'https://rpc.ankr.com/blast' --private-key $PRIVATE_KEY --broadcast -vv
```

### Generate Merkle Proof

```
pip3 install --user merkletools eth_utils pycryptodome
python3 script/merkle.py
```