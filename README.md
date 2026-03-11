# BDFlix iOS - Clean SwiftUI Rewrite

A simple, clean app with Search, Downloads (custom save location), and About tabs.

## Project Structure

```
BDFlix/
├── .github/
│   └── workflows/
│       └── build.yml
├── generate_project.sh
├── BDFlix/
│   ├── Info.plist
│   ├── BDFlixApp.swift
│   ├── Models.swift
│   ├── SearchEngine.swift
│   ├── DownloadManager.swift
│   ├── ContentView.swift
│   ├── SearchView.swift
│   ├── DownloadsView.swift
│   └── AboutView.swift
└── README.md
```

## Setup

1. Run the project generator to create the Xcode project:
   ```bash
   bash generate_project.sh
   ```
2. Open `BDFlix.xcodeproj` in Xcode.
3. Build and run!
