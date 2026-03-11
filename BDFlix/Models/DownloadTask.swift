import Foundation
import Combine

enum DownloadState: String, Sendable {
    case queued = "Queued"
    case downloading = "▶ Downloading"
    case paused = "⏸ Paused"
    case complete = "✔ Complete"
    case error = "✖ Error"
    case cancelled = "✖ Cancelled"
    
    var icon: String {
        switch self {
        case .queued: return "clock"
        case .downloading: return "arrow.down.circle.fill"
        case .paused: return "pause.circle.fill"
        case .complete: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .cancelled: return "xmark.circle"
        }
    }
    
    var color: String {
        switch self {
        case .queued: return "dim"
        case .downloading: return "green"
        case .paused: return "yellow"
        case .complete: return "green"
        case .error, .cancelled: return "red"
        }
    }
}

class DownloadTaskItem: ObservableObject, Identifiable {
    let id: Int
    let url: String
    let fileName: String
    let savePath: URL
    let serverHost: String
    let serverPath: String
    let serverPort: Int
    
    @Published var fileSize: Int64 = -1
    @Published var totalDownloaded: Int64 = 0
    @Published var state: DownloadState = .queued
    @Published var speed: Double = 0
    @Published var errorMessage: String = ""
    
    var isPaused = false
    var isCancelled = false
    var urlSessionTask: URLSessionDownloadTask?
    var resumeData: Data?
    
    var startTime: Date?
    var lastBytes: Int64 = 0
    var lastTime: Date?
    var smoothSpeed: Double = 0
    
    var progress: Double {
        guard fileSize > 0 else { return 0 }
        return Double(totalDownloaded) / Double(fileSize)
    }
    
    var eta: String {
        guard speed > 0, fileSize > 0 else { return "—" }
        let remaining = fileSize - totalDownloaded
        return Formatters.formatETA(remaining: remaining, speed: speed)
    }
    
    init(id: Int, url: String, fileName: String, savePath: URL) {
        self.id = id
        self.url = url
        self.fileName = fileName
        self.savePath = savePath
        
        // Parse URL
        var host = ""
        var path = "/"
        var port = 80
        var u = url
        if u.hasPrefix("http://") {
            u = String(u.dropFirst(7))
        } else if u.hasPrefix("https://") {
            u = String(u.dropFirst(8))
            port = 443
        }
        if let slashIdx = u.firstIndex(of: "/") {
            host = String(u[u.startIndex..<slashIdx])
            path = String(u[slashIdx...])
        } else {
            host = u
        }
        if let colonIdx = host.firstIndex(of: ":") {
            port = Int(host[host.index(after: colonIdx)...]) ?? port
            host = String(host[host.startIndex..<colonIdx])
        }
        
        self.serverHost = host
        self.serverPath = path
        self.serverPort = port
    }
}
