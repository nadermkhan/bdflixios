import Foundation

struct Formatters {
    static func formatSize(_ bytes: Int64) -> String {
        if bytes < 0 { return "—" }
        if bytes < 1024 { return "\(bytes) B" }
        if bytes < 1_048_576 { return String(format: "%.1f KB", Double(bytes) / 1024.0) }
        if bytes < 1_073_741_824 { return String(format: "%.1f MB", Double(bytes) / 1_048_576.0) }
        return String(format: "%.2f GB", Double(bytes) / 1_073_741_824.0)
    }
    
    static func formatSpeed(_ bytesPerSecond: Double) -> String {
        if bytesPerSecond <= 0 { return "0 B/s" }
        if bytesPerSecond < 1024 { return String(format: "%.0f B/s", bytesPerSecond) }
        if bytesPerSecond < 1_048_576 { return String(format: "%.1f KB/s", bytesPerSecond / 1024.0) }
        if bytesPerSecond < 1_073_741_824 { return String(format: "%.1f MB/s", bytesPerSecond / 1_048_576.0) }
        return String(format: "%.2f GB/s", bytesPerSecond / 1_073_741_824.0)
    }
    
    static func formatETA(remaining: Int64, speed: Double) -> String {
        guard speed > 0, remaining > 0 else { return "—" }
        let seconds = Int(Double(remaining) / speed)
        if seconds < 60 { return "\(seconds)s" }
        if seconds < 3600 { return "\(seconds / 60)m \(seconds % 60)s" }
        return "\(seconds / 3600)h \((seconds % 3600) / 60)m"
    }
    
    static func parseSize(_ sizeString: String) -> Int64 {
        let trimmed = sizeString.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return -1 }
        
        var numStr = ""
        var unitStr = ""
        var foundNumber = false
        
        for char in trimmed {
            if char.isNumber || char == "." {
                numStr.append(char)
                foundNumber = true
            } else if foundNumber {
                unitStr.append(char)
            }
        }
        
        guard let value = Double(numStr) else { return -1 }
        
        let unit = unitStr.trimmingCharacters(in: .whitespaces).lowercased()
        
        if unit.contains("tb") { return Int64(value * 1_099_511_627_776) }
        if unit.contains("gb") { return Int64(value * 1_073_741_824) }
        if unit.contains("mb") { return Int64(value * 1_048_576) }
        if unit.contains("kb") { return Int64(value * 1024) }
        
        return Int64(value)
    }
}
