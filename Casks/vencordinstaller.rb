cask "vencordinstaller" do
  version "1.5.1"
  sha256 "634a08d878164d1ea2bf4acae1893a95d79a335f7e7eedfa52d99dfdea6215e1"
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
