## firebrew
Self-maintained [Homebrew](https://brew.sh/) repository.

`tree`
```
.
├── Casks
│   ├── aya.rb
│   ├── pcsx2.rb
│   ├── rquickshare.rb
│   ├── stacher7.rb
│   ├── uad-ng.rb
│   └── vencordinstaller.rb
├── Formula
│   └── cutefetch.rb
├── README.md
├── audit_exceptions
│   └── github_prerelease_allowlist.json
└── scripts
    ├── casks-config.sh
    ├── process-casks.sh
    └── update-cask.sh
```

### Adding the Tap

To add this tap to your Homebrew installation:

```bash
brew tap mogura1n/firebrew https://github.com/mogura1n/firebrew
```

### App Installation
#### Formula
```
brew install mogura1n/firebrew/appname
```
or
```
brew install appname
```

#### Casks
```bash
brew install --cask navialliance/firebrew/appname
```
or
```
brew install --cask appname
```

### Removing the Tap

> [!NOTE]
> You should remove any installed apps from this tap before removing the tap.

To remove this tap from your Homebrew installation:
```bash
brew untap mogura1n/firebrew
```
