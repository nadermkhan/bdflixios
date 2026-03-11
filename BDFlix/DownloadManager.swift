// BDFlix/DownloadManager.swift
import Foundation
import SwiftUI
import UserNotifications

@MainActor
class DownloadManager: NSObject, ObservableObject, URLSessionDownloadDelegate {
    @Published var items: [DLItem] = []
    @Published var saveDir: URL = DownloadManager.defaultDir()

    private var nextId = 1
    private var session: URLSession!
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
        
        let cfg = URLSessionConfiguration.background(withIdentifier: "BDFlixBackground")
        cfg.timeoutIntervalForRequest = 30
        cfg.timeoutIntervalForResource = 86400
        
        // URLSession configuration and init
        
        self.session = URLSession(configuration: cfg, delegate: self, delegateQueue: nil)
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in self.tick() }
        }
        
        Task { await restoreExistingTasks() }
    }
    
    // Quick struct to serialize DLItem essential info into taskDescription
    private struct DLTaskMeta: Codable {
        let id: Int
        let url: String
        let fileName: String
        let savePath: URL
    }
    
    private func restoreExistingTasks() async {
        let tasks = await session.allTasks
        for task in tasks {
            guard let dlTask = task as? URLSessionDownloadTask,
                  let desc = task.taskDescription,
                  let data = desc.data(using: .utf8),
                  let meta = try? JSONDecoder().decode(DLTaskMeta.self, from: data) else { continue }
            
            let item = DLItem(id: meta.id, url: meta.url, fileName: meta.fileName, savePath: meta.savePath)
            item.task = dlTask
            if item.id >= nextId { nextId = item.id + 1 }
            
            switch task.state {
            case .running: item.state = .downloading
            case .suspended: item.state = .paused
            case .canceling: item.state = .cancelled
            case .completed:
                if let err = task.error {
                    item.state = .error
                    item.errorMsg = err.localizedDescription
                } else {
                    item.state = .done
                    item.downloaded = item.fileSize > 0 ? item.fileSize : task.countOfBytesReceived
                }
            @unknown default: item.state = .queued
            }
            
            items.append(item)
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
        objectWillChange.send()
        item.isPaused = true
        item.task?.cancel(byProducingResumeData: { item.resumeData = $0 })
        item.state = .paused; item.speed = 0
    }

    func resume(_ item: DLItem) {
        objectWillChange.send()
        item.isPaused = false; item.state = .downloading
        if let rd = item.resumeData {
            let t = session.downloadTask(withResumeData: rd)
            item.task = t;
            setTaskMeta(for: t, from: item)
            t.resume()
        } else { start(item) }
    }

    func cancel(_ item: DLItem) {
        objectWillChange.send()
        item.isCancelled = true; item.task?.cancel()
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

    private func setTaskMeta(for task: URLSessionTask, from item: DLItem) {
        let meta = DLTaskMeta(id: item.id, url: item.url, fileName: item.fileName, savePath: item.savePath)
        if let data = try? JSONEncoder().encode(meta) {
            task.taskDescription = String(data: data, encoding: .utf8)
        }
    }

    private func start(_ item: DLItem) {
        guard let url = URL(string: item.url) else {
            item.state = .error; item.errorMsg = "Bad URL"; return
        }
        let t = session.downloadTask(with: url)
        setTaskMeta(for: t, from: item)
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

    // MARK: - URLSessionDelegate
    
    private func itemForTask(_ task: URLSessionTask) -> DLItem? {
        guard let desc = task.taskDescription,
              let data = desc.data(using: .utf8),
              let meta = try? JSONDecoder().decode(DLTaskMeta.self, from: data) else { return nil }
        return items.first { $0.id == meta.id }
    }

    nonisolated func urlSession(_ s: URLSession, downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo loc: URL) {
        Task { @MainActor in
            guard let item = self.itemForTask(downloadTask) else { return }
            do {
                let fm = FileManager.default
                if fm.fileExists(atPath: item.savePath.path) { try fm.removeItem(at: item.savePath) }
                try fm.moveItem(at: loc, to: item.savePath)
                self.objectWillChange.send()
                item.state = .done; item.speed = 0
                if item.fileSize > 0 { item.downloaded = item.fileSize }
                self.notify(title: "Download Complete", body: item.fileName)
            } catch {
                self.objectWillChange.send()
                item.state = .error; item.errorMsg = error.localizedDescription
                self.notify(title: "Download Failed", body: error.localizedDescription)
            }
        }
    }

    private nonisolated func notify(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let req = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(req)
    }

    nonisolated func urlSession(_ s: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bw: Int64, totalBytesWritten tw: Int64,
                    totalBytesExpectedToWrite te: Int64) {
        Task { @MainActor in
            guard let item = self.itemForTask(downloadTask) else { return }
            item.downloaded = tw
            if te > 0 { item.fileSize = te }
        }
    }

    nonisolated func urlSession(_ s: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        Task { @MainActor in
            guard let item = self.itemForTask(task), let e = error else { return }
            let ns = e as NSError
            self.objectWillChange.send()
            if ns.code == NSURLErrorCancelled {
                if !item.isPaused && !item.isCancelled { item.state = .cancelled }
            } else {
                item.state = .error; item.errorMsg = e.localizedDescription; item.speed = 0
                self.notify(title: "Download Failed", body: "\(item.fileName)\n\(e.localizedDescription)")
            }
        }
    }

    nonisolated func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        Task { @MainActor in
            if let ad = UIApplication.shared.delegate as? AppDelegate,
               let completion = ad.bgSessionCompletionHandler {
                ad.bgSessionCompletionHandler = nil
                completion()
            }
        }
    }
}
