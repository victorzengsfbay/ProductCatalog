//
//  DownloadManager.swift
//  ProductCatalog
//
//

import Foundation

protocol CSVDownloadWatcher: AnyObject {
    func finishDownloading(_ status: Bool)
    func downloadProgress(_ progress: Float, _ bytes: Int, _ total: Int)
    func csvFileWillStartDownload()
}

class CSVDownloadManager: NSObject {
    static var shared = CSVDownloadManager()
    private var urlSession: URLSession!
    var tasks: [URLSessionTask] = []
    var targetURL: URL?
    weak var delegate: CSVDownloadWatcher?

    override private init() {
        super.init()

        let config = URLSessionConfiguration.background(withIdentifier: "\(Bundle.main.bundleIdentifier!).background")
        self.urlSession = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
        self.urlSession.getAllTasks { tasks in
            DispatchQueue.main.async {
                self.tasks = tasks
            }
        }
    }

    func startDownload(source url: URL, target fileURL: URL, watcher: CSVDownloadWatcher?) -> URLSessionDownloadTask {
        self.delegate = watcher

        let task = self.urlSession.downloadTask(with: url)
        self.targetURL = fileURL
        task.resume()
        self.tasks.append(task)
        self.delegate?.csvFileWillStartDownload()

        return task
    }

    private func cleanup(_ task: URLSessionTask) {
        for (i, t) in self.tasks.enumerated() {
            if t === task {
                t.cancel()
                self.tasks.remove(at: i)
                break
            }
        }
    }

    static func defaultLocalFileURL() -> URL? {
        return try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(Constants.CSVFile.productCatalogFilePath)
    }
}

extension CSVDownloadManager: URLSessionDelegate, URLSessionDownloadDelegate {
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        self.delegate?.downloadProgress(Float(downloadTask.progress.fractionCompleted), Int(totalBytesWritten), Int(totalBytesExpectedToWrite))
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        if let target = self.targetURL {
            let fileManager = FileManager.default
            try? fileManager.removeItem(at: target)
            do {
                try fileManager.copyItem(at: location, to: target)
                UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: Constants.UserDefaultsKey.csvFileCreationTimestamp)
                self.delegate?.finishDownloading(true)
            } catch {
                self.delegate?.finishDownloading(false)
            }
        } else {
            self.delegate?.finishDownloading(false)
        }
        self.cleanup(downloadTask)
    }

    func urlSession(_: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            debugPrint(task.debugDescription)
            debugPrint(error.localizedDescription)
            self.delegate?.finishDownloading(false)
            self.cleanup(task)
        }
    }
}
