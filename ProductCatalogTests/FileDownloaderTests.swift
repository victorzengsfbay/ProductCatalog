//
//  FileDownloaderTests.swift
//  ProductCatalogTests
//
//  Created by Victor Zeng on 7/19/22.
//

import XCTest
@testable import ProductCatalog

class FileDownloaderTests: XCTestCase, CSVDownloadWatcher {
    var downloadExp: XCTestExpectation!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceDownloadtime() throws {
        // This is an example of a performance test case.
        if let source =  URL(string: Constants.CSVFile.productCatalogURLPath),
           let targetURL = CSVDownloadManager.defaultLocalFileURL()
        {
            downloadExp = XCTestExpectation(description: "DownloadExp")
            self.measure {
                _ = CSVDownloadManager.shared.startDownload(source: source,
                                                        target: targetURL,
                                                        watcher: self)
            }
            wait(for: [downloadExp], timeout: 100)
        }
    }
        
        func finishDownloading(_ status: Bool) {
            XCTAssert(status)
            downloadExp.fulfill()
        }
        
        func downloadProgress(_ progress: Float, _ bytes: Int, _ total: Int) {
            
        }
        
        func csvFileWillStartDownload() {
            
        }
        

}
