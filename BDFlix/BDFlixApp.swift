// BDFlix/BDFlixApp.swift
import SwiftUI

@main
struct BDFlixApp: App {
    @StateObject private var searchEngine = SearchEngine()
    @StateObject private var downloadManager = DownloadManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(searchEngine)
                .environmentObject(downloadManager)
        }
    }
}
