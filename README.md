# BDFlix - iOS

A SwiftUI iOS app for searching and downloading files from DHAKA-FLIX servers.
Built for use with LiveContainer (unsigned IPA).

## Features

- **Search**: Search across multiple DHAKA-FLIX servers simultaneously
  - Support for exclusion terms (`-keyword`) and exact phrases (`"phrase"`)
  - Sortable results by name, size, server, folder
  - Media file highlighting
  
- **Downloads**: Built-in multi-threaded download manager
  - Pause/Resume/Cancel support
  - Progress tracking with speed and ETA
  - File sharing via iOS share sheet
  
- **UI**: Dark theme with animated color cycling
  - Dynamic color palette that slowly shifts hue
  - Smooth animations and transitions
  - Context menus for quick actions

## Building

### Automatic (GitHub Actions)
Push to `main` branch and the workflow will build an unsigned IPA automatically.
Download from the Actions artifacts or Releases page.

### Manual
```bash
chmod +x generate_project.sh
./generate_project.sh
xcodebuild -project BDFlix.xcodeproj -scheme BDFlix \
  -configuration Release -sdk iphoneos \
  -destination 'generic/platform=iOS' \
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO archive \
  -archivePath build/BDFlix.xcarchive
mkdir -p build/Payload
cp -r build/BDFlix.xcarchive/Products/Applications/BDFlix.app build/Payload/
cd build && zip -r BDFlix.ipa Payload
```

## Installing with LiveContainer

1. Download the IPA from Releases
2. Open LiveContainer
3. Import the IPA
4. Launch BDFlix

## Requirements

- iOS 16.0+
- Network access to DHAKA-FLIX servers (172.16.50.x)

## License

Copyright © 2026 Nader Mahbub Khan. All rights reserved.
