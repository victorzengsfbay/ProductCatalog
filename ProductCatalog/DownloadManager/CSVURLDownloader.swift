//
//  CSVURLDownloader.swift
//  ProductCatalog
//
//  Created by Victor Zeng on 7/20/22.
//

import UIKit
import Combine

class CSVURLDownloader: NSObject {
    //result file URL
    var resultURL: URL!
    @Published var state: (done: Bool, url: URL?, written: Int64, total: Int64) = (done: false,
                                                                                   url: nil,
                                                                                   written: 0,
                                                                                   total: 0)
    
    lazy var session: URLSession = {
        .init(configuration: .default, delegate: self, delegateQueue: nil)
    }()
    
    override init() {
        super.init()
    }
    
    func startDownload(_ sourceURL: URL, _ targetURL: URL? = nil) {
        self.resultURL = targetURL ?? CSVURLDownloader.defaultLocalFileURL()
        let task = session.downloadTask(with: sourceURL)
        task.resume()
    }
    
    static func defaultLocalFileURL() -> URL? {
        return try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(Constants.CSVFile.productCatalogFilePath)
    }
}

extension CSVURLDownloader: URLSessionDelegate, URLSessionDownloadDelegate {
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        state = (done: false,
                 url: nil,
                 written: totalBytesWritten,
                 total: totalBytesExpectedToWrite)
        
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        if let target = self.resultURL {
            do {
                let fileManager = FileManager.default
                try fileManager.removeItem(at: target)
                
                try fileManager.copyItem(at: location, to: target)
                state = (done: true, url: target, written: 0, total: 0)
                return
            }
            catch {
            }
        }
        else {
            state =  (done: true, url: location, written: 0, total: 0)
            return
        }
        state = (done: false, url: location, written: 0, total: 0)
    }

    func urlSession(_: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            debugPrint(task.debugDescription)
            debugPrint(error.localizedDescription)
            state = (done: true, url: nil, written: 0, total: 0)
        }
    }
}
