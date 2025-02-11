module dos_1::collection;

use std::string::String;
use sui::display;
use sui::event::emit;
use sui::linked_table::{Self, LinkedTable};
use sui::package;

//=== Structs ===

public struct COLLECTION has drop {}

//=== Constants ===

const FRAMEWORK: vector<u8> = b"DOS-1";
const NAME: vector<u8> = b"<NAME>";
const DESCRIPTION: vector<u8> = b"<DESCRIPTION>";
const IMAGE_URI: vector<u8> = b"<IMAGE_URI>";
const UNIT_NAME: vector<u8> = b"<UNIT_NAME>";
const UNIT_DESCRIPTION: vector<u8> = b"<UNIT_DESCRIPTION>";
const SUPPLY: u64 = 0;
const SYMBOL: vector<u8> = b"<SYMBOL>";
const IS_DESTROYABLE: bool = true;

//=== Structs ===

public struct Collection has key {
    id: UID,
    // The framework name of the collection.
    framework: String,
    // The creator of the collection.
    creator: address,
    // The name of the collection.
    name: String,
    // The description of the collection.
    description: String,
    // The image uri of the collection.
    image_uri: String,
    // The name for a unit of the collection (e.g. "Enforcer Machin" if the collection name is "ENFORCER MACHIN").
    unit_name: String,
    // The symbol of the collection, should be all caps (e.g. TAMASHI).
    unit_description: String,
    // The supply of the collection.
    supply: u64,
    // Symbol of the collection.
    symbol: String,
    // Whether NFTs in this collection should be destroyable.
    is_destroyable: bool,
    // Table that stores NFT IDs by number.
    nfts: LinkedTable<u64, ID>,
}

public struct CollectionAdminCap has key, store {
    id: UID,
    collection_id: ID,
    framework: String,
}

public struct CollectionInitializedEvent has copy, drop {
    collection_id: ID,
    collection_name: String,
    creator: address,
}

//=== Init Function ===

fun init(otw: COLLECTION, ctx: &mut TxContext) {
    let collection = Collection {
        id: object::new(ctx),
        framework: FRAMEWORK.to_string(),
        creator: @creator,
        name: NAME.to_string(),
        description: DESCRIPTION.to_string(),
        image_uri: IMAGE_URI.to_string(),
        unit_name: UNIT_NAME.to_string(),
        unit_description: UNIT_DESCRIPTION.to_string(),
        symbol: SYMBOL.to_string(),
        supply: SUPPLY,
        is_destroyable: IS_DESTROYABLE,
        nfts: linked_table::new(ctx),
    };

    let admin_cap = CollectionAdminCap {
        id: object::new(ctx),
        collection_id: object::id(&collection),
        framework: collection.framework(),
    };

    emit(CollectionInitializedEvent {
        collection_id: object::id(&collection),
        collection_name: collection.name(),
        creator: @creator,
    });

    let publisher = package::claim(otw, ctx);

    let mut display = display::new<Collection>(&publisher, ctx);
    display.add(b"framework".to_string(), b"{framework}".to_string());
    display.add(b"name".to_string(), b"{name}".to_string());
    display.add(b"description".to_string(), b"{description}".to_string());
    display.add(b"image_uri".to_string(), b"{image_uri}".to_string());
    display.add(b"unit_name".to_string(), b"{unit_name}".to_string());
    display.add(b"unit_description".to_string(), b"{unit_description}".to_string());
    display.add(b"supply".to_string(), b"{supply}".to_string());
    display.add(b"symbol".to_string(), b"{symbol}".to_string());
    display.add(b"is_destroyable".to_string(), b"{is_destroyable}".to_string());
    display.update_version();

    transfer::public_transfer(display, ctx.sender());
    transfer::public_transfer(publisher, ctx.sender());
    transfer::public_transfer(admin_cap, ctx.sender());

    transfer::share_object(collection);
}

//=== View Functions ===

public fun id(self: &Collection): ID {
    self.id.to_inner()
}

public fun name(self: &Collection): String {
    self.name
}

public fun description(self: &Collection): String {
    self.description
}

public fun unit_name(self: &Collection): String {
    self.unit_name
}

public fun unit_description(self: &Collection): String {
    self.unit_description
}

public fun framework(self: &Collection): String {
    self.framework
}

public fun is_destroyable(self: &Collection): bool {
    self.is_destroyable
}

public fun supply(self: &Collection): u64 {
    self.supply
}

public fun symbol(self: &Collection): String {
    self.symbol
}

//=== Package Functions ===

public(package) fun nfts_mut(self: &mut Collection): &mut LinkedTable<u64, ID> {
    &mut self.nfts
}
