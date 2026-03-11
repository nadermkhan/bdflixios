import SwiftUI

struct DownloadRow: View {
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var task: DownloadTaskItem
    let isAlternate: Bool
    
    var body: some View {
        VStack(spacing: 6) {
            HStack {
                // File name
                VStack(alignment: .leading, spacing: 2) {
                    Text(task.fileName)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(themeManager.accent)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    
                    HStack(spacing: 12) {
                        // Size
                        Text(sizeText)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(themeManager.secondary)
                        
                        // Speed
                        if task.state == .downloading {
                            Text(Formatters.formatSpeed(task.speed))
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(themeManager.secondary)
                        }
                        
                        // ETA
                        if task.state == .downloading && task.fileSize > 0 && task.speed > 0 {
                            Text(task.eta)
                                .font(.system(size: 11))
                                .foregroundColor(themeManager.dim)
                        }
                    }
                }
                
                Spacer()
                
                // Status
                VStack(alignment: .trailing, spacing: 2) {
                    Label(task.state.rawValue, systemImage: task.state.icon)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(statusColor)
                    
                    if task.fileSize > 0 {
                        Text("\(Int(task.progress * 100))%")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(progressColor)
                    }
                }
            }
            
            // Progress bar
            if task.state == .downloading || task.state == .paused {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(themeManager.progressBackground)
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(progressBarColor)
                            .frame(width: geometry.size.width * task.progress)
                    }
                }
                .frame(height: 4)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(isAlternate ? themeManager.cardAlt : themeManager.card)
    }
    
    private var sizeText: String {
        if task.fileSize > 0 {
            return "\(Formatters.formatSize(task.totalDownloaded)) / \(Formatters.formatSize(task.fileSize))"
        }
        return Formatters.formatSize(task.totalDownloaded)
    }
    
    private var statusColor: Color {
        switch task.state {
        case .downloading: return themeManager.green
        case .paused: return themeManager.yellow
        case .complete: return themeManager.green
        case .error, .cancelled: return themeManager.red
        case .queued: return themeManager.dim
        }
    }
    
    private var progressColor: Color {
        switch task.state {
        case .complete: return themeManager.green
        case .error: return themeManager.red
        default: return themeManager.warm
        }
    }
    
    private var progressBarColor: Color {
        switch task.state {
        case .paused: return themeManager.yellow
        default: return themeManager.primary
        }
    }
}
