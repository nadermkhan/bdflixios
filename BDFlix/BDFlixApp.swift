// BDFlix/BDFlixApp.swift
import SwiftUI
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    var bgSessionCompletionHandler: (() -> Void)?

    func application(_ application: UIApplication,
                     handleEventsForBackgroundURLSession identifier: String,
                     completionHandler: @escaping () -> Void) {
        bgSessionCompletionHandler = completionHandler
    }
}

@main
struct BDFlixApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
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
