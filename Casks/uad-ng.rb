cask "uad-ng" do
  arch arm: "arm64", intel: "intel"

  version "1.2.0"
  sha256 :no_check

  on_arm do
  url "https://github.com/Universal-Debloater-Alliance/universal-android-debloater-next-generation/releases/download/v#{version}/uad-ng-macos.tar.gz"
  end

  on_intel do
  url "https://github.com/Universal-Debloater-Alliance/universal-android-debloater-next-generation/releases/download/v#{version}/uad-ng-macos-#{arch}.tar.gz"
  end

  name "Universal Android Debloater Next Generation"
  name "UAD-NG"
  desc "GUI which uses ADB to debloat non-rooted Android devices"
  homepage "https://github.com/Universal-Debloater-Alliance/universal-android-debloater-next-generation"

  auto_updates true
  depends_on cask: "android-platform-tools"

  on_arm do
  binary "uad-ng-macos", target: "uad-ng"
  end

  on_intel do
  binary "uad-ng-macos-intel", target: "uad-ng"
  end

  zap trash: "~/Library/Caches/uad"

  caveats do
    requires_rosetta
  end
end
