import SwiftUI

struct DownloadsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var downloadManager: DownloadManager
    
    var body: some View {
        VStack(spacing: 0) {
            if downloadManager.downloads.isEmpty {
                EmptyStateView(
                    icon: "arrow.down.circle",
                    title: "No downloads yet",
                    subtitle: "Right-click a file → Download"
                )
            } else {
                // Header
                HStack(spacing: 0) {
                    Text("File").frame(maxWidth: .infinity, alignment: .leading)
                    Text("Size").frame(width: 90, alignment: .trailing)
                    Text("Progress").frame(width: 70, alignment: .center)
                    Text("Speed").frame(width: 80, alignment: .trailing)
                    Text("Status").frame(width: 90, alignment: .leading)
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(themeManager.dim)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(themeManager.card)
                .overlay(
                    Rectangle().fill(themeManager.faint).frame(height: 1),
                    alignment: .bottom
                )
                
                // Download list
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(downloadManager.downloads.enumerated()), id: \.element.id) { index, task in
                            DownloadRow(task: task, isAlternate: index % 2 == 1)
                                .contextMenu {
                                    if task.state == .downloading {
                                        Button {
                                            downloadManager.pauseDownload(task)
                                        } label: {
                                            Label("Pause", systemImage: "pause.circle")
                                        }
                                    }
                                    
                                    if task.state == .paused {
                                        Button {
                                            downloadManager.resumeDownload(task)
                                        } label: {
                                            Label("Resume", systemImage: "play.circle")
                                        }
                                    }
                                    
                                    if task.state == .downloading || task.state == .paused || task.state == .queued {
                                        Button(role: .destructive) {
                                            downloadManager.cancelDownload(task)
                                        } label: {
                                            Label("Cancel", systemImage: "xmark.circle")
                                        }
                                    }
                                    
                                    Divider()
                                    
                                    Button {
                                        shareFile(task)
                                    } label: {
                                        Label("Share File", systemImage: "square.and.arrow.up")
                                    }
                                    .disabled(task.state != .complete)
                                    
                                    if task.state == .complete || task.state == .error || task.state == .cancelled {
                                        Button(role: .destructive) {
                                            downloadManager.removeDownload(task)
                                        } label: {
                                            Label("Remove from list", systemImage: "trash")
                                        }
                                    }
                                }
                                .onTapGesture(count: 2) {
                                    if task.state == .complete {
                                        shareFile(task)
                                    }
                                }
                        }
                    }
                }
            }
        }
    }
    
    private func shareFile(_ task: DownloadTaskItem) {
        guard task.state == .complete else { return }
        let url = task.savePath
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = rootVC.view
                popover.sourceRect = CGRect(x: rootVC.view.bounds.midX, y: rootVC.view.bounds.midY, width: 0, height: 0)
            }
            rootVC.present(activityVC, animated: true)
        }
    }
}
