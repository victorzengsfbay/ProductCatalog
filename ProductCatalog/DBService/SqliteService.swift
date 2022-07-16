//
//  SqliteWriter.swift
//  ProductCatalog
//

import Foundation
import SQLite3
import UIKit

protocol SqliteWriteObserver {
    func progress(at position: Int, of total: Int)
    func complete(with status: Bool)
}

protocol SqliteReaderObserver {
    func productsUpdate()
    func searchResults(_ products: [Product], for searchId: String)
}

protocol SqliteReaderProvider {
    func getProducts(with productId_Prefix: String, from: Int, _ maxLimit: Int) -> ([Product], Int)
}

protocol SqliteWriteProvider {
    func startImport() -> Bool
    func cancel()
}

class SqliteService: SqliteWriteProvider & SqliteReaderProvider {
    static let shared = SqliteService()
    
    let queue = DispatchQueue(label: "SerialSqliteDB")
    var delegate: SqliteWriteObserver?
    var reader: CSVReaderProtocol?
    var dataObserver: SqliteReaderObserver?
    var database: OpaquePointer?
    var current: Int = 0
    //var isCancelled: AtomicBoolean = AtomicBoolean()
    
    var searchCount: Int = 0
    
    
    required init(_ observer: SqliteReaderObserver?) {
        self.dataObserver = observer
        _ = createDefaultDatabase()
    }
    
    required init(_ delegate: SqliteWriteObserver? = nil, _ csvFileReader: CSVReaderProtocol? = nil) {
        self.delegate = delegate
        self.reader = csvFileReader
    }
    
    func createDefaultDatabase() -> OpaquePointer? {
        if self.database != nil {return self.database}
        var db : OpaquePointer? = nil
        guard let filePath = try? FileManager.default.url(for: .documentDirectory,
                                                          in: .userDomainMask,
                                                          appropriateFor: nil,
                                                          create: false).appendingPathExtension(Constants.SqliteDatabase.productSqliteDBName) else {return nil}
        
        if sqlite3_open(filePath.path, &db) == SQLITE_OK, let database = db {
            self.database = database
        }
        return self.database
    }
    
    deinit {
        if let db = self.database {
            sqlite3_close_v2(db)
            self.database = nil
        }
    }
}

//
//MARK: SqliteWriteProvider
//
extension SqliteService {
    func cancel() {
        //_ = isCancelled.testAndSet(value: true)
    }
    
    func startImport() -> Bool {
        
        queue.sync {
            if let _ = self.createDefaultDatabase() {
                _ = self.dropTable()
                queue.async {
                    self.pouplateAllData()
                }
            }
        }
        return self.database != nil
    }
    
    func pouplateAllData() {
        guard createTable() == true, let reader = self.reader else {
            return notifyStatus(false)
        }
        let k = 100
        var lines: [Product] = []
        var status: Bool = true
        let blockInsert = {
            status = self.insertProducts(lines)
            self.current += lines.count
            lines = []
            if self.current % 2000 == 0 {
                self.notifyProgress(at: self.current, of: reader.totalRecord)
            }
        }
        
        while status && self.current < reader.totalRecord  {
            if let nextLine = reader.getNextLine(), let product = Product(nextLine) {
                lines.append(product)
                if lines.count >= k {
                    blockInsert()
                }
            }
            else {
                break
            }
        }
        if lines.count > 0 {
            blockInsert()
        }
        notifyStatus(status)
    }
    
    func notifyProgress(at position: Int, of total: Int) {
        DispatchQueue.main.async {
            self.delegate?.progress(at: position, of: total)
        }
    }
    
    func notifyStatus(_ status: Bool) {
        DispatchQueue.main.async {
            self.delegate?.complete(with: status)
        }
    }
   
    func dropTable() -> Bool {
        
        let query = "DROP TABLE \(Constants.SqliteDatabase.productsTableName)"
        var statement : OpaquePointer? = nil
        
        defer { statement = nil}
        
        if sqlite3_prepare_v2(self.database, query, -1, &statement, nil) == SQLITE_OK,
            sqlite3_step(statement) == SQLITE_DONE {
                return true
        }
        return false
    }
    
    func createTable() -> Bool {
        let query = "CREATE TABLE IF NOT EXISTS \(Constants.SqliteDatabase.productsTableName)(productId TEXT PRIMARY KEY, title TEXT, listPrice INTEGER, salesPrice INTEGER, color TEXT, size TEXT);"
        var statement : OpaquePointer? = nil
        
        defer { statement = nil}
        
        if sqlite3_prepare_v2(self.database, query, -1, &statement, nil) == SQLITE_OK,
            sqlite3_step(statement) == SQLITE_DONE {
                return true
        }
        return false
    }
    
    func insertProducts(_ products: [Product]) -> Bool {
        var query = "INSERT INTO \(Constants.SqliteDatabase.productsTableName)(productId, title, listPrice, salesPrice, color, size) VALUES "
        for (i, product) in products.enumerated() {
            query.append(" (\'\(product.productId.sanitize())', '\(product.title.sanitize())', \(product.listPrice), \(product.salesPrice), '\(product.color.sanitize())', '\(product.size.sanitize())')")
            if i < (products.count - 1) {
                query.append(",")
            }
            else {
                query.append(";")
            }
        }
        var statement : OpaquePointer? = nil
        defer { statement = nil}
        
        if sqlite3_prepare_v2(self.database,
                              query,
                              -1,
                              &statement, nil) == SQLITE_OK,
           sqlite3_step(statement) == SQLITE_DONE
        {
            return true
        }
        return false
    }
    
    func insert(product: Product) -> Bool {
        let query = "INSERT INTO \(Constants.SqliteDatabase.productsTableName)(productId, title, listPrice, salesPrice, color, size) VALUES (\'\(product.productId.sanitize())', '\(product.title.sanitize())', \(product.listPrice), \(product.salesPrice), '\(product.color.sanitize())', '\(product.size.sanitize())');"
        var statement : OpaquePointer? = nil
        
        defer { statement = nil}
        
        if sqlite3_prepare_v2(self.database,
                              query,
                              -1,
                              &statement, nil) == SQLITE_OK,
           sqlite3_step(statement) == SQLITE_DONE
        {
            return true
        }
        return false
    }
}

//
//MARK: SqliteReaderProvider
//
extension SqliteService {
    
    func getProducts(with productId_Prefix: String = "", from: Int, _ maxLimit: Int) -> ([Product], Int) {
        var results: [Product] = []
        var statement : OpaquePointer? = nil
        
        defer { statement = nil}
        queue.sync {
        
        let prefixFilter: String = productId_Prefix.count == 0 ? "" : "WHERE productId LIKE \'%\(productId_Prefix)%\'"
        if from == 0 {
            let queryCount = "SELECT COUNT(productId) FROM \(Constants.SqliteDatabase.productsTableName) \(prefixFilter)"
            if sqlite3_prepare_v2(self.database,
                              queryCount,
                              -1,
                              &statement, nil) == SQLITE_OK
            {
                
                if sqlite3_step(statement) == SQLITE_ROW {
                    searchCount = Int(sqlite3_column_int64(statement, 0))
                }
            }
        }
        
        let query = "SELECT * FROM \(Constants.SqliteDatabase.productsTableName) \(prefixFilter) ORDER BY productId LIMIT \(maxLimit) OFFSET \(from)"
            
            if sqlite3_prepare_v2(self.database,
                              query,
                              -1,
                              &statement, nil) == SQLITE_OK
            {
                
                while sqlite3_step(statement) == SQLITE_ROW {
                    let id = String(cString:  sqlite3_column_text(statement,0) )
                    let title = String(cString:  sqlite3_column_text(statement, 1) )
                    let listPrice = sqlite3_column_int64(statement, 2)
                    let salesPrice = sqlite3_column_int64(statement, 3)
                    let color = String(cString:  sqlite3_column_text(statement, 4) )
                    let size = String(cString:  sqlite3_column_text(statement, 5) )
                    let product = Product(productId: id, title: title, listPrice: Int(listPrice), salesPrice: Int(salesPrice), color: color, size: size)
                   
                    results.append(product)
                }
            }
        }
            return (results, self.searchCount)
    }
}

