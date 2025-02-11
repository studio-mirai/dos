#!/bin/bash

# Check if two arguments are provided
if [ "$#" -ne 2 ]; then
  echo "Usage: bash publish.sh <creator_address> <deployer_address>"
  exit 1
fi

CREATOR_ADDRESS=$1
DEPLOYER_ADDRESS=$2

sed -i '' "s/\(creator = \)\"[^\"]*\"/\1\"${CREATOR_ADDRESS}\"/" Move.toml
sed -i '' "s/\(deployer = \)\"[^\"]*\"/\1\"${DEPLOYER_ADDRESS}\"/" Move.toml

RESULT=$(sui client publish --json --skip-dependency-verification)

echo "$RESULT" | jq '{
  packageId: (.objectChanges[] | select(.type=="published") | .packageId),
  createdObjects: [
    .objectChanges[] | select(.type=="created") | {object_type: .objectType, object_id: .objectId}
  ]
}'