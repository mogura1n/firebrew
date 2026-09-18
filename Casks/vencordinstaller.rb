cask "vencordinstaller" do
  version "1.4.2"
  sha256 "2d127ef1f5cab27d31a71880b237db0356c34b33ffe977827d95b8c6e5cb80d1"
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
