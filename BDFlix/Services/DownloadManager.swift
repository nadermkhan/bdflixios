import Foundation
import Combine

class DownloadManager: NSObject, ObservableObject {
    @Published var downloads: [DownloadTaskItem] = []
    
    private var nextId = 1
    private var activeSessions: [Int: URLSession] = [:]
    private var activeObservations: [Int: NSKeyValueObservation] = [:]
    private var updateTimer: Timer?
    
    override init() {
        super.init()
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.updateSpeeds()
        }
    }
    
    deinit {
        updateTimer?.invalidate()
    }
    
    func queueDownload(url: String, fileName: String) {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let downloadsDir = documentsURL.appendingPathComponent("Downloads")
        try? FileManager.default.createDirectory(at: downloadsDir, withIntermediateDirectories: true)
        
        let sanitized = StringUtils.sanitizeFilename(fileName)
        let savePath = downloadsDir.appendingPathComponent(sanitized)
        
        let task = DownloadTaskItem(id: nextId, url: url, fileName: fileName, savePath: savePath)
        nextId += 1
        
        DispatchQueue.main.async {
            self.downloads.append(task)
        }
        
        startDownload(task)
    }
    
    func pauseDownload(_ task: DownloadTaskItem) {
        task.isPaused = true
        task.urlSessionTask?.cancel(byProducingResumeData: { data in
            task.resumeData = data
        })
        DispatchQueue.main.async {
            task.state = .paused
            task.speed = 0
        }
    }
    
    func resumeDownload(_ task: DownloadTaskItem) {
        task.isPaused = false
        DispatchQueue.main.async {
            task.state = .downloading
        }
        
        if let resumeData = task.resumeData,
           let session = activeSessions[task.id] {
            let downloadTask = session.downloadTask(withResumeData: resumeData)
            task.urlSessionTask = downloadTask
            observeProgress(downloadTask, for: task)
            downloadTask.resume()
        } else {
            startDownload(task)
        }
    }
    
    func cancelDownload(_ task: DownloadTaskItem) {
        task.isCancelled = true
        task.urlSessionTask?.cancel()
        activeObservations[task.id]?.invalidate()
        activeObservations.removeValue(forKey: task.id)
        activeSessions[task.id]?.invalidateAndCancel()
        activeSessions.removeValue(forKey: task.id)
        DispatchQueue.main.async {
            task.state = .cancelled
            task.speed = 0
        }
    }
    
    func removeDownload(_ task: DownloadTaskItem) {
        cancelDownload(task)
        DispatchQueue.main.async {
            self.downloads.removeAll { $0.id == task.id }
        }
    }
    
    func openDownloadsFolder() {
        // On iOS, we can share the file or open Files app
    }
    
    var downloadsDirectory: URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsURL.appendingPathComponent("Downloads")
    }
    
    // MARK: - Private
    
    private func startDownload(_ task: DownloadTaskItem) {
        guard let url = URL(string: task.url) else {
            DispatchQueue.main.async {
                task.state = .error
                task.errorMessage = "Invalid URL"
            }
            return
        }
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 3600 * 24 // 24 hours for large files
        
        let delegate = DownloadDelegate(task: task, manager: self)
        let session = URLSession(configuration: config, delegate: delegate, delegateQueue: nil)
        activeSessions[task.id] = session
        
        let downloadTask = session.downloadTask(with: url)
        task.urlSessionTask = downloadTask
        task.startTime = Date()
        task.lastTime = Date()
        task.lastBytes = 0
        
        DispatchQueue.main.async {
            task.state = .downloading
        }
        
        observeProgress(downloadTask, for: task)
        downloadTask.resume()
    }
    
    private func observeProgress(_ downloadTask: URLSessionDownloadTask, for task: DownloadTaskItem) {
        let observation = downloadTask.progress.observe(\.fractionCompleted) { [weak task] progress, _ in
            guard let task = task else { return }
            let downloaded = Int64(progress.fractionCompleted * Double(max(task.fileSize, progress.totalUnitCount)))
            DispatchQueue.main.async {
                task.totalDownloaded = downloaded
                if task.fileSize <= 0 {
                    task.fileSize = progress.totalUnitCount
                }
            }
        }
        activeObservations[task.id] = observation
    }
    
    private func updateSpeeds() {
        let now = Date()
        for task in downloads where task.state == .downloading {
            guard let lastTime = task.lastTime else {
                task.lastTime = now
                task.lastBytes = task.totalDownloaded
                continue
            }
            
            let elapsed = now.timeIntervalSince(lastTime)
            if elapsed > 0.1 {
                let bytesInInterval = task.totalDownloaded - task.lastBytes
                let instantSpeed = Double(bytesInInterval) / elapsed
                task.smoothSpeed = task.smoothSpeed <= 0 ? instantSpeed : task.smoothSpeed * 0.7 + instantSpeed * 0.3
                DispatchQueue.main.async {
                    task.speed = task.smoothSpeed
                }
            }
            task.lastBytes = task.totalDownloaded
            task.lastTime = now
        }
    }
}

// MARK: - Download Delegate

class DownloadDelegate: NSObject, URLSessionDownloadDelegate {
    weak var task: DownloadTaskItem?
    weak var manager: DownloadManager?
    
    init(task: DownloadTaskItem, manager: DownloadManager) {
        self.task = task
        self.manager = manager
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let task = task else { return }
        
        do {
            if FileManager.default.fileExists(atPath: task.savePath.path) {
                try FileManager.default.removeItem(at: task.savePath)
            }
            try FileManager.default.moveItem(at: location, to: task.savePath)
            
            DispatchQueue.main.async {
                task.state = .complete
                task.speed = 0
                if task.fileSize > 0 {
                    task.totalDownloaded = task.fileSize
                }
            }
        } catch {
            DispatchQueue.main.async {
                task.state = .error
                task.errorMessage = error.localizedDescription
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let task = task else { return }
        DispatchQueue.main.async {
            task.totalDownloaded = totalBytesWritten
            if totalBytesExpectedToWrite > 0 {
                task.fileSize = totalBytesExpectedToWrite
            }
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let downloadTask = self.task else { return }
        
        if let error = error {
            let nsError = error as NSError
            if nsError.code == NSURLErrorCancelled {
                // Don't mark as error if user cancelled or paused
                if !downloadTask.isPaused && !downloadTask.isCancelled {
                    DispatchQueue.main.async {
                        downloadTask.state = .cancelled
                    }
                }
            } else {
                DispatchQueue.main.async {
                    downloadTask.state = .error
                    downloadTask.errorMessage = error.localizedDescription
                    downloadTask.speed = 0
                }
            }
        }
    }
}
