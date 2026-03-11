import Foundation

actor ConnectionPool {
    static let shared = ConnectionPool()
    
    private var sessions: [String: URLSession] = [:]
    
    func session(for host: String, port: Int) -> URLSession {
        let key = "\(host):\(port)"
        if let existing = sessions[key] {
            return existing
        }
        
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 25
        config.httpMaximumConnectionsPerHost = 8
        config.httpShouldUsePipelining = true
        
        let session = URLSession(configuration: config)
        sessions[key] = session
        return session
    }
    
    func flush() {
        for (_, session) in sessions {
            session.invalidateAndCancel()
        }
        sessions.removeAll()
    }
}
