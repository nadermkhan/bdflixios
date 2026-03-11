import Foundation

struct StringUtils {
    static func urlDecode(_ string: String) -> String {
        return string.removingPercentEncoding ?? string
    }
    
    static func getName(_ href: String) -> String {
        var s = href
        if s.hasSuffix("/") { s = String(s.dropLast()) }
        if let lastSlash = s.lastIndex(of: "/") {
            return String(s[s.index(after: lastSlash)...])
        }
        return s
    }
    
    static func getFolder(_ href: String) -> String {
        var s = href
        if s.hasSuffix("/") { s = String(s.dropLast()) }
        guard let lastSlash = s.lastIndex(of: "/") else { return "Root" }
        let parent = String(s[s.startIndex..<lastSlash])
        if let parentSlash = parent.lastIndex(of: "/") {
            return String(parent[parent.index(after: parentSlash)...])
        }
        return parent.isEmpty ? "Root" : parent
    }
    
    static func sanitizeFilename(_ name: String) -> String {
        let invalidChars = CharacterSet(charactersIn: "\\/:*?\"<>|")
        return name.components(separatedBy: invalidChars).joined(separator: "_")
    }
    
    static func getExtension(_ name: String) -> String {
        guard let dotIndex = name.lastIndex(of: ".") else { return "" }
        return String(name[dotIndex...]).lowercased()
    }
}
