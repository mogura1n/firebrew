#!/bin/bash

# Define the list of casks to check and their respective sources
# Format: "CaskPath|SourceType|SourceTarget|AppName|PreRelease|SHA"
# SourceType: github | header_redirect
# PreRelease: Set to "true" to include pre-release versions, "false" for stable releases only (GitHub only)
# SHA: none | single | dual
CASKS=(
  "Casks/pcsx2.rb|github|PCSX2/pcsx2|pcsx2|true|single"
  "Casks/vencordinstaller.rb|github|Vencord/Installer|vencordinstaller|false|single"
  "Casks/rquickshare.rb|github|Martichou/rquickshare|rquickshare|false|dual"
  "Casks/aya.rb|github|liriliri/aya|aya|false|none"
  "Casks/uad-ng.rb|github|Universal-Debloater-Alliance/universal-android-debloater-next-generation|uad-ng|false|none"
  "Casks/stacher7.rb|header_redirect|https://api.stacher.io/api/update/mac/arm64/latest|stacher7|false|none"
)
