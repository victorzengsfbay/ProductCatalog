//
//  ProductDatabaseBuilder.swift
//  ProductCatalog
//
//  Created by Victor Zeng on 7/20/22.
//

import UIKit
import Combine

class ProductDatabaseBuilder: NSObject, SqliteWriteObserver {
    
    
    let progress: PassthroughSubject<(id: Int, written: Int64, total: Int64), Never> = .init()
    
    @Published var state: (done: Bool, itemsImported: Int64, total: Int64) = (done: false, itemsImported: 0, total: 0)
    
    var sqlService: SqliteService = SqliteService()
    
    /*
     * Based on local source CSVFile, create default database if needed, create a new table
     * for the product catalog to import
     * Start populating all data entries
     */
    func configureAndStartImport(source: URL) -> Bool {
        guard let csvFileReader = CSVFileReader(source.path) else {return false}
        
        if  sqlService.startImport() {
            sqlService.delegate = self
            sqlService.pouplateAllData(csvFileReader)
            return true
        }
        return false
    }
    
}

extension ProductDatabaseBuilder {
    func progress(at position: Int, of total: Int) {
        self.state = (done: false,
                      itemsImported: Int64(position),
                      total: Int64(total))
    }
    
    func complete(with status: Bool) {
        self.state = (done: status,
                      itemsImported: self.state.itemsImported,
                      total: self.state.total)
    }
    
    
}
