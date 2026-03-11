import SwiftUI

struct FileResultRow: View {
    @EnvironmentObject var themeManager: ThemeManager
    let file: FileResult
    let isAlternate: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            // File icon + name
            HStack(spacing: 8) {
                Image(systemName: fileIcon)
                    .font(.system(size: 12))
                    .foregroundColor(file.isMedia ? themeManager.accent : themeManager.dim)
                    .frame(width: 16)
                
                Text(file.name)
                    .font(.system(size: 13))
                    .foregroundColor(file.isMedia ? themeManager.accent : themeManager.textColor)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Size
            Text(Formatters.formatSize(file.sizeBytes))
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(themeManager.secondary)
                .frame(width: 80, alignment: .trailing)
            
            // Server
            Text(file.server)
                .font(.system(size: 11))
                .foregroundColor(themeManager.warm)
                .frame(width: 90, alignment: .leading)
                .padding(.leading, 8)
            
            // Folder
            Text(file.folder)
                .font(.system(size: 11))
                .foregroundColor(themeManager.dim)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(width: 80, alignment: .leading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(isAlternate ? themeManager.cardAlt : themeManager.card)
    }
    
    private var fileIcon: String {
        let ext = file.ext.lowercased()
        switch ext {
        case ".mp4", ".mkv", ".avi", ".mov", ".flv", ".webm", ".m4v", ".ts":
            return "film"
        case ".mp3", ".flac", ".aac", ".ogg", ".wav", ".m4a":
            return "music.note"
        case ".zip", ".rar", ".7z", ".tar", ".gz":
            return "doc.zipper"
        case ".pdf":
            return "doc.text"
        case ".srt", ".sub":
            return "captions.bubble"
        case ".iso":
            return "opticaldiscsymbol"
        case ".exe", ".msi", ".apk":
            return "app"
        case ".torrent":
            return "arrow.triangle.2.circlepath"
        default:
            return "doc"
        }
    }
}
