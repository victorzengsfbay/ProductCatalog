//
//  DatabaseImporter.swift
//  ProductCatalog
//
//

import Foundation

protocol DatabaseImporterWatcher: AnyObject {
    func databaseWillStartImport()
    func progress(_ progress: Float, _ message: String)
    func onImportDone(_ status: Bool)
}

class DatabaseImporter: SqliteWriteObserver {
    weak var databuilderObserver: DatabaseImporterWatcher?
    weak var downloadWatcher: CSVDownloadWatcher?
    var localCSVFileURL: URL?
    var sqlService: SqliteService?
    
    @Published var status: DatabaseImporter.Status?
    
    /*
     * Based on local source CSVFile, create default database if needed, create a new table
     * for the product catalog to import
     * Start populating all data entries
     */
    func configureAndStartImport(source: URL? = nil) {
        
        guard let localCSVFileURL = source ?? localCSVFileURL ?? CSVDownloadManager.defaultLocalFileURL(),
           let csvFileReader = CSVFileReader(localCSVFileURL.path) else {
            self.status = .cannotStartImport
            return
        }
        let sqlw = SqliteService()
        
        if  sqlw.startImport() {
            sqlw.delegate = self
            
            self.databuilderObserver?.databaseWillStartImport()
            self.status = .importStarted
            
            sqlw.pouplateAllData(csvFileReader)
            
            self.sqlService = sqlw
            self.status = .importStarted
        }
        else {
            self.status = .cannotStartImport
        }
        
    }
    
    func prepareDatabase(_ url: URL? = nil,
                         _ observer: DatabaseImporterWatcher?,
                         _ downloadWatcher: CSVDownloadWatcher?)
    {
        self.databuilderObserver = observer
        self.downloadWatcher = downloadWatcher
        
        if DatabaseImporter.isCSVFileReady() {
            self.configureAndStartImport()
        }
        else {
            if let source = url ?? URL(string: Constants.CSVFile.productCatalogURLPath),
               let targetURL = CSVDownloadManager.defaultLocalFileURL()
            {
                self.localCSVFileURL = targetURL
                _ = CSVDownloadManager.shared.startDownload(source: source,
                                                            target: targetURL,
                                                            watcher: self)
                self.status = .downloadStarted
            }
            else {
                self.status = .cannotStartDownload
            }
        }
    }
    
    static func isCSVFileReady() -> Bool {
        // should compare this timestamp with latest backend CSV file timestamp to
        // decide if we should download latest csv
        return UserDefaults.standard.double(forKey: Constants.UserDefaultsKey.csvFileCreationTimestamp) > 0
    }
    
    static func isDatabaseReady() -> Bool {
        // should compare this timestamp with some timestamp latest CSV file timestamp to
        // decide if we should rebuild database
        let csvfilestamp: Double = UserDefaults.standard.double(forKey: Constants.UserDefaultsKey.csvFileCreationTimestamp)
        let databaseTimestamp: Double = UserDefaults.standard.double(forKey: Constants.UserDefaultsKey.databasePopulatedTimestamp)
        return databaseTimestamp > csvfilestamp
    }
}

// MARK: forward populating progress to UI

extension DatabaseImporter {
    func progress(at position: Int, of total: Int) {
        guard position % 1000 == 0 else { return }
        let p = Float(position) / Float(total)
        let message = String(format: Constants.ImportDatabase.messageFormat, position, total)
        self.databuilderObserver?.progress(p, message)
    }
    
    func complete(with status: Bool) {
        if status {
            UserDefaults.standard.setValue(Date().timeIntervalSince1970, forKey: Constants.UserDefaultsKey.databasePopulatedTimestamp)
        }
        self.databuilderObserver?.onImportDone(status)
    }
}

// MARK: forward download progress to UI

extension DatabaseImporter: CSVDownloadWatcher {
    func downloadProgress(_ progress: Float, _ bytes: Int, _ total: Int) {
        DispatchQueue.main.async {
            self.downloadWatcher?.downloadProgress(progress, bytes, total)
        }
    }

    func csvFileWillStartDownload() {
        DispatchQueue.main.async {
            self.downloadWatcher?.csvFileWillStartDownload()
        }
    }
    
    func finishDownloading(_ status: Bool) {
        DispatchQueue.main.async {
            self.downloadWatcher?.finishDownloading(status)
            if status {
                // launch database builder
                self.configureAndStartImport()
            }
        }
    }
}

extension DatabaseImporter {
    enum Status {
        case cannotStartDownload
        case downloadStarted
        case cannotStartImport
        case importStarted
    }
}
