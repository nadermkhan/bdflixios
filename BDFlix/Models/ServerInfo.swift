import Foundation

struct ServerInfo: Identifiable, Sendable {
    let id = UUID()
    let name: String
    let host: String
    let path: String
    let port: Int
    
    static let allServers: [ServerInfo] = [
        ServerInfo(name: "DHAKA-FLIX-7", host: "172.16.50.7", path: "/DHAKA-FLIX-7/", port: 80),
        ServerInfo(name: "DHAKA-FLIX-8", host: "172.16.50.8", path: "/DHAKA-FLIX-8/", port: 80),
        ServerInfo(name: "DHAKA-FLIX-9", host: "172.16.50.9", path: "/DHAKA-FLIX-9/", port: 80),
        ServerInfo(name: "DHAKA-FLIX-12", host: "172.16.50.12", path: "/DHAKA-FLIX-12/", port: 80),
        ServerInfo(name: "DHAKA-FLIX-14", host: "172.16.50.14", path: "/DHAKA-FLIX-14/", port: 80),
    ]
}
