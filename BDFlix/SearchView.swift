// BDFlix/SearchView.swift
import SwiftUI

struct SearchView: View {
    @Environment(\.editMode) private var editMode
    @EnvironmentObject var engine: SearchEngine
    @EnvironmentObject var dlMgr: DownloadManager
    
    @State private var query = ""
    @State private var toast = ""
    @State private var showToast = false

    @State private var filterMediaOnly = false
    @State private var sortColumn: SortColumn = .folder
    @State private var sortAscending = true

    // 1. Add state to hold selected file IDs
    @State private var selectedFiles = Set<UUID>()

    enum SortColumn: String, CaseIterable {
        case folder = "Folder"
        case name = "Name"
        case size = "Size"
    }

    var processedResults: [FileResult] {
        var base = engine.results
        if filterMediaOnly {
            base = base.filter { $0.isMedia }
        }
        return base.sorted { a, b in
            let res: Bool
            switch sortColumn {
            case .name: res = a.name.localizedCaseInsensitiveCompare(b.name) == .orderedAscending
            case .size: res = a.sizeBytes < b.sizeBytes
            case .folder: res = a.folder.localizedCaseInsensitiveCompare(b.folder) == .orderedAscending
            }
            return sortAscending ? res : !res
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if engine.results.isEmpty && !engine.isSearching {
                    VStack(spacing: 12) {
                        Spacer()
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        Text("Search for files")
                            .font(.headline).foregroundStyle(.secondary)
                        Text("Use -word to exclude, \"phrase\" for exact match")
                            .font(.caption).foregroundStyle(.tertiary)
                        Spacer()
                    }
                } else if engine.isSearching && engine.results.isEmpty {
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Searching \(engine.progress)")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                } else {
                    // 2. Bind the list to the selectedFiles set
                    List(selection: $selectedFiles) {
                        ForEach(processedResults) { file in
                            FileRow(file: file)
                                .swipeActions(edge: .trailing) {
                                    Button {
                                        dlMgr.add(url: file.fullUrl, name: file.name)
                                        flash("Download started")
                                    } label: {
                                        Label("Download", systemImage: "arrow.down.circle")
                                    }
                                    .tint(.blue)
                                }
                                .contextMenu {
                                    Button { dlMgr.add(url: file.fullUrl, name: file.name); flash("Download started") }
                                        label: { Label("Download", systemImage: "arrow.down.circle") }
                                    if file.isMedia {
                                        Button { watchM3U8(file) }
                                            label: { Label("Watch (M3U8)", systemImage: "play.circle") }
                                    }
                                    Button { UIPasteboard.general.string = file.fullUrl; flash("URL copied") }
                                        label: { Label("Copy URL", systemImage: "doc.on.doc") }
                                    Button { UIPasteboard.general.string = file.name; flash("Name copied") }
                                        label: { Label("Copy Name", systemImage: "doc.text") }
                                }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("BDFlix")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $query, prompt: "Search files...")
            .onSubmit(of: .search) { 
                selectedFiles.removeAll() // Clear selection on new search
                engine.search(query) 
            }
            .toolbar {
                // 3. Add an EditButton for multiselect
                ToolbarItem(placement: .navigationBarLeading) {
                    if !engine.results.isEmpty {
                        EditButton()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        if engine.isSearching {
                            ProgressView()
                        } else if !engine.results.isEmpty {
                            Text(engine.progress)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Menu {
                            Toggle("Media Files Only", isOn: $filterMediaOnly)
                            Divider()
                            Picker("Sort By", selection: $sortColumn) {
                                ForEach(SortColumn.allCases, id: \.self) { c in
                                    Text(c.rawValue).tag(c)
                                }
                            }
                            Toggle("Ascending", isOn: $sortAscending)
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                        }
                    }
                }
            }
            // 4. Show a download button at the bottom when items are selected
            .safeAreaInset(edge: .bottom) {
                if !selectedFiles.isEmpty {
                    Button {
                        downloadSelected()
                    } label: {
                        Label("Download \(selectedFiles.count) Files", systemImage: "arrow.down.circle.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.blue, in: Capsule())
                            .foregroundStyle(.white)
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.easeInOut, value: selectedFiles.isEmpty)
                }
            }
            .overlay(alignment: .bottom) {
                if showToast {
                    Text(toast)
                        .font(.subheadline).bold()
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20).padding(.vertical, 10)
                        .background(.blue, in: Capsule())
                        .padding(.bottom, 8)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }

    // 5. Logic for processing the bulk download
    private func downloadSelected() {
        let filesToDownload = processedResults.filter { selectedFiles.contains($0.id) }
        
        for file in filesToDownload {
            dlMgr.add(url: file.fullUrl, name: file.name)
        }
        
        let count = selectedFiles.count
        
        // Clean up UI state
        selectedFiles.removeAll()
        editMode?.wrappedValue = .inactive 
        
        flash("Started \(count) downloads")
    }

    private func flash(_ msg: String) {
        toast = msg
        withAnimation { showToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation { showToast = false }
        }
    }

    private func watchM3U8(_ file: FileResult) {
        let content = "#EXTM3U\n#EXTINF:-1,\(file.name)\n\(file.fullUrl)"
        let tempDir = FileManager.default.temporaryDirectory
        let m3u8URL = tempDir.appendingPathComponent("\(file.name).m3u8")
        do {
            try content.write(to: m3u8URL, atomically: true, encoding: .utf8)
            let av = UIActivityViewController(activityItems: [m3u8URL], applicationActivities: nil)
            if let ws = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let vc = ws.windows.first?.rootViewController {
                if let pop = av.popoverPresentationController {
                    pop.sourceView = vc.view
                    pop.sourceRect = CGRect(x: vc.view.bounds.midX, y: vc.view.bounds.midY, width: 0, height: 0)
                }
                vc.present(av, animated: true)
            }
        } catch {
            print("Failed to make m3u8")
        }
    }
}

// MARK: - File Row

struct FileRow: View {
    let file: FileResult

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundStyle(file.isMedia ? .blue : .secondary)
                    .frame(width: 18)
                Text(file.name)
                    .font(.subheadline)
                    .lineLimit(2)
            }
            HStack(spacing: 12) {
                Label(Fmt.size(file.sizeBytes), systemImage: "doc")
                    .font(.caption2).foregroundStyle(.secondary)
                Text(file.folder)
                    .font(.caption2).foregroundStyle(.tertiary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 2)
    }

    private var icon: String {
        switch file.ext {
        case ".mp4",".mkv",".avi",".mov",".flv",".webm",".m4v",".ts": return "film"
        case ".mp3",".flac",".aac",".ogg",".wav",".m4a": return "music.note"
        case ".zip",".rar",".7z",".tar",".gz": return "doc.zipper"
        case ".pdf": return "doc.text"
        case ".srt",".sub": return "captions.bubble"
        default: return "doc"
        }
    }
}
