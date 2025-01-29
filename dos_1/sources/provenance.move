module dos_1::provenance;

use dos_1::collection::{Collection, CollectionAdminCap};
use std::string::String;
use sui::event::emit;
use sui::hash::blake2b256;
use sui::hex;
use sui::table::{Self, Table};

//=== Structs ===

public struct PROVENANCE has drop {}

public struct Provenance has key {
    id: UID,
    is_initialized: bool,
    hashes: Table<u64, String>,
}

public struct ProvenanceCreatedEvent has copy, drop {
    provenance_id: ID,
}

//=== Errors ===

const EProvenanceHashMismatch: u64 = 0;
const EProvenanceAlreadyInitialized: u64 = 1;

//=== Init Function ===

fun init(_otw: PROVENANCE, ctx: &mut TxContext) {
    let provenance = Provenance {
        id: object::new(ctx),
        is_initialized: false,
        hashes: table::new(ctx),
    };

    emit(ProvenanceCreatedEvent { provenance_id: provenance.id() });

    transfer::share_object(provenance);
}

//=== Public Functions ===

public fun add_hash(
    self: &mut Provenance,
    _: &CollectionAdminCap,
    number: u64,
    hash: String,
    collection: &Collection,
) {
    assert!(self.is_initialized == false, EProvenanceAlreadyInitialized);

    self.hashes.add(number, hash);

    if (self.hashes.length() == collection.supply()) {
        self.is_initialized = true;
    };
}

//=== Package Functions ===

public(package) fun hashes_mut(self: &mut Provenance): &mut Table<u64, String> {
    &mut self.hashes
}

public(package) fun is_initialized(self: &Provenance): bool {
    self.is_initialized
}

public(package) fun calculate_hash(
    number: u64,
    mut attribute_keys: vector<String>,
    mut attribute_values: vector<String>,
    image_uri: String,
): String {
    attribute_keys.reverse();
    attribute_values.reverse();

    let mut input = number.to_string();

    while (!attribute_keys.is_empty()) {
        input.append(attribute_keys.pop_back());
    };

    while (!attribute_values.is_empty()) {
        input.append(attribute_values.pop_back());
    };

    input.append(image_uri);

    let hash = hex::encode(blake2b256(input.as_bytes())).to_string();

    hash
}

public(package) fun verify_hash(self: &mut Provenance, number: u64, hash: String) {
    let stored_hash = self.hashes.remove(number);
    assert!(stored_hash == hash, EProvenanceHashMismatch);
}

public fun id(self: &Provenance): ID {
    self.id.to_inner()
}

#[test]
fun test_calculate_hash() {
    let hash = calculate_hash(
        1,
        vector[
            b"aura".to_string(),
            b"background".to_string(),
            b"clothing".to_string(),
            b"decal".to_string(),
            b"headwear".to_string(),
            b"highlight".to_string(),
            b"internals".to_string(),
            b"mask".to_string(),
            b"screen".to_string(),
            b"skin".to_string(),
        ],
        vector[
            b"none".to_string(),
            b"yellow".to_string(),
            b"sweater-and-tie".to_string(),
            b"none".to_string(),
            b"cowboy-hat".to_string(),
            b"green".to_string(),
            b"gray".to_string(),
            b"tengu".to_string(),
            b"square-small".to_string(),
            b"semi-transparent".to_string(),
        ],
        b"bafkreifc2za5epml2gkwx3oe5s4gy5isy6niunew3yfsh5cfpuybto7w5a".to_string(),
    );

    assert!(
        hash == b"2fd6a57e2110635ac14624287c90baa2b34f0c88c73965004f024d62c1c945f0".to_string(),
    );
}
