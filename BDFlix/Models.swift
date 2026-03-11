// BDFlix/Models.swift
import Foundation

// MARK: - Server

struct ServerInfo: Identifiable {
    let id = UUID()
    let name: String
    let host: String
    let path: String
    let port: Int

    static let all: [ServerInfo] = [
        .init(name: "DHAKA-FLIX-7",  host: "172.16.50.7",  path: "/DHAKA-FLIX-7/",  port: 80),
        .init(name: "DHAKA-FLIX-8",  host: "172.16.50.8",  path: "/DHAKA-FLIX-8/",  port: 80),
        .init(name: "DHAKA-FLIX-9",  host: "172.16.50.9",  path: "/DHAKA-FLIX-9/",  port: 80),
        .init(name: "DHAKA-FLIX-12", host: "172.16.50.12", path: "/DHAKA-FLIX-12/", port: 80),
        .init(name: "DHAKA-FLIX-14", host: "172.16.50.14", path: "/DHAKA-FLIX-14/", port: 80),
    ]
}

// MARK: - File Result

struct FileResult: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let href: String
    let fullUrl: String
    let sizeBytes: Int64
    let server: String
    let folder: String

    var ext: String { Self.ext(name) }
    var isMedia: Bool { Self.mediaExts.contains(ext) }

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (a: FileResult, b: FileResult) -> Bool { a.id == b.id }

    static func ext(_ n: String) -> String {
        guard let d = n.lastIndex(of: ".") else { return "" }
        return String(n[d...]).lowercased()
    }

    private static let mediaExts: Set<String> = [
        ".mp3",".mp4",".mkv",".avi",".mov",".flv",".webm",
        ".flac",".aac",".ogg",".wav",".m4a",".m4v",".ts"
    ]

    static let allowedExts: Set<String> = [
        ".mp3",".mp4",".mkv",".avi",".mov",".wmv",".flv",".webm",
        ".flac",".aac",".ogg",".wav",".m4a",".m4v",".ts",".iso",
        ".zip",".rar",".7z",".tar",".gz",".exe",".msi",".apk",
        ".pdf",".srt",".sub",".torrent"
    ]

    static func allowed(_ n: String) -> Bool { allowedExts.contains(ext(n)) }
}

// MARK: - Download State

enum DLState: String {
    case queued      = "Queued"
    case downloading = "Downloading"
    case paused      = "Paused"
    case done        = "Complete"
    case error       = "Error"
    case cancelled   = "Cancelled"
}

// MARK: - Download Item

class DLItem: ObservableObject, Identifiable {
    let id: Int
    let url: String
    let fileName: String
    var savePath: URL

    @Published var fileSize: Int64 = -1
    @Published var downloaded: Int64 = 0
    @Published var state: DLState = .queued
    @Published var speed: Double = 0
    @Published var errorMsg = ""

    var isPaused = false
    var isCancelled = false
    var task: URLSessionDownloadTask?
    var resumeData: Data?
    var lastBytes: Int64 = 0
    var lastTime: Date?
    var smooth: Double = 0

    var progress: Double {
        guard fileSize > 0 else { return 0 }
        return min(1, Double(downloaded) / Double(fileSize))
    }

    var eta: String {
        guard speed > 0, fileSize > 0 else { return "—" }
        let rem = fileSize - downloaded
        let s = Int(Double(rem) / speed)
        if s < 60 { return "\(s)s" }
        if s < 3600 { return "\(s/60)m \(s%60)s" }
        return "\(s/3600)h \((s%3600)/60)m"
    }

    init(id: Int, url: String, fileName: String, savePath: URL) {
        self.id = id; self.url = url; self.fileName = fileName; self.savePath = savePath
    }
}

// MARK: - Helpers

enum Fmt {
    static func size(_ b: Int64) -> String {
        if b < 0 { return "—" }
        if b < 1024 { return "\(b) B" }
        if b < 1_048_576 { return String(format: "%.1f KB", Double(b)/1024) }
        if b < 1_073_741_824 { return String(format: "%.1f MB", Double(b)/1_048_576) }
        return String(format: "%.2f GB", Double(b)/1_073_741_824)
    }

    static func speed(_ bps: Double) -> String {
        if bps <= 0 { return "—" }
        if bps < 1024 { return String(format: "%.0f B/s", bps) }
        if bps < 1_048_576 { return String(format: "%.1f KB/s", bps/1024) }
        return String(format: "%.1f MB/s", bps/1_048_576)
    }

    static func parseSize(_ s: String) -> Int64 {
        let t = s.trimmingCharacters(in: .whitespaces)
        guard !t.isEmpty else { return -1 }
        var ns = "", us = ""
        var seenNum = false
        for c in t {
            if c.isNumber || c == "." { ns.append(c); seenNum = true }
            else if seenNum { us.append(c) }
        }
        guard let v = Double(ns) else { return -1 }
        let u = us.lowercased().trimmingCharacters(in: .whitespaces)
        if u.contains("tb") { return Int64(v * 1_099_511_627_776) }
        if u.contains("gb") { return Int64(v * 1_073_741_824) }
        if u.contains("mb") { return Int64(v * 1_048_576) }
        if u.contains("kb") { return Int64(v * 1024) }
        return Int64(v)
    }
}

enum StrUtil {
    static func urlDec(_ s: String) -> String { s.removingPercentEncoding ?? s }

    static func name(_ href: String) -> String {
        var s = href
        if s.hasSuffix("/") { s = String(s.dropLast()) }
        if let i = s.lastIndex(of: "/") { return String(s[s.index(after: i)...]) }
        return s
    }

    static func folder(_ href: String) -> String {
        var s = href
        if s.hasSuffix("/") { s = String(s.dropLast()) }
        guard let li = s.lastIndex(of: "/") else { return "Root" }
        let par = String(s[..<li])
        if let pi = par.lastIndex(of: "/") { return String(par[par.index(after: pi)...]) }
        return par.isEmpty ? "Root" : par
    }

    static func sanitize(_ n: String) -> String {
        let bad = CharacterSet(charactersIn: "\\/:*?\"<>|")
        return n.components(separatedBy: bad).joined(separator: "_")
    }
}
