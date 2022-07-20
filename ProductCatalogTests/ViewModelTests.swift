//
//  ViewModelTests.swift
//  ProductCatalogTests
//
//  Created by Victor Zeng on 7/19/22.
//

import XCTest
@testable import ProductCatalog

class ViewModelTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    /*
     * MARK: ViewModel test
     */
    func testVM() throws {
        let dbRecord = 1000000
        let vm = CatalogListVM()
        vm.load("")
        let exp = XCTestExpectation(description: "LoadDB")
        var ct: Int = 0
        vm.onLoaded = { k in
            ct = k
            exp.fulfill()
        }
        wait(for: [exp], timeout: 3.0)
        XCTAssert(ct == dbRecord)
    }

    func testVMSearch() throws {
        
        let vm = CatalogListVM()
        //search results
        let exp = XCTestExpectation(description: "SearchDB")
        var ct: Int = 0
        vm.onLoaded = {
            k  in
            ct = k
            exp.fulfill()
        }
        vm.load("1002")
        wait(for: [exp], timeout: 3.0)
        XCTAssert(ct > 0)
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            let vm = CatalogListVM()
            vm.load("")
            let exp = XCTestExpectation(description: "LoadDB")
            vm.onLoaded = { k in
                
                exp.fulfill()
            }
            wait(for: [exp], timeout: 3.0)
        }
    }

}
