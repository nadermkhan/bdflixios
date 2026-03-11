// BDFlix/SearchView.swift
import SwiftUI

struct SearchView: View {
    @EnvironmentObject var engine: SearchEngine
    @EnvironmentObject var dlMgr: DownloadManager
    @State private var query = ""
    @State private var toast = ""
    @State private var showToast = false

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
                    List {
                        ForEach(engine.results) { file in
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
            .onSubmit(of: .search) { engine.search(query) }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if engine.isSearching {
                        ProgressView()
                    } else if !engine.results.isEmpty {
                        Text(engine.progress)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
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

    private func flash(_ msg: String) {
        toast = msg
        withAnimation { showToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation { showToast = false }
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
                Label(file.server, systemImage: "server.rack")
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
