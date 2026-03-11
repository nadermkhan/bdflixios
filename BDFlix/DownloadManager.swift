// BDFlix/DownloadManager.swift
import Foundation
import SwiftUI
import UserNotifications

@MainActor
class DownloadManager: NSObject, ObservableObject {
    @Published var items: [DLItem] = []
    @Published var saveDir: URL = DownloadManager.defaultDir()

    private var nextId = 1
    private var sessions: [Int: URLSession] = [:]
    private var delegates: [Int: DLDelegate] = [:]
    private var timer: Timer?

    override init() {
        super.init()
        if let bm = UserDefaults.standard.data(forKey: "savedDownloadDir") {
            var staled = false
            if let url = try? URL(resolvingBookmarkData: bm, options: .withoutUI, relativeTo: nil, bookmarkDataIsStale: &staled) {
                _ = url.startAccessingSecurityScopedResource()
                self.saveDir = url
            }
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in self.tick() }
        }
    }

    static func defaultDir() -> URL {
        let d = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Downloads")
        try? FileManager.default.createDirectory(at: d, withIntermediateDirectories: true)
        return d
    }

    func add(url: String, name: String) {
        try? FileManager.default.createDirectory(at: saveDir, withIntermediateDirectories: true)
        let save = saveDir.appendingPathComponent(StrUtil.sanitize(name))
        let item = DLItem(id: nextId, url: url, fileName: name, savePath: save)
        nextId += 1
        items.append(item)
        start(item)
    }

    func pause(_ item: DLItem) {
        item.isPaused = true
        item.task?.cancel(byProducingResumeData: { item.resumeData = $0 })
        item.state = .paused; item.speed = 0
    }

    func resume(_ item: DLItem) {
        item.isPaused = false; item.state = .downloading
        if let rd = item.resumeData, let s = sessions[item.id] {
            let t = s.downloadTask(withResumeData: rd)
            item.task = t; t.resume()
        } else { start(item) }
    }

    func cancel(_ item: DLItem) {
        item.isCancelled = true; item.task?.cancel()
        sessions[item.id]?.invalidateAndCancel()
        sessions.removeValue(forKey: item.id)
        delegates.removeValue(forKey: item.id)
        item.state = .cancelled; item.speed = 0
    }

    func remove(_ item: DLItem) {
        cancel(item)
        items.removeAll { $0.id == item.id }
    }

    func changeSaveDir(to url: URL) {
        saveDir = url
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }

    // MARK: Private

    private func start(_ item: DLItem) {
        guard let url = URL(string: item.url) else {
            item.state = .error; item.errorMsg = "Bad URL"; return
        }
        let cfg = URLSessionConfiguration.default
        cfg.timeoutIntervalForRequest = 30
        cfg.timeoutIntervalForResource = 86400
        let del = DLDelegate(item: item, mgr: self)
        delegates[item.id] = del
        let s = URLSession(configuration: cfg, delegate: del, delegateQueue: nil)
        sessions[item.id] = s
        let t = s.downloadTask(with: url)
        item.task = t; item.lastTime = Date(); item.lastBytes = 0
        item.state = .downloading
        t.resume()
    }

    private func tick() {
        let now = Date()
        for item in items where item.state == .downloading {
            guard let lt = item.lastTime else {
                item.lastTime = now; item.lastBytes = item.downloaded; continue
            }
            let el = now.timeIntervalSince(lt)
            if el > 0.3 {
                let inst = Double(item.downloaded - item.lastBytes) / el
                item.smooth = item.smooth <= 0 ? inst : item.smooth * 0.7 + inst * 0.3
                item.speed = item.smooth
                item.lastBytes = item.downloaded; item.lastTime = now
            }
        }
    }
}

// MARK: - Delegate

class DLDelegate: NSObject, URLSessionDownloadDelegate {
    weak var item: DLItem?
    weak var mgr: DownloadManager?

    init(item: DLItem, mgr: DownloadManager) {
        self.item = item; self.mgr = mgr
    }

    func urlSession(_ s: URLSession, downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo loc: URL) {
        guard let item = item else { return }
        do {
            let fm = FileManager.default
            if fm.fileExists(atPath: item.savePath.path) { try fm.removeItem(at: item.savePath) }
            try fm.moveItem(at: loc, to: item.savePath)
            DispatchQueue.main.async {
                self.mgr?.objectWillChange.send()
                item.state = .done; item.speed = 0
                if item.fileSize > 0 { item.downloaded = item.fileSize }
                self.notify(title: "Download Complete", body: item.fileName)
            }
        } catch {
            DispatchQueue.main.async {
                self.mgr?.objectWillChange.send()
                item.state = .error; item.errorMsg = error.localizedDescription
                self.notify(title: "Download Failed", body: error.localizedDescription)
            }
        }
    }

    private func notify(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let req = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(req)
    }

    func urlSession(_ s: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bw: Int64, totalBytesWritten tw: Int64,
                    totalBytesExpectedToWrite te: Int64) {
        guard let item = item else { return }
        DispatchQueue.main.async {
            item.downloaded = tw
            if te > 0 { item.fileSize = te }
        }
    }

    func urlSession(_ s: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let item = item, let e = error else { return }
        let ns = e as NSError
        DispatchQueue.main.async {
            self.mgr?.objectWillChange.send()
            if ns.code == NSURLErrorCancelled {
                if !item.isPaused && !item.isCancelled { item.state = .cancelled }
            } else {
                item.state = .error; item.errorMsg = e.localizedDescription; item.speed = 0
                self.notify(title: "Download Failed", body: "\(item.fileName)\n\(e.localizedDescription)")
            }
        }
    }
}
