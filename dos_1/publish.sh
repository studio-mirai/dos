#!/bin/bash

required_vars=(
  "CREATOR_ADDRESS"
  "DEPLOYER_ADDRESS" 
  "NAME"
  "DESCRIPTION"
  "IMAGE_URI"
  "UNIT_NAME"
  "UNIT_DESCRIPTION"
  "SUPPLY"
  "SYMBOL"
  "IS_DESTROYABLE"
)

for var in "${required_vars[@]}"; do
  if [ -z "${!var}" ]; then
    echo "Error: Required environment variable $var is not set"
    exit 1
  fi
done

echo "Setting constants to specified values..."
perl -pi -e "s|^const NAME: vector<u8> = b\"[^\"]*\";|const NAME: vector<u8> = b\"${NAME}\";|" sources/collection.move
perl -pi -e "s|^const DESCRIPTION: vector<u8> = b\"[^\"]*\";|const DESCRIPTION: vector<u8> = b\"${DESCRIPTION}\";|" sources/collection.move
perl -pi -e "s|^const IMAGE_URI: vector<u8> = b\"[^\"]*\";|const IMAGE_URI: vector<u8> = b\"${IMAGE_URI}\";|" sources/collection.move
perl -pi -e "s|^const UNIT_NAME: vector<u8> = b\"[^\"]*\";|const UNIT_NAME: vector<u8> = b\"${UNIT_NAME}\";|" sources/collection.move
perl -pi -e "s|^const UNIT_DESCRIPTION: vector<u8> = b\"[^\"]*\";|const UNIT_DESCRIPTION: vector<u8> = b\"${UNIT_DESCRIPTION}\";|" sources/collection.move
perl -pi -e "s|^const SUPPLY: u64 = \\d+;|const SUPPLY: u64 = ${SUPPLY};|" sources/collection.move
perl -pi -e "s|^const SYMBOL: vector<u8> = b\"[^\"]*\";|const SYMBOL: vector<u8> = b\"${SYMBOL}\";|" sources/collection.move
perl -pi -e "s/^const IS_DESTROYABLE: bool = (true|false);/const IS_DESTROYABLE: bool = ${IS_DESTROYABLE};/" sources/collection.move

perl -pi -e "s|^creator = \".*\"|creator = \"${CREATOR_ADDRESS}\"|" Move.toml
perl -pi -e "s|^deployer = \".*\"|deployer = \"${DEPLOYER_ADDRESS}\"|" Move.toml

sui client ptb \
  --publish "." \
  --gas-budget 100000000

#RESULT=$(sui client publish --json --skip-dependency-verification)

echo "Resetting constants back to default values..."
perl -pi -e 's|const NAME: vector<u8> = b".*"|const NAME: vector<u8> = b"<NAME>"|' sources/collection.move
perl -pi -e 's|const DESCRIPTION: vector<u8> = b".*"|const DESCRIPTION: vector<u8> = b"<DESCRIPTION>"|' sources/collection.move
perl -pi -e 's|const IMAGE_URI: vector<u8> = b".*"|const IMAGE_URI: vector<u8> = b"<IMAGE_URI>"|' sources/collection.move
perl -pi -e 's|const UNIT_NAME: vector<u8> = b".*"|const UNIT_NAME: vector<u8> = b"<UNIT_NAME>"|' sources/collection.move
perl -pi -e 's|const UNIT_DESCRIPTION: vector<u8> = b".*"|const UNIT_DESCRIPTION: vector<u8> = b"<UNIT_DESCRIPTION>"|' sources/collection.move
perl -pi -e 's|const SUPPLY: u64 = \d+;|const SUPPLY: u64 = 0;|' sources/collection.move
perl -pi -e 's|const SYMBOL: vector<u8> = b".*"|const SYMBOL: vector<u8> = b"<SYMBOL>"|' sources/collection.move
perl -pi -e 's/^const IS_DESTROYABLE: bool = (true|false);/const IS_DESTROYABLE: bool = true;/' sources/collection.move

#echo "$RESULT" | jq '(.objectChanges[] | select(.type=="published") | .packageId)'

#echo "$RESULT" | jq -r .objectChanges