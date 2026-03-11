// BDFlix/SearchEngine.swift
import Foundation

struct Token { let text: String; let neg: Bool }

@MainActor
class SearchEngine: ObservableObject {
    @Published var results: [FileResult] = []
    @Published var isSearching = false
    @Published var progress = ""

    private var job: Task<Void, Never>?

    func search(_ term: String) {
        let q = term.trimmingCharacters(in: .whitespaces)
        guard q.count >= 2 else { return }
        job?.cancel()
        isSearching = true
        results = []
        progress = "0/\(ServerInfo.all.count)"
        let tokens = tokenize(q)

        job = Task {
            var done = 0
            var all: [FileResult] = []

            await withTaskGroup(of: [FileResult].self) { group in
                for srv in ServerInfo.all {
                    group.addTask { [tokens] in
                        await self.query(srv, q, tokens)
                    }
                }
                for await batch in group {
                    all.append(contentsOf: batch)
                    all.sort {
                        let c = $0.folder.localizedCaseInsensitiveCompare($1.folder)
                        return c == .orderedSame
                            ? $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
                            : c == .orderedAscending
                    }
                    self.results = all
                    done += 1
                    self.progress = "\(done)/\(ServerInfo.all.count)"
                }
            }

            isSearching = false
            progress = "\(all.count) files"
        }
    }

    // MARK: - Private

    private nonisolated func tokenize(_ q: String) -> [Token] {
        var tokens: [Token] = []
        let chars = Array(q)
        var i = 0
        while i < chars.count {
            while i < chars.count && chars[i] == " " { i += 1 }
            guard i < chars.count else { break }
            var neg = false
            if chars[i] == "-" {
                neg = true
                i += 1
            }
            guard i < chars.count else { break }
            var txt = ""
            if chars[i] == "\"" {
                i += 1
                let s = i
                while i < chars.count && chars[i] != "\"" { i += 1 }
                txt = String(chars[s..<i]).lowercased()
                if i < chars.count { i += 1 }
            } else {
                let s = i
                while i < chars.count && chars[i] != " " { i += 1 }
                txt = String(chars[s..<i]).lowercased()
            }
            if !txt.isEmpty { tokens.append(Token(text: txt, neg: neg)) }
        }
        return tokens
    }

    private nonisolated func matches(_ name: String, _ tokens: [Token]) -> Bool {
        let lo = name.lowercased()
        for t in tokens {
            let f = lo.contains(t.text)
            if t.neg && f { return false }
            if !t.neg && !f { return false }
        }
        return true
    }

    private nonisolated func query(_ srv: ServerInfo, _ term: String, _ tokens: [Token]) async -> [FileResult] {
        var pat = term
        for t in tokens where !t.neg { pat = t.text; break }
        if pat.isEmpty { pat = term.trimmingCharacters(in: .whitespaces) }

        let body: [String: Any] = [
            "action": "get",
            "search": [
                "href": "/\(srv.name)/",
                "pattern": pat,
                "ignorecase": true
            ]
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body),
              let url = URL(string: "http://\(srv.host):\(srv.port)\(srv.path)") else { return [] }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.httpBody = jsonData
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.timeoutInterval = 25

        do {
            let config = URLSessionConfiguration.ephemeral
            config.timeoutIntervalForRequest = 25
            config.timeoutIntervalForResource = 60
            let session = URLSession(configuration: config)

            let (data, resp) = try await session.data(for: req)
            guard (resp as? HTTPURLResponse)?.statusCode == 200 else { return [] }
            return parse(data, srv, tokens)
        } catch { return [] }
    }

    private nonisolated func parse(_ data: Data, _ srv: ServerInfo, _ tokens: [Token]) -> [FileResult] {
        guard let arr = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            guard let str = String(data: data, encoding: .utf8) else { return [] }
            return parseJsonString(str, srv, tokens)
        }
        return arr.compactMap { item -> FileResult? in
            guard let href = item["href"] as? String else { return nil }
            let dn = StrUtil.urlDec(StrUtil.name(href))
            guard FileResult.allowed(dn), matches(dn, tokens) else { return nil }
            let ss: String
            if let n = item["size"] as? NSNumber { ss = n.stringValue }
            else if let s = item["size"] as? String { ss = s }
            else { ss = "" }
            return FileResult(
                name: dn, href: href,
                fullUrl: "http://\(srv.host)\(href)",
                sizeBytes: Fmt.parseSize(ss),
                server: srv.name,
                folder: StrUtil.urlDec(StrUtil.folder(href))
            )
        }
    }

    private nonisolated func parseJsonString(_ jsonString: String, _ srv: ServerInfo, _ tokens: [Token]) -> [FileResult] {
        var results: [FileResult] = []
        var searchStart = jsonString.startIndex
        
        while let openBrace = jsonString.range(of: "{", range: searchStart..<jsonString.endIndex) {
            guard let closeBrace = jsonString.range(of: "}", range: openBrace.upperBound..<jsonString.endIndex) else { break }
            let objectStr = String(jsonString[openBrace.lowerBound...closeBrace.lowerBound])
            
            if let href = extractJsonString(objectStr, key: "href") {
                let dn = StrUtil.urlDec(StrUtil.name(href))
                if FileResult.allowed(dn) && matches(dn, tokens) {
                    let sizeStr = extractJsonNumber(objectStr, key: "size") ?? extractJsonString(objectStr, key: "size") ?? ""
                    results.append(FileResult(
                        name: dn,
                        href: href,
                        fullUrl: "http://\(srv.host)\(href)",
                        sizeBytes: Fmt.parseSize(sizeStr),
                        server: srv.name,
                        folder: StrUtil.urlDec(StrUtil.folder(href))
                    ))
                }
            }
            searchStart = closeBrace.upperBound
        }
        return results
    }

    private nonisolated func extractJsonString(_ json: String, key: String) -> String? {
        let searchKey = "\"\(key)\""
        guard let keyRange = json.range(of: searchKey) else { return nil }
        var idx = keyRange.upperBound
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

    private nonisolated func extractJsonNumber(_ json: String, key: String) -> String? {
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
}
