cask "vencordinstaller" do
  version "1.4.1"
  sha256 "224f689154f1a3d716ae8d08f5f9d96200612dd349262fd4bde78f2feb0166ba"
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
