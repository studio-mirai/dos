module dos_1::factory;

use dos_1::collection::{Collection, CollectionAdminCap};
use dos_1::nft::{Self, Nft};
use std::u64;
use sui::event::emit;
use sui::table_vec::{Self, TableVec};

//=== Structs ===

public struct FACTORY has drop {}

public struct Factory has key {
    id: UID,
    is_initialized: bool,
    nfts: TableVec<Nft>,
}

public struct FactoryCreatedEvent has copy, drop {
    factory_id: ID,
}

//=== Errors ===

const EFactoryAlreadyInitialized: u64 = 0;
const EFactoryNotInitialized: u64 = 1;
const EFactoryNotEmpty: u64 = 2;

//=== Init Function ===

fun init(_otw: FACTORY, ctx: &mut TxContext) {
    let factory = Factory {
        id: object::new(ctx),
        is_initialized: false,
        nfts: table_vec::empty(ctx),
    };

    emit(FactoryCreatedEvent { factory_id: factory.id() });

    transfer::share_object(factory);
}

//=== Public Functions ===

public fun destroy(self: Factory, _: &CollectionAdminCap) {
    assert!(self.is_initialized == true, EFactoryNotInitialized);
    assert!(self.nfts.length() == 0, EFactoryNotEmpty);

    let Factory { id, nfts, .. } = self;

    id.delete();
    nfts.destroy_empty();
}

public fun create_nfts(
    self: &mut Factory,
    _: &CollectionAdminCap,
    mut quantity: u64,
    collection: &mut Collection,
    ctx: &mut TxContext,
) {
    assert!(self.is_initialized == false, EFactoryAlreadyInitialized);

    quantity = u64::min(quantity, collection.supply() - self.nfts.length());

    let mut i = 0;
    while (i < quantity) {
        let nft = nft::new(self.nfts.length() + 1, collection, ctx);
        self.nfts.push_back(nft);
        i = i + 1;
    };

    if (self.nfts.length() == collection.supply()) {
        self.is_initialized = true;
    };
}

public fun remove_nfts(self: &mut Factory, _: &CollectionAdminCap, mut quantity: u64): vector<Nft> {
    assert!(self.is_initialized == true, EFactoryNotInitialized);

    quantity = u64::min(quantity, self.nfts.length());

    let mut nfts: vector<Nft> = vector[];

    let mut i = 0;
    while (i < quantity) {
        let nft = self.nfts.pop_back();
        nfts.push_back(nft);
        i = i + 1;
    };

    nfts
}

// Remove and transfer NFTs in a single function.
// This is useful for transferring NFTs directly to a Launch.
public fun remove_and_transfer_nfts(
    self: &mut Factory,
    _: &CollectionAdminCap,
    quantity: u64,
    recipient: address,
) {
    let mut i = 0;
    while (i < quantity) {
        let nft = self.nfts.pop_back();
        transfer::public_transfer(nft, recipient);
        i = i + 1;
    };
}

//=== View Functions ===

public fun id(self: &Factory): ID {
    object::id(self)
}

public fun is_initialized(self: &Factory): bool {
    self.is_initialized
}

public fun nfts(self: &Factory): &TableVec<Nft> {
    &self.nfts
}
