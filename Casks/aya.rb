cask "aya" do
  arch arm: "arm64", intel: "x64"

  version "1.14.1"
  sha256 :no_check

  url "https://github.com/liriliri/aya/releases/download/v#{version}/AYA-#{version}-mac-#{arch}.dmg"
  name "AYA"
  desc "Android ADB desktop app"
  homepage "https://github.com/liriliri/aya"

  livecheck do
    url :url
    strategy :github_latest
  end

  auto_updates true

  app "AYA.app"

  zap trash: [
    "~/Library/Application Support/AYA",
    "~/Library/Caches/AYA",
    "~/Library/Preferences/com.electron.aya.plist",
    "~/Library/Saved Application State/com.electron.aya.savedState",
  ]

end
