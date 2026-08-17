#!/bin/bash

set -e

source scripts/casks-config.sh

for CASK_INFO in "${CASKS[@]}"; do
  IFS='|' read -r CASK_PATH SOURCE_TYPE SOURCE_TARGET APP_NAME INCLUDE_PRERELEASE SHA_TYPE <<< "$CASK_INFO"

  echo "============================================="
  echo "Processing $APP_NAME ($CASK_PATH) via $SOURCE_TYPE ($SOURCE_TARGET)"
  echo "Pre-release inclusion: $INCLUDE_PRERELEASE"
  echo "SHA type: $SHA_TYPE"
  echo "============================================="

  ./scripts/update-cask.sh "$CASK_PATH" "$SOURCE_TYPE" "$SOURCE_TARGET" "$APP_NAME" "$INCLUDE_PRERELEASE" "$SHA_TYPE"

  git checkout main
done

echo "All casks processed successfully!"
