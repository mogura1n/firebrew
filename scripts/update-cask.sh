#!/bin/bash
set -euo pipefail

CASK_PATH="$1"
REPO="$2"
APP_NAME="$3"
INCLUDE_PRERELEASE="${4:-false}"
SHA_TYPE="${5:-single}"

if [ -z "$CASK_PATH" ] || [ -z "$REPO" ] || [ -z "$APP_NAME" ]; then
  echo "Usage: $0 CASK_PATH REPO APP_NAME [INCLUDE_PRERELEASE] [SHA_TYPE]"
  exit 1
fi

if [ ! -f "$CASK_PATH" ]; then
  echo "Cask file $CASK_PATH not found. Skipping."
  exit 0
fi

echo "GH_PAT present: $([ -n "${GH_PAT:-}" ] && echo yes || echo no)"

#############################################
# Helpers
#############################################

github_api() {
  local url="$1"

  if [ -n "${GH_PAT:-}" ]; then
    curl -fsSL \
      -H "Accept: application/vnd.github+json" \
      -H "Authorization: Bearer $GH_PAT" \
      "$url"
  else
    curl -fsSL \
      -H "Accept: application/vnd.github+json" \
      "$url"
  fi
}

get_filename() {
  basename "$1"
}

cleanup() {
  rm -rf "${TEMP_DIR:-}"
  rm -f "$CASK_PATH.bak"
}

trap cleanup EXIT

#############################################
# Fetch releases
#############################################

echo "Fetching releases from $REPO..."

RELEASES_DATA=$(github_api "https://api.github.com/repos/$REPO/releases")

# Ensure GitHub returned an array
if ! echo "$RELEASES_DATA" | jq -e 'type == "array"' >/dev/null 2>&1; then
  echo "❌ Invalid GitHub API response"
  echo "$RELEASES_DATA"
  exit 1
fi

#############################################
# Get latest tag
#############################################

get_latest_tag() {
  local json="$1"
  local include_pre="$2"

  if [ "$include_pre" = "true" ]; then
    echo "$json" | jq -r '.[0].tag_name'
  else
    echo "$json" | jq -r '
      [.[] | select(.prerelease == false)][0].tag_name
    '
  fi
}

LATEST_TAG=$(get_latest_tag "$RELEASES_DATA" "$INCLUDE_PRERELEASE")

if [ -z "$LATEST_TAG" ] || [ "$LATEST_TAG" = "null" ]; then
  echo "❌ Could not determine latest release tag"
  exit 1
fi

LATEST_VERSION=$(echo "$LATEST_TAG" | sed -E 's/^(v|release-|build-)//')

#############################################
# Current version check
#############################################

CURRENT_VERSION=$(
  grep -oP 'version ["'"'"']\K[^"'"'"']+' "$CASK_PATH" \
  || echo "not-found"
)

if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
  echo "$APP_NAME is already up to date."
  exit 0
fi

echo "Updating $APP_NAME:"
echo "  Current: $CURRENT_VERSION"
echo "  Latest : $LATEST_VERSION"

#############################################
# Update version
#############################################

sed -i.bak -E \
  "s/version [\"'].*[\"']/version \"$LATEST_VERSION\"/" \
  "$CASK_PATH"

#############################################
# SHA256 Handling
#############################################

TEMP_DIR=$(mktemp -d)

# Detect existing no_check
IS_NO_CHECK=$(grep -c "sha256 :no_check" "$CASK_PATH" || true)

if [ "$SHA_TYPE" = "none" ]; then
  echo "Using sha256 :no_check"

  if [ "$IS_NO_CHECK" -eq 0 ]; then
    sed -i.bak -E "/^  version/ a\\
  sha256 :no_check
" "$CASK_PATH"
  fi

else
  # Remove existing sha256 entries
  sed -i.bak '/^\s*sha256 /d' "$CASK_PATH"

  ###########################################
  # Dual architecture
  ###########################################

  if [ "$SHA_TYPE" = "dual" ]; then

    ARM_URL=$(
      echo "$RELEASES_DATA" | jq -r \
        --arg TAG "$LATEST_TAG" '
        [.[] | select(.tag_name == $TAG)][0]
        .assets[]
        | select(.name | test("arm|arm64"; "i"))
        | .browser_download_url
      ' | head -1
    )

    INTEL_URL=$(
      echo "$RELEASES_DATA" | jq -r \
        --arg TAG "$LATEST_TAG" '
        [.[] | select(.tag_name == $TAG)][0]
        .assets[]
        | select(.name | test("intel|x86_64|amd64"; "i"))
        | .browser_download_url
      ' | head -1
    )

    if [ -z "$ARM_URL" ] || [ "$ARM_URL" = "null" ]; then
      echo "❌ ARM asset not found"
      exit 1
    fi

    if [ -z "$INTEL_URL" ] || [ "$INTEL_URL" = "null" ]; then
      echo "❌ Intel asset not found"
      exit 1
    fi

    ARM_FILE="$TEMP_DIR/$(get_filename "$ARM_URL")"
    INTEL_FILE="$TEMP_DIR/$(get_filename "$INTEL_URL")"

    echo "Downloading ARM asset..."
    curl -fL "$ARM_URL" -o "$ARM_FILE"

    echo "Downloading Intel asset..."
    curl -fL "$INTEL_URL" -o "$INTEL_FILE"

    ARM_SHA256=$(shasum -a 256 "$ARM_FILE" | awk '{print $1}')
    INTEL_SHA256=$(shasum -a 256 "$INTEL_FILE" | awk '{print $1}')

    sed -i.bak -E "/^  version/ a\\
  sha256 arm:   \"$ARM_SHA256\",\\
         intel: \"$INTEL_SHA256\"
" "$CASK_PATH"

  ###########################################
  # Single asset
  ###########################################

  elif [ "$SHA_TYPE" = "single" ]; then

    # Prefer macOS tarball if available
    UNIVERSAL_URL=$(
      echo "$RELEASES_DATA" | jq -r \
        --arg TAG "$LATEST_TAG" '
        [.[] | select(.tag_name == $TAG)][0]
        .assets[]
        | select(.name | test("macos.*(tar\\.xz|zip|dmg|pkg)$"; "i"))
        | .browser_download_url
      ' | head -1
    )

    # Fallback to first asset
    if [ -z "$UNIVERSAL_URL" ] || [ "$UNIVERSAL_URL" = "null" ]; then
      UNIVERSAL_URL=$(
        echo "$RELEASES_DATA" | jq -r \
          --arg TAG "$LATEST_TAG" '
          [.[] | select(.tag_name == $TAG)][0]
          .assets[0]
          .browser_download_url
        '
      )
    fi

    if [ -z "$UNIVERSAL_URL" ] || [ "$UNIVERSAL_URL" = "null" ]; then
      echo "❌ Could not determine download URL"
      exit 1
    fi

    UNIVERSAL_FILE="$TEMP_DIR/$(get_filename "$UNIVERSAL_URL")"

    echo "Downloading asset..."
    curl -fL "$UNIVERSAL_URL" -o "$UNIVERSAL_FILE"

    UNIVERSAL_SHA256=$(shasum -a 256 "$UNIVERSAL_FILE" | awk '{print $1}')

    sed -i.bak -E "/^  version/ a\\
  sha256 \"$UNIVERSAL_SHA256\"
" "$CASK_PATH"

  else
    echo "❌ Unknown SHA_TYPE: $SHA_TYPE"
    exit 1
  fi
fi

#############################################
# Git operations
#############################################

git add "$CASK_PATH"

if git diff --cached --quiet; then
  echo "No changes detected."
  exit 0
fi

git commit -S -m "$APP_NAME: v$LATEST_VERSION"
git push origin main

echo "✅ Done with $APP_NAME"
