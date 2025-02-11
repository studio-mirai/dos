# DOS-1

DOS-1 defines a base standard for creating a capped PFP collection that uses IPFS as a storage layer.

**Disclaimer: DOS-1 is intended to be a temporary standard. Once Walrus has been deployed to mainnet, the Cascade team will deploy a more robust and extensible standard that uses Walrus as a storage layer. Once the new Walrus-based standard has been finalized, we will provide migration guidelines for creators who wish to migrate from DOS-1 to the new standard.**

## How to Use

First, update `collection.move` with information about your collection.

```
const FRAMEWORK: vector<u8> = b"DOS-1";
const NAME: vector<u8> = b"Prime Machin";
const DESCRIPTION: vector<u8> = b"Prime Machin is a collection of 3,333 robots.";
const UNIT_NAME: vector<u8> = b"Prime Machin";
const UNIT_DESCRIPTION: vector<u8> = b"A robot manufactured by the Triangle Company.";
const SUPPLY: u64 = 3333;
const SYMBOL: vector<u8> = b"PRIME_MACHIN";
const IS_DESTROYABLE: bool = false;
```

Then, publish the collection with Sui client.

```
sui client publish
```