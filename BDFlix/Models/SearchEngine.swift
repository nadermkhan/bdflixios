import Foundation
import Combine

struct SearchToken {
    let text: String
    let isNegated: Bool
}

class SearchEngine: ObservableObject {
    @Published var results: [FileResult] = []
    @Published var filteredResults: [FileResult] = []
    @Published var isSearching = false
    @Published var searchProgress: (done: Int, total: Int) = (0, 0)
    @Published var statusMessage = "Ready"
    @Published var sortColumn: SortColumn = .name
    @Published var sortAscending = true
    
    enum SortColumn: String, CaseIterable {
        case name = "Name"
        case size = "Size"
        case server = "Server"
        case folder = "Folder"
    }
    
    private let networkService = NetworkService()
    private var searchTasks: [Task<Void, Never>] = []
    private let resultsLock = NSLock()
    
    func search(term: String) {
        let trimmed = term.trimmingCharacters(in: .whitespaces)
        guard trimmed.count >= 2 else { return }
        
        // Cancel previous searches
        searchTasks.forEach { $0.cancel() }
        searchTasks.removeAll()
        
        isSearching = true
        results = []
        filteredResults = []
        searchProgress = (0, ServerInfo.allServers.count)
        statusMessage = "Searching..."
        
        let tokens = tokenize(trimmed)
        let servers = ServerInfo.allServers
        
        let task = Task { [weak self] in
            guard let self = self else { return }
            
            await withTaskGroup(of: [FileResult].self) { group in
                for server in servers {
                    group.addTask {
                        let results = await self.searchServer(server: server, term: trimmed, tokens: tokens)
                        await MainActor.run {
                            self.searchProgress.done += 1
                            self.statusMessage = "Searching \(self.searchProgress.done) / \(self.searchProgress.total) servers"
                        }
                        return results
                    }
                }
                
                var allResults: [FileResult] = []
                for await serverResults in group {
                    allResults.append(contentsOf: serverResults)
                }
                
                await MainActor.run {
                    self.results = allResults
                    self.applySort()
                    self.isSearching = false
                    self.statusMessage = "\(allResults.count) files found"
                }
            }
        }
        searchTasks.append(task)
    }
    
    func applySort() {
        var sorted = results
        switch sortColumn {
        case .name:
            sorted.sort { sortAscending ? $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending : $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedDescending }
        case .size:
            sorted.sort { sortAscending ? $0.sizeBytes < $1.sizeBytes : $0.sizeBytes > $1.sizeBytes }
        case .server:
            sorted.sort { sortAscending ? $0.server < $1.server : $0.server > $1.server }
        case .folder:
            sorted.sort {
                let cmp = $0.folder.localizedCaseInsensitiveCompare($1.folder)
                if cmp == .orderedSame {
                    return sortAscending ? $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending : $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedDescending
                }
                return sortAscending ? cmp == .orderedAscending : cmp == .orderedDescending
            }
        }
        filteredResults = sorted
    }
    
    func toggleSort(_ column: SortColumn) {
        if sortColumn == column {
            sortAscending.toggle()
        } else {
            sortColumn = column
            sortAscending = true
        }
        applySort()
    }
    
    // MARK: - Private
    
    private func tokenize(_ query: String) -> [SearchToken] {
        var tokens: [SearchToken] = []
        var index = query.startIndex
        
        while index < query.endIndex {
            // Skip spaces
            while index < query.endIndex && query[index] == " " {
                index = query.index(after: index)
            }
            guard index < query.endIndex else { break }
            
            var negated = false
            if query[index] == "-" {
                negated = true
                index = query.index(after: index)
            }
            
            guard index < query.endIndex else { break }
            
            var tokenText = ""
            if query[index] == "\"" {
                // Quoted phrase
                index = query.index(after: index)
                let start = index
                while index < query.endIndex && query[index] != "\"" {
                    index = query.index(after: index)
                }
                tokenText = String(query[start..<index]).lowercased()
                if index < query.endIndex { index = query.index(after: index) }
            } else {
                let start = index
                while index < query.endIndex && query[index] != " " {
                    index = query.index(after: index)
                }
                tokenText = String(query[start..<index]).lowercased()
            }
            
            if !tokenText.isEmpty {
                tokens.append(SearchToken(text: tokenText, isNegated: negated))
            }
        }
        return tokens
    }
    
    private func matchesTokens(_ name: String, _ tokens: [SearchToken]) -> Bool {
        let lower = name.lowercased()
        for token in tokens {
            let found = lower.contains(token.text)
            if token.isNegated && found { return false }
            if !token.isNegated && !found { return false }
        }
        return true
    }
    
    private func searchServer(server: ServerInfo, term: String, tokens: [SearchToken]) async -> [FileResult] {
        var pattern = term
        for token in tokens {
            if !token.isNegated {
                pattern = token.text
                break
            }
        }
        
        let body: [String: Any] = [
            "action": "get",
            "search": [
                "href": "/\(server.name)/",
                "pattern": pattern,
                "ignorecase": true
            ]
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            return []
        }
        
        let urlString = "http://\(server.host):\(server.port)\(server.path)"
        guard let url = URL(string: urlString) else { return [] }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 25
        
        do {
            let config = URLSessionConfiguration.ephemeral
            config.timeoutIntervalForRequest = 25
            config.timeoutIntervalForResource = 60
            let session = URLSession(configuration: config)
            
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                return []
            }
            
            return parseResponse(data: data, server: server, tokens: tokens)
        } catch {
            return []
        }
    }
    
    private func parseResponse(data: Data, server: ServerInfo, tokens: [SearchToken]) -> [FileResult] {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            // Try parsing as string
            guard let jsonString = String(data: data, encoding: .utf8) else { return [] }
            return parseJsonString(jsonString, server: server, tokens: tokens)
        }
        
        var results: [FileResult] = []
        for item in json {
            guard let href = item["href"] as? String else { continue }
            let decodedName = StringUtils.urlDecode(StringUtils.getName(href))
            
            guard FileResult.isAllowed(decodedName), matchesTokens(decodedName, tokens) else { continue }
            
            let sizeStr: String
            if let sizeNum = item["size"] as? Int64 {
                sizeStr = "\(sizeNum)"
            } else if let sizeString = item["size"] as? String {
                sizeStr = sizeString
            } else {
                sizeStr = ""
            }
            
            let sizeBytes = Formatters.parseSize(sizeStr)
            let ext = FileResult.getExtension(decodedName)
            let folder = StringUtils.urlDecode(StringUtils.getFolder(href))
            
            let result = FileResult(
                name: decodedName,
                href: href,
                fullUrl: "http://\(server.host)\(href)",
                size: sizeStr,
                sizeBytes: sizeBytes,
                server: server.name,
                folder: folder,
                ext: ext
            )
            results.append(result)
        }
        return results
    }
    
    private func parseJsonString(_ jsonString: String, server: ServerInfo, tokens: [SearchToken]) -> [FileResult] {
        var results: [FileResult] = []
        var searchStart = jsonString.startIndex
        
        while let openBrace = jsonString.range(of: "{", range: searchStart..<jsonString.endIndex) {
            guard let closeBrace = jsonString.range(of: "}", range: openBrace.upperBound..<jsonString.endIndex) else { break }
            
            let objectStr = String(jsonString[openBrace.lowerBound...closeBrace.lowerBound])
            
            if let href = extractJsonString(objectStr, key: "href") {
                let decodedName = StringUtils.urlDecode(StringUtils.getName(href))
                
                if FileResult.isAllowed(decodedName) && matchesTokens(decodedName, tokens) {
                    let sizeStr = extractJsonNumber(objectStr, key: "size") ?? extractJsonString(objectStr, key: "size") ?? ""
                    let sizeBytes = Formatters.parseSize(sizeStr)
                    let ext = FileResult.getExtension(decodedName)
                    let folder = StringUtils.urlDecode(StringUtils.getFolder(href))
                    
                    let result = FileResult(
                        name: decodedName,
                        href: href,
                        fullUrl: "http://\(server.host)\(href)",
                        size: sizeStr,
                        sizeBytes: sizeBytes,
                        server: server.name,
                        folder: folder,
                        ext: ext
                    )
                    results.append(result)
                }
            }
            
            searchStart = closeBrace.upperBound
        }
        return results
    }
    
    private func extractJsonString(_ json: String, key: String) -> String? {
        let searchKey = "\"\(key)\""
        guard let keyRange = json.range(of: searchKey) else { return nil }
        var idx = keyRange.upperBound
        
        // Skip whitespace and colon
        while idx < json.endIndex && (json[idx] == " " || json[idx] == ":" || json[idx] == "\t" || json[idx] == "\n") {
            idx = json.index(after: idx)
        }
        guard idx < json.endIndex && json[idx] == "\"" else { return nil }
        idx = json.index(after: idx)
        
        var result = ""
        while idx < json.endIndex && json[idx] != "\"" {
            if json[idx] == "\\" {
                idx = json.index(after: idx)
                guard idx < json.endIndex else { break }
                switch json[idx] {
                case "\"": result += "\""
                case "\\": result += "\\"
                case "/": result += "/"
                case "n": result += "\n"
                default: result.append(json[idx])
                }
            } else {
                result.append(json[idx])
            }
            idx = json.index(after: idx)
        }
        return result
    }
    
    private func extractJsonNumber(_ json: String, key: String) -> String? {
        let searchKey = "\"\(key)\""
        guard let keyRange = json.range(of: searchKey) else { return nil }
        var idx = keyRange.upperBound
        
        while idx < json.endIndex && (json[idx] == " " || json[idx] == ":" || json[idx] == "\t") {
            idx = json.index(after: idx)
        }
        guard idx < json.endIndex else { return nil }
        
        var result = ""
        while idx < json.endIndex && (json[idx].isNumber || json[idx] == ".") {
            result.append(json[idx])
            idx = json.index(after: idx)
        }
        return result.isEmpty ? nil : result
    }
    
    func generatePlaylist(folder: String, server: String) -> (url: URL, count: Int)? {
        let mediaFiles = filteredResults.filter { $0.folder == folder && $0.server == server && $0.isMedia }
        guard !mediaFiles.isEmpty else { return nil }
        
        var content = "#EXTM3U\r\n"
        for file in mediaFiles {
            content += "#EXTINF:-1,\(file.name)\r\n\(file.fullUrl)\r\n"
        }
        
        let sanitizedFolder = StringUtils.sanitizeFilename(folder)
        let fileName = "\(sanitizedFolder)_\(Int(Date().timeIntervalSince1970)).m3u8"
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent(fileName)
        
        do {
            let bom = Data([0xEF, 0xBB, 0xBF])
            var data = bom
            data.append(content.data(using: .utf8)!)
            try data.write(to: fileURL)
            return (fileURL, mediaFiles.count)
        } catch {
            return nil
        }
    }
}
