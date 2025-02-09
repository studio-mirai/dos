#!/bin/bash

RESULT=$(sui client publish --json --skip-dependency-verification)

echo "$RESULT" | jq '{
  packageId: (.objectChanges[] | select(.type=="published") | .packageId),
  createdObjects: [
    .objectChanges[] | select(.type=="created") | {object_type: .objectType, object_id: .objectId}
  ]
}'