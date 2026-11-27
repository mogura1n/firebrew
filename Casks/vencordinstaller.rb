cask "vencordinstaller" do
  version "1.5.2"
  sha256 "63c8ecf4df50450778940a66d4636819eb68d31ff1f241fe411a403af1ba191b"
  url "https://github.com/Vencord/Installer/releases/download/v#{version}/VencordInstaller.MacOS.zip"
  name "VencordInstaller"
  desc "A cross platform app for installing Vencord"
  homepage "https://github.com/Vencord/Installer"

  livecheck do
    url :url
    strategy :github_latest
  end

  auto_updates true

  app "VencordInstaller.app"

  zap trash: [ "~/Library/Application Support/Vencord" ]
end
