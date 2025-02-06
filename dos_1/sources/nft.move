module dos_1::nft;

use dos_1::collection::{Collection, CollectionAdminCap};
use std::string::String;
use sui::display;
use sui::event::emit;
use sui::package;
use sui::transfer::Receiving;
use sui::vec_map::{Self, VecMap};

//=== Structs ===

public struct NFT has drop {}

public struct Nft has key, store {
    id: UID,
    name: String,
    number: u64,
    image_uri: String,
    attributes: VecMap<String, String>,
}

//=== Events ===

public struct NftCreatedEvent has copy, drop {
    nft_id: ID,
    nft_number: u64,
}

public struct NftDestroyedEvent has copy, drop {
    nft_id: ID,
}

public struct NftRevealedEvent has copy, drop {
    nft_id: ID,
}

public struct ObjectReceivedEvent has copy, drop {
    nft_id: ID,
    object_id: ID,
}

//=== Errors ===

const ECollectionNotDestroyable: u64 = 0;
const EImageUriNotEmpty: u64 = 1;

//=== Init Function ===

fun init(otw: NFT, ctx: &mut TxContext) {
    let publisher = package::claim(otw, ctx);

    // Create a display object for the Nft type.
    let mut display = display::new<Nft>(&publisher, ctx);
    display.add(b"name".to_string(), b"{name}".to_string());
    display.add(b"number".to_string(), b"{number}".to_string());
    display.add(b"image_uri".to_string(), b"{image_uri}".to_string());
    display.add(b"attributes".to_string(), b"{attributes}".to_string());
    display.update_version();

    transfer::public_transfer(display, ctx.sender());
    transfer::public_transfer(publisher, ctx.sender());
}

//=== Public Functions ===

// Destroy an NFT. Only works if the collection.is_destroyable is true.
public fun destroy(self: Nft, collection: &mut Collection) {
    assert!(collection.is_destroyable() == true, ECollectionNotDestroyable);

    emit(NftDestroyedEvent {
        nft_id: object::id(&self),
    });

    collection.nfts_mut().remove(self.number());

    let Nft {
        id,
        attributes,
        ..,
    } = self;

    id.delete();
    attributes.into_keys_values();
}

// Receive an object that's been transferred to an NFT.
public fun receive<T: key + store>(nft: &mut Nft, obj_to_receive: Receiving<T>): T {
    let obj = transfer::public_receive(
        &mut nft.id,
        obj_to_receive,
    );

    emit(ObjectReceivedEvent {
        nft_id: object::id(nft),
        object_id: object::id(&obj),
    });

    obj
}

// Reveal the NFT with attributes keys, attribute values, and an image URI.
public fun reveal(
    self: &mut Nft,
    _: &CollectionAdminCap,
    mut attribute_keys: vector<String>,
    mut attribute_values: vector<String>,
    image_uri: String,
) {
    assert!(self.image_uri == b"".to_string(), EImageUriNotEmpty);

    while (!attribute_keys.is_empty()) {
        let key = attribute_keys.pop_back();
        self.attributes.insert(key, attribute_values.pop_back());
    };

    emit(NftRevealedEvent {
        nft_id: object::id(self),
    });

    self.image_uri = image_uri;
}

//=== Package Functions ===

public(package) fun new(number: u64, collection: &mut Collection, ctx: &mut TxContext): Nft {
    let mut name = collection.unit_name();
    name.append(b" #".to_string());
    name.append(number.to_string());

    let nft = Nft {
        id: object::new(ctx),
        name: name,
        number: number,
        image_uri: b"".to_string(),
        attributes: vec_map::empty(),
    };

    emit(NftCreatedEvent {
        nft_id: object::id(&nft),
        nft_number: number,
    });

    collection.nfts_mut().push_back(number, nft.id());

    nft
}

//=== View Functions ===

public fun id(self: &Nft): ID {
    object::id(self)
}

public fun name(self: &Nft): String {
    self.name
}

public fun number(self: &Nft): u64 {
    self.number
}

public fun image_uri(self: &Nft): String {
    self.image_uri
}

public fun attributes(self: &Nft): &VecMap<String, String> {
    &self.attributes
}
