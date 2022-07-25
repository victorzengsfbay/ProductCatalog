//
//  CatalogListVM.swift
//  ProductCatalog
//
//

import Foundation

typealias DataLoadedHandler = (Int) -> Void
typealias DataAddedHandler = (ClosedRange<Int>?) -> Void

protocol CatalogListVMProvider {
    func load(_ str: String?, _ isStart: Bool, _ size: Int)
    
    func numberOfProducts() -> Int
    func product(at n: Int) -> Product?
    
    var onLoaded: DataLoadedHandler? {
        get
        set
    }
    var onRowsAdded: DataAddedHandler? {
        get
        set
    }
}

class CatalogListVM: CatalogListVMProvider {
    private let pageSize: Int
    private var productId_prefix: String = ""
    private var products: [Product] = []
    private var dataService: SqliteReaderProvider
    private var searchQueue: DispatchQueue = DispatchQueue(label: "search")
    
    private var pendingSearchItem: DispatchWorkItem?
    
    var onLoaded: DataLoadedHandler?
    var onRowsAdded: DataAddedHandler?
    
    init(_ pageSize: Int = 20) {
        self.dataService = SqliteService(nil)
        self.pageSize = pageSize
    }
 
    func load(_ str: String? = nil, _ isStart: Bool = true, _ size: Int = 20) {
        
        self.pendingSearchItem?.cancel()
        
        if let str = str {
            productId_prefix = str
        }
        let startIndex = isStart ? 0 : self.products.count + 1
        print("request added:\"\(self.productId_prefix)\", from:\(startIndex), size: \(size)")
        var searchWorkItem: DispatchWorkItem?
        searchWorkItem =  DispatchWorkItem {
            if searchWorkItem?.isCancelled == true {return}
            print("perform search:\"\(self.productId_prefix)\", from:\(startIndex), size: \(size)")
            let (results, total) = self.dataService.getProducts(with: self.productId_prefix, from: startIndex, size)
            DispatchQueue.main.async {
                [weak self] in
                guard let self = self else {return}
                if searchWorkItem?.isCancelled == true {return}
                print("UI display:\"\(self.productId_prefix)\", from:\(startIndex), size: \(size)")
                if isStart {
                    self.products = results
                    self.onLoaded?(total)
                }
                else {
                    let range: ClosedRange<Int>? = results.count == 0 ? nil : (self.products.count ... (self.products.count + results.count - 1))
                    self.products += results
                    self.onRowsAdded?(range)
                }
            }
        }
        self.pendingSearchItem = searchWorkItem
        searchQueue.asyncAfter(deadline: DispatchTime.now() + .milliseconds(50), execute: searchWorkItem!)
    }
    
    
    func numberOfProducts() -> Int {
        return products.count
    }
    
    func product(at n: Int) -> Product? {
        if n < products.count {
            return products[n]
        }
        return nil
    }
}

/*
 * - lock and start db operation
 */
class SearchOperation: Operation {
    
}
