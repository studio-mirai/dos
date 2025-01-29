module dos_1::collection;

use std::string::String;
use sui::event::emit;
use sui::linked_table::{Self, LinkedTable};
use sui::vec_set::{Self, VecSet};

public use fun initialize_collection_cap_id as InitializeCollectionCap.id;

public struct COLLECTION has drop {}

const FRAMEWORK: vector<u8> = b"DOS-1";
const COLLECTION_NAME: vector<u8> = b"PRIME MACHIN";
const UNIT_NAME: vector<u8> = b"Prime Machin";
const SYMBOL: vector<u8> = b"PRIME";
const DESCRIPTION: vector<u8> =
    b"Prime Machin is a collection of 3,333 robots manufactured by the Triangle Company.";
const ATTRIBUTE_KEYS: vector<vector<u8>> = vector[
    b"aura",
    b"background",
    b"clothing",
    b"decal",
    b"headwear",
    b"highlight",
    b"internals",
    b"mask",
    b"screen",
    b"skin",
];
const SUPPLY: u64 = 100;
const IS_DESTROYABLE: bool = true;

public struct Collection has key {
    id: UID,
    // The framework name of the collection.
    framework: String,
    // The name of the collection.
    collection_name: String,
    // The name for a unit of the collection (e.g. "Enforcer Machin" if the collection name is "ENFORCER MACHIN").
    unit_name: String,
    // The symbol of the collection, should be all caps (e.g. TAMASHI).
    symbol: String,
    // The description of the collection.
    description: String,
    // The valid attribute keys for the collection.
    attribute_keys: VecSet<String>,
    // The supply of the collection.
    supply: u64,
    // Whether NFTs in this collection should be destroyable.
    is_destroyable: bool,
    // Table that stores NFT IDs by number.
    nfts: LinkedTable<u64, ID>,
}

public struct CollectionAdminCap has key, store {
    id: UID,
}

public struct InitializeCollectionCap has key {
    id: UID,
}

public struct CollectionInitializeEvent has copy, drop {
    collection_id: ID,
    collection_name: String,
    creator: address,
}

fun init(_otw: COLLECTION, ctx: &mut TxContext) {
    let collection = Collection {
        id: object::new(ctx),
        framework: FRAMEWORK.to_string(),
        collection_name: COLLECTION_NAME.to_string(),
        unit_name: UNIT_NAME.to_string(),
        symbol: SYMBOL.to_string(),
        description: DESCRIPTION.to_string(),
        attribute_keys: vec_set::from_keys(ATTRIBUTE_KEYS.map!(|v| v.to_string())),
        supply: SUPPLY,
        is_destroyable: IS_DESTROYABLE,
        nfts: linked_table::new(ctx),
    };

    emit(CollectionInitializeEvent {
        collection_id: collection.id(),
        collection_name: collection.collection_name(),
        creator: ctx.sender(),
    });

    let collection_admin_cap = CollectionAdminCap {
        id: object::new(ctx),
    };

    transfer::share_object(collection);

    transfer::transfer(collection_admin_cap, ctx.sender());
}

public fun id(self: &Collection): ID {
    self.id.to_inner()
}

public fun attribute_keys(self: &Collection): &VecSet<String> {
    &self.attribute_keys
}

public fun description(self: &Collection): String {
    self.description
}

public fun is_destroyable(self: &Collection): bool {
    self.is_destroyable
}

public fun collection_name(self: &Collection): String {
    self.collection_name
}

public fun supply(self: &Collection): u64 {
    self.supply
}

public fun symbol(self: &Collection): String {
    self.symbol
}

public fun unit_name(self: &Collection): String {
    self.unit_name
}

public fun initialize_collection_cap_id(self: &InitializeCollectionCap): ID {
    object::id(self)
}

//=== Package Functions ===

public(package) fun nfts_mut(self: &mut Collection): &mut LinkedTable<u64, ID> {
    &mut self.nfts
}
