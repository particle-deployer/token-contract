# Particle Token Contracts

There are 4 components of the token contracts: token, lockup, airdrop and staking.

## Token

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

### Staking

Staking contract to stake tokens and account for the staked amount with timespan.


## Unit Tests

```
forge test -vv --fork-url https://rpc.ankr.com/blast --fork-block-number 4000000
```

## Deployment

```
forge script script/Deploy.s.sol --rpc-url 'https://rpc.ankr.com/blast' --private-key $PRIVATE_KEY --broadcast -vv
```

## Generate Merkle Proof

```
node script/merkle.js
```