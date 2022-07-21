//
//  HomeViewController.swift
//  ProductCatalog
//
//

import Combine
import UIKit
import Combine

class HomeViewController: UIViewController {
    weak var progressView: ActivityProgressView!
    var dbImporter: DatabaseImporter?
    var dataBuilder: ProductDatabaseBuilder? //new implementation of dbImporter
    var downloadCancellable: AnyCancellable?
    var importCancellable: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Constants.App.appTitle
        
        //download CSV file
        self.startCSVFileDown(nil)
    }
    
    func addProductCatalogViewController() {
        if let pvc = self.storyboard?.instantiateViewController(withIdentifier: "ProductTableViewController") as? ProductTableViewController {
            self.navigationController?.setToolbarHidden(true, animated: false)
            self.navigationController?.setViewControllers([pvc], animated: true)
        }
    }
}

//MARK: Manage file download
extension HomeViewController {
    func startCSVFileDown(_ url: URL?) {
        guard let sourceURL = url ?? URL(string: Constants.CSVFile.productCatalogURLPath) else {
            return
        }
        let downloader = CSVURLDownloader()
        self.progressView = ActivityProgressView.createProgressView(in: self.view,
                                                                    Constants.CSVFile.progressViewTitle)
        downloadCancellable = downloader.$state.sink { r in
            DispatchQueue.main.async {
                if r.done == true  {
                    if let url = r.url {
                        self.progressView.removeFromSuperview()
                        self.startDataImport(url)
                    }
                    self.downloadCancellable?.cancel()
                    self.downloadCancellable = nil
                }
                else {
                    if r.written != 0 && r.total != 0 {
                        let message = String(format: Constants.CSVFile.messageFormat, r.written, r.total)
                        let d = Float( r.written )/Float(r.total)
                        self.progressView?.updateStatus(d, message)
                    }
                }
            }
        }
        downloader.startDownload(sourceURL, nil)
    }
}

//MARK: Manage database import
extension HomeViewController {
    func startDataImport(_ csvFile: URL) {
        self.progressView = ActivityProgressView.createProgressView(in: self.view)
        dataBuilder = ProductDatabaseBuilder()
        if dataBuilder?.configureAndStartImport(source: csvFile) == true {
            importCancellable = dataBuilder?.$state.sink(receiveValue: { r in
                DispatchQueue.main.async {
                    if r.done == true  {
                        self.progressView?.removeFromSuperview()
                        self.addProductCatalogViewController()
                        self.importCancellable?.cancel()
                        self.importCancellable = nil
                    }
                    else {
                        if r.total != 0 && r.itemsImported != 0 {
                            let message = String(format: Constants.CSVFile.messageFormat, r.itemsImported, r.total)
                            let d = Float( r.itemsImported)/Float(r.total)
                            self.progressView?.updateStatus(d, message)
                        }
                    }
                }
            })
        }
    }
}

