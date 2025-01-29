# SOF-1

SOF-1 defines a base framework for creating a capped NFT collection that uses IPFS as a storage layer.

SOF-1 is split up into five modules:

1. collection.move
2. factory.move
3. nft.move
4. provenance.move
5. registry.move

## collection.move

This module defines a `Collection` object that contains metadata about the collection.

* framework - The framework name of the collection.
* collection_name - The name of the collection.
* unit_name - The name for a single unit in the collection (e.g. "Enforcer Machin" or "Prime Machin").
* symbol - The symbol of the collection, should be all caps (e.g. TAMASHI or PRIMEMACHIN).
* description - The description of the collection.
* attribute_keys - The valid attribute keys for the collection.
* supply - The total supply of the collection.
* is_destroyable - Whether NFTs in the collection are destroyable.
* nfts - A `LinkedTable` that stores the IDs of all NFTs in the collection, keyed by NFT number.

## factory.move

This module defines a `Factory` object that's used to create NFTs for a collection. Once NFTs are created, they can distributed directly or though a dedicated launchpad tool.

## nft.move

This module defines an `Nft` object, which is a unit of a collection.

```
public struct Nft has key, store {
    id: UID,
    name: String,
    number: u64,
    image_uri: Option<String>,
    attributes: VecMap<String, String>,
}
```

The `Nft` object includes a few required fields:

* name - The name of the NFT.
* number - The number of the NFT in the collection.
* image_uri - The URI of the NFT's image.
* attributes - A `VecMap` that maps attribute keys to attribute values.

`Nft` objects are initialized with an empty `attributes` map. `Nft` objects can be revealed by an admin via the `reveal()` method which requires a `CollectionAdminCap`.

## provenance.move

This module defines a `Provenance` object that forces a creator to specify a provenance hash for each NFT in a collection upfront. In the context of SOF-1, a provenance hash is a blake2b256 hash that takes the following inputs:

1. The number of the NFT.
2. The NFT's attribute keys as a concatenated string.
3. The NFT's attribute values as a concatenated string.
4. The NFT's image URI.

Once all the hashes for a collection have been inserted to the `Provenance` object, the `Provenance` object shifts to "initialized" state. With an initialized `Provenance` object, a creator can proceed to create NFTs for the collection. SOF-1 is structured this way to ensure that a creator does not have the ability to selectively reveal rare NFTs for their own benefit. During the reveal process for an NFT, its provenance hash is calculated onchain, and the reveal can only succeed if the calculated hash matches the expected hash.