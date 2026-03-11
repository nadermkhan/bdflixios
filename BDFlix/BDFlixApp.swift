// BDFlix/BDFlixApp.swift
import SwiftUI
import UserNotifications

@main
struct BDFlixApp: App {
    @StateObject private var searchEngine = SearchEngine()
    @StateObject private var downloadManager = DownloadManager()

    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(searchEngine)
                .environmentObject(downloadManager)
        }
    }
}
