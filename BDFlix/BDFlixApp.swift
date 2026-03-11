import SwiftUI

@main
struct BDFlixApp: App {
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var downloadManager = DownloadManager()
    @StateObject private var searchEngine = SearchEngine()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
                .environmentObject(downloadManager)
                .environmentObject(searchEngine)
                .preferredColorScheme(.dark)
        }
    }
}
