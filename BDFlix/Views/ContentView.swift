import SwiftUI

struct ContentView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var downloadManager: DownloadManager
    @EnvironmentObject var searchEngine: SearchEngine
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            themeManager.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Tab Bar
                HStack(spacing: 0) {
                    TabButton(title: "Search", icon: "magnifyingglass", isSelected: selectedTab == 0) {
                        selectedTab = 0
                    }
                    
                    TabButton(title: "Downloads", icon: "arrow.down.circle", isSelected: selectedTab == 1) {
                        selectedTab = 1
                    }
                    
                    TabButton(title: "About", icon: "info.circle", isSelected: selectedTab == 2) {
                        selectedTab = 2
                    }
                    
                    Spacer()
                    
                    Text("BDFlix")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(themeManager.accent)
                        .padding(.trailing, 16)
                }
                .frame(height: 48)
                .background(themeManager.card)
                
                // Accent line
                Rectangle()
                    .fill(themeManager.primary)
                    .frame(height: 2)
                
                // Search progress bar
                if searchEngine.isSearching {
                    AnimatedProgressBar()
                        .frame(height: 3)
                }
                
                // Content
                Group {
                    switch selectedTab {
                    case 0:
                        SearchView()
                    case 1:
                        DownloadsView()
                    case 2:
                        AboutView()
                    default:
                        SearchView()
                    }
                }
                
                // Status bar
                HStack {
                    Text(searchEngine.statusMessage)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(themeManager.dim)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(themeManager.card)
                .overlay(
                    Rectangle()
                        .fill(themeManager.faint)
                        .frame(height: 1),
                    alignment: .top
                )
            }
        }
        .onAppear {
            themeManager.startColorCycle()
        }
    }
}

struct TabButton: View {
    @EnvironmentObject var themeManager: ThemeManager
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                Spacer()
                HStack(spacing: 6) {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                    Text(title)
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(isSelected ? .white : (isHovered ? themeManager.textColor : themeManager.dim))
                Spacer()
                
                if isSelected {
                    Rectangle()
                        .fill(themeManager.accent)
                        .frame(height: 3)
                }
            }
        }
        .frame(width: title == "Downloads" ? 120 : 90, height: 48)
        .background(isSelected ? themeManager.primary : (isHovered ? themeManager.tabHover : themeManager.card))
        .onHover { hovering in
            isHovered = hovering
        }
    }
}
