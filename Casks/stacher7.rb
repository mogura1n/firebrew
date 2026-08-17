cask "stacher7" do
  arch arm: "arm64", intel: "x64"

  version "7.1.11"
  sha256 :no_check

  url "https://s7-releases.stacher-cloud.com/s7-releases/Stacher_Setup_#{version}_#{arch}.dmg"
  name "Stacher7"
  desc "GUI front-end for the YT-DLP video downloader"
  homepage "https://stacher.io"

  livecheck do
    url "https://api.stacher.io/api/update/mac/arm64/latest"
    strategy :header_match do |headers|
      headers["location"]&.scan(/Stacher_Setup_(\d+(?:\.\d+)+)_arm64\.dmg/i)&.flatten&.first
    end
  end

  app "Stacher7.app"

  zap trash: [
    "~/Library/Application Support/Stacher7",
    "~/Library/Caches/com.electron.stacher7",
    "~/Library/Preferences/com.electron.stacher7.plist",
    "~/Library/Saved Application State/com.electron.stacher7.savedState",
  ]

end
