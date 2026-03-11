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
                    done += 1
                    progress = "\(done)/\(ServerInfo.all.count)"
                }
            }

            all.sort {
                let c = $0.folder.localizedCaseInsensitiveCompare($1.folder)
                return c == .orderedSame
                    ? $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
                    : c == .orderedAscending
            }

            results = all
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

        guard let url = URL(string: "http://\(srv.host):\(srv.port)\(srv.path)") else { return [] }
        
        let safePat = pat.replacingOccurrences(of: "\"", with: "\\\"")
        let searchJson = "[{\"href\":\"/\(srv.name)/\",\"pattern\":\"\(safePat)\",\"ignorecase\":true}]"
        
        var comps = URLComponents()
        comps.queryItems = [
            URLQueryItem(name: "action", value: "get"),
            URLQueryItem(name: "search", value: searchJson)
        ]
        
        guard let bodyString = comps.percentEncodedQuery,
              let bodyData = bodyString.data(using: .utf8) else { return [] }

        var req = URLRequest(url: url, timeoutInterval: 25)
        req.httpMethod = "POST"
        req.httpBody = bodyData
        req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        do {
            let (data, resp) = try await URLSession.shared.data(for: req)
            guard (resp as? HTTPURLResponse)?.statusCode == 200 else { return [] }
            return parse(data, srv, tokens)
        } catch { return [] }
    }

    private nonisolated func parse(_ data: Data, _ srv: ServerInfo, _ tokens: [Token]) -> [FileResult] {
        guard let arr = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else { return [] }
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
}
