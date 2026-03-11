// BDFlix/ContentView.swift
import SwiftUI

struct ContentView: View {
    @State private var tab = 0

    var body: some View {
        TabView(selection: $tab) {
            SearchView()
                .tabItem { Label("Search", systemImage: "magnifyingglass") }
                .tag(0)
            DownloadsView()
                .tabItem { Label("Downloads", systemImage: "arrow.down.circle") }
                .tag(1)
            AboutView()
                .tabItem { Label("About", systemImage: "info.circle") }
                .tag(2)
        }
    }
}
