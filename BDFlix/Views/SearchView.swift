import SwiftUI

struct SearchView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var searchEngine: SearchEngine
    @EnvironmentObject var downloadManager: DownloadManager
    @State private var searchText = ""
    @State private var showContextMenu = false
    @State private var selectedFile: FileResult?
    @State private var showPlaylistAlert = false
    @State private var playlistMessage = ""
    @State private var showCopiedToast = false
    @State private var copiedText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            SearchBar(text: $searchText) {
                let trimmed = searchText.trimmingCharacters(in: .whitespaces)
                if trimmed.count >= 2 && !searchEngine.isSearching {
                    searchEngine.search(term: trimmed)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            
            // Results
            if searchEngine.filteredResults.isEmpty {
                EmptyStateView(
                    icon: searchEngine.isSearching ? "magnifyingglass" : "doc.text.magnifyingglass",
                    title: searchEngine.isSearching ? "Searching servers..." : "No files to display",
                    subtitle: searchEngine.isSearching ? "Results will appear here" : "Type a query and press Search"
                )
            } else {
                // Sort header
                SortHeader()
                    .padding(.horizontal, 16)
                
                // File list
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(searchEngine.filteredResults.enumerated()), id: \.element.id) { index, file in
                            FileResultRow(file: file, isAlternate: index % 2 == 1)
                                .contentShape(Rectangle())
                                .onTapGesture(count: 2) {
                                    downloadManager.queueDownload(url: file.fullUrl, fileName: file.name)
                                }
                                .contextMenu {
                                    Button {
                                        downloadManager.queueDownload(url: file.fullUrl, fileName: file.name)
                                    } label: {
                                        Label("Download (Built-in)", systemImage: "arrow.down.circle")
                                    }
                                    
                                    Button {
                                        UIPasteboard.general.string = file.fullUrl
                                        showCopiedToast("URL copied!")
                                    } label: {
                                        Label("Copy URL", systemImage: "doc.on.doc")
                                    }
                                    
                                    Button {
                                        UIPasteboard.general.string = file.name
                                        showCopiedToast("Filename copied!")
                                    } label: {
                                        Label("Copy Filename", systemImage: "doc.text")
                                    }
                                    
                                    Divider()
                                    
                                    Button {
                                        generatePlaylist(for: file)
                                    } label: {
                                        Label("Playlist from folder", systemImage: "music.note.list")
                                    }
                                    
                                    if let shareUrl = URL(string: file.fullUrl) {
                                        ShareLink(item: shareUrl) {
                                            Label("Share Link", systemImage: "square.and.arrow.up")
                                        }
                                    }
                                }
                        }
                    }
                }
            }
        }
        .overlay(
            Group {
                if showCopiedToast {
                    VStack {
                        Spacer()
                        Text(copiedText)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(themeManager.primary.opacity(0.9))
                            .cornerRadius(8)
                            .padding(.bottom, 20)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .animation(.easeInOut(duration: 0.3), value: showCopiedToast)
        )
        .alert("Playlist", isPresented: $showPlaylistAlert) {
            Button("OK") {}
        } message: {
            Text(playlistMessage)
        }
    }
    
    private func showCopiedToast(_ text: String) {
        copiedText = text
        showCopiedToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showCopiedToast = false
        }
    }
    
    private func generatePlaylist(for file: FileResult) {
        if let result = searchEngine.generatePlaylist(folder: file.folder, server: file.server) {
            playlistMessage = "\(result.count) tracks → \(result.url.lastPathComponent)"
        } else {
            playlistMessage = "No media files in this folder."
        }
        showPlaylistAlert = true
    }
}

struct SortHeader: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var searchEngine: SearchEngine
    
    var body: some View {
        HStack(spacing: 0) {
            SortButton(title: "Name", column: .name, flex: 0.46)
            SortButton(title: "Size", column: .size, flex: 0.14)
            SortButton(title: "Server", column: .server, flex: 0.20)
            SortButton(title: "Folder", column: .folder, flex: 0.20)
        }
        .frame(height: 32)
        .background(themeManager.card)
        .overlay(
            Rectangle().fill(themeManager.faint).frame(height: 1),
            alignment: .bottom
        )
    }
}

struct SortButton: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var searchEngine: SearchEngine
    let title: String
    let column: SearchEngine.SortColumn
    let flex: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            Button {
                searchEngine.toggleSort(column)
            } label: {
                HStack(spacing: 4) {
                    Text(title)
                        .font(.system(size: 12, weight: .medium))
                    if searchEngine.sortColumn == column {
                        Image(systemName: searchEngine.sortAscending ? "chevron.up" : "chevron.down")
                            .font(.system(size: 9))
                    }
                    Spacer()
                }
                .foregroundColor(searchEngine.sortColumn == column ? themeManager.textColor : themeManager.dim)
                .padding(.horizontal, 8)
            }
        }
        .frame(width: UIScreen.main.bounds.width * flex - 8)
    }
}
