//
//  CatalogListVM.swift
//  ProductCatalog
//
//

import Foundation

typealias DataLoadedHandler = (Int) -> Void
typealias DataAddedHandler = (ClosedRange<Int>?) -> Void

protocol CatalogListVMProvider {
    func load(_ str: String, _ size: Int)
    func loadMore(_ n: Int)
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
    let pageSize: Int
    
    var productId_prefix: String = ""
    
    var products: [Product] = []
    
    var dataService: SqliteReaderProvider
   
    var onLoaded: DataLoadedHandler?
    var onRowsAdded: DataAddedHandler?
    
    init(_ pageSize: Int = 20) {
        self.dataService = SqliteService(nil)
        self.pageSize = pageSize
    }
 
    func load(_ str: String, _ size: Int = 20) {
        productId_prefix = str
        DispatchQueue.global().async {
            let (products, total) = self.dataService.getProducts(with: self.productId_prefix, from: 0, size)
            DispatchQueue.main.async {
                self.products = products
                self.onLoaded?(total)
            }
        }
    }
    
    func loadMore(_ n: Int = 20) {
        DispatchQueue.global().async {
            let ct = self.products.count
            let (results, _) = self.dataService.getProducts(with: self.productId_prefix, from: ct + 1, n)
            DispatchQueue.main.async {
                let range: ClosedRange<Int>? = results.count == 0 ? nil : (self.products.count ... (self.products.count + results.count - 1))
                self.products += results
                self.onRowsAdded?(range)
            }
        }
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
