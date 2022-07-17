//
//  HomeViewController.swift
//  ProductCatalog
//
//

import Combine
import UIKit

class HomeViewController: UIViewController {
    weak var progressView: ActivityProgressView!
    var dbImporter: DatabaseImporter?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Constants.App.appTitle
        if !DatabaseImporter.isDatabaseReady() {
            self.dbImporter = DatabaseImporter()
            self.dbImporter?.prepareDatabase(nil, self, self)
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

// MARK: download csv file activity

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

// MARK: populate database activity

extension HomeViewController: DatabaseImporterWatcher {
    func progress(_ progress: Float, _ message: String) {
        self.progressView?.updateStatus(progress, message)
    }

    func onImportDone(_ status: Bool) {
        self.dbImporter = nil
        self.progressView?.removeFromSuperview()

        self.addProductCatalogViewController()
    }

    func databaseWillStartImport() {
        self.progressView = ActivityProgressView.createProgressView(in: self.view)
    }
}
