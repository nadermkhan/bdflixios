// BDFlix/DownloadsView.swift
import SwiftUI

struct DownloadsView: View {
    @EnvironmentObject var mgr: DownloadManager
    @State private var showFilesReminder = false

    var body: some View {
        NavigationStack {
            Group {
                if mgr.items.isEmpty {
                    VStack(spacing: 12) {
                        Spacer()
                        Image(systemName: "arrow.down.circle")
                            .font(.system(size: 48)).foregroundStyle(.secondary)
                        Text("No downloads yet")
                            .font(.headline).foregroundStyle(.secondary)
                        Text("Swipe a search result to download")
                            .font(.caption).foregroundStyle(.tertiary)
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(mgr.items) { item in
                            DLRow(item: item)
                                .swipeActions(edge: .leading) {
                                    if item.state == .downloading {
                                        Button { mgr.pause(item) } label: { Label("Pause", systemImage: "pause") }.tint(.orange)
                                    }
                                    if item.state == .paused {
                                        Button { mgr.resume(item) } label: { Label("Resume", systemImage: "play") }.tint(.green)
                                    }
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    if item.state == .done || item.state == .error || item.state == .cancelled {
                                        Button(role: .destructive) { mgr.remove(item) } label: { Label("Remove", systemImage: "trash") }
                                    }
                                    if item.state == .downloading || item.state == .paused {
                                        Button(role: .destructive) { mgr.cancel(item) } label: { Label("Cancel", systemImage: "xmark") }
                                    }
                                }
                                .contextMenu {
                                    if item.state == .downloading {
                                        Button { mgr.pause(item) } label: { Label("Pause", systemImage: "pause.circle") }
                                    }
                                    if item.state == .paused {
                                        Button { mgr.resume(item) } label: { Label("Resume", systemImage: "play.circle") }
                                    }
                                    if item.state == .downloading || item.state == .paused {
                                        Button(role: .destructive) { mgr.cancel(item) } label: { Label("Cancel", systemImage: "xmark.circle") }
                                    }
                                    if item.state == .done {
                                        Button { share(item) } label: { Label("Share File", systemImage: "square.and.arrow.up") }
                                        Button { openFolder(item.savePath.deletingLastPathComponent()) } label: { Label("Open Folder", systemImage: "folder") }
                                    }
                                    if item.state == .done || item.state == .error || item.state == .cancelled {
                                        Button(role: .destructive) { mgr.remove(item) } label: { Label("Remove", systemImage: "trash") }
                                    }
                                }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Downloads")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button { showFilesReminder = true } label: {
                            Label("Change Save Location", systemImage: "folder")
                        }
                        Section {
                            Text("Current: \(mgr.saveDir.lastPathComponent)")
                        }
                    } label: {
                        Image(systemName: "folder.badge.gearshape")
                    }
                }
            }
            .alert("Manage in Files App", isPresented: $showFilesReminder) {
                Button("Open Files App", role: .none) {
                    if let url = URL(string: "shareddocuments://"), UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("To avoid LiveContainer sandbox limitations, please use the native iOS Files app to move or manage downloaded files.")
            }
        }
    }

    private func share(_ item: DLItem) {
        guard FileManager.default.fileExists(atPath: item.savePath.path) else { return }
        let av = UIActivityViewController(activityItems: [item.savePath], applicationActivities: nil)
        if let ws = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let vc = ws.windows.first?.rootViewController {
            if let pop = av.popoverPresentationController {
                pop.sourceView = vc.view
                pop.sourceRect = CGRect(x: vc.view.bounds.midX, y: vc.view.bounds.midY, width: 0, height: 0)
            }
            vc.present(av, animated: true)
        }
    }

    private func openFolder(_ url: URL) {
        var comps = URLComponents(url: url, resolvingAgainstBaseURL: false)
        comps?.scheme = "shareddocuments"
        if let sharedUrl = comps?.url, UIApplication.shared.canOpenURL(sharedUrl) {
            UIApplication.shared.open(sharedUrl)
        } else {
            let av = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            if let ws = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let vc = ws.windows.first?.rootViewController {
                if let pop = av.popoverPresentationController {
                    pop.sourceView = vc.view
                    pop.sourceRect = CGRect(x: vc.view.bounds.midX, y: vc.view.bounds.midY, width: 0, height: 0)
                }
                vc.present(av, animated: true)
            }
        }
    }
}

// MARK: - Download Row

struct DLRow: View {
    @ObservedObject var item: DLItem

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(item.fileName)
                .font(.subheadline)
                .lineLimit(1)

            if item.state == .downloading || item.state == .paused {
                ProgressView(value: item.progress)
                    .tint(item.state == .paused ? .orange : .blue)
            }

            HStack {
                statusBadge
                Spacer()
                if item.fileSize > 0 {
                    Text("\(Fmt.size(item.downloaded)) / \(Fmt.size(item.fileSize))")
                        .font(.caption2).foregroundStyle(.secondary)
                } else if item.downloaded > 0 {
                    Text(Fmt.size(item.downloaded))
                        .font(.caption2).foregroundStyle(.secondary)
                }
            }

            if item.state == .downloading {
                HStack {
                    Text(Fmt.speed(item.speed)).font(.caption2).foregroundStyle(.secondary)
                    Spacer()
                    Text("ETA: \(item.eta)").font(.caption2).foregroundStyle(.secondary)
                }
            }

            if item.state == .error && !item.errorMsg.isEmpty {
                Text(item.errorMsg).font(.caption2).foregroundStyle(.red)
            }
        }
        .padding(.vertical, 4)
    }

    private var statusBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: statusIcon)
                .font(.caption2)
            Text(item.state.rawValue)
                .font(.caption2).bold()
        }
        .foregroundStyle(statusColor)
    }

    private var statusIcon: String {
        switch item.state {
        case .queued: return "clock"
        case .downloading: return "arrow.down"
        case .paused: return "pause"
        case .done: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .cancelled: return "xmark.circle"
        }
    }

    private var statusColor: Color {
        switch item.state {
        case .downloading: return .blue
        case .paused: return .orange
        case .done: return .green
        case .error, .cancelled: return .red
        case .queued: return .secondary
        }
    }
}

// MARK: - Folder Picker

struct FolderPicker: UIViewControllerRepresentable {
    let onPick: (URL?) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.folder])
        picker.directoryURL = DownloadManager.defaultDir()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ vc: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onPick: onPick) }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPick: (URL?) -> Void
        init(onPick: @escaping (URL?) -> Void) { self.onPick = onPick }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { onPick(nil); return }
            guard url.startAccessingSecurityScopedResource() else { onPick(nil); return }
            let bm = try? url.bookmarkData(options: .minimalBookmark, includingResourceValuesForKeys: nil, relativeTo: nil)
            if let bm = bm {
                UserDefaults.standard.set(bm, forKey: "savedDownloadDir")
            }
            onPick(url)
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            onPick(nil)
        }
    }
}
