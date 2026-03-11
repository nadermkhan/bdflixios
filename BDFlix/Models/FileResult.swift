import Foundation

struct FileResult: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let href: String
    let fullUrl: String
    let size: String
    let sizeBytes: Int64
    let server: String
    let folder: String
    let ext: String
    
    var isMedia: Bool {
        let mediaExts: Set<String> = [
            ".mp3", ".mp4", ".mkv", ".avi", ".mov", ".flv", ".webm",
            ".flac", ".aac", ".ogg", ".wav", ".m4a", ".m4v", ".ts"
        ]
        return mediaExts.contains(ext.lowercased())
    }
    
    static let allowedExtensions: Set<String> = [
        ".mp3", ".mp4", ".mkv", ".avi", ".mov", ".wmv", ".flv", ".webm",
        ".flac", ".aac", ".ogg", ".wav", ".m4a", ".m4v", ".ts", ".iso",
        ".zip", ".rar", ".7z", ".tar", ".gz", ".exe", ".msi", ".apk",
        ".pdf", ".srt", ".sub", ".torrent"
    ]
    
    static func isAllowed(_ name: String) -> Bool {
        let ext = getExtension(name).lowercased()
        return allowedExtensions.contains(ext)
    }
    
    static func getExtension(_ name: String) -> String {
        guard let dotIndex = name.lastIndex(of: ".") else { return "" }
        return String(name[dotIndex...]).lowercased()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: FileResult, rhs: FileResult) -> Bool {
        lhs.id == rhs.id
    }
}
