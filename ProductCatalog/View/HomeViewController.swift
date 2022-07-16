//
//  HomeViewController.swift
//  ProductCatalog
//
//

import UIKit
import Combine

class HomeViewController: UIViewController {
    let db = SqliteService.shared
    
    weak var progressView: ActivityProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Constants.App.appTitle
        if !DatabaseImporter.isDatabaseReady() {
            DatabaseImporter.shared.prepareDatabase(nil, self, self)
        }
        else {
            self.addProductCatalogViewController()
        }
    }
    
    func addProductCatalogViewController() {
        if let pvc = self.storyboard?.instantiateViewController(withIdentifier: "ProductTableViewController") as? ProductTableViewController {
            self.navigationController?.setToolbarHidden(true, animated: false)
            self.navigationController?.setViewControllers([pvc], animated: true)
        }
    }
}

//MARK: download csv file activity
extension HomeViewController: CSVDownloadWatcher {
    func finishDownloading(_ status: Bool) {
        self.progressView.removeFromSuperview()
    }
    
    func downloadProgress(_ progress: Float, _ bytes: Int, _ total: Int) {
        let message = String(format: Constants.CSVFile.messageFormat, bytes, total)
        self.progressView?.updateStatus(progress, message)
    }
    
    func csvFileWillStartDownload() {
        self.progressView = ActivityProgressView.createProgressView(in: self.view, Constants.CSVFile.progressViewTitle)
    }
}

//MARK: populate database activity
extension HomeViewController: DatabaseImporterWatcher {
    func progress(_ progress: Float, _ message: String) {
        self.progressView?.updateStatus(progress, message)
    }
    func onImportDone(_ status: Bool) {
        self.progressView.removeFromSuperview()
        self.addProductCatalogViewController()
    }
    
    func databaseWillStartImport() {
        self.progressView = ActivityProgressView.createProgressView(in: self.view)
    }
}


