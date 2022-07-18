//
//  SqliteWriter.swift
//  ProductCatalog
//

import Foundation
import SQLite3
import UIKit

protocol SqliteWriteObserver: AnyObject {
    func progress(at position: Int, of total: Int)
    func complete(with status: Bool)
}

protocol SqliteReaderObserver: AnyObject {
    func productsUpdate()
    func searchResults(_ products: [Product], for searchId: String)
}

protocol SqliteReaderProvider {
    func getProducts(with productId_Prefix: String, from: Int, _ maxLimit: Int) -> ([Product], Int)
}

protocol SqliteWriteProvider {
    func startImport(_ csvReader: CSVReaderProtocol?) -> Bool
    func pouplateAllData(_ csvReader: CSVReaderProtocol)
    func cancel()
}

class SqliteService: SqliteWriteProvider & SqliteReaderProvider {
    let queue = DispatchQueue(label: "SerialSqliteDB")
    let batchSize = 100
    
    weak var delegate: SqliteWriteObserver?
    weak var dataObserver: SqliteReaderObserver?
    
    var reader: CSVReaderProtocol?
    var database: OpaquePointer?
    
    var current: Int = 0
    // var isCancelled: AtomicBoolean = AtomicBoolean()
    
    var searchCount: Int = 0
    
    required init(_ observer: SqliteReaderObserver?) {
        self.dataObserver = observer
        _ = self.createDefaultDatabase()
    }
    
    required init(_ delegate: SqliteWriteObserver? = nil, _ csvFileReader: CSVReaderProtocol? = nil) {
        self.delegate = delegate
        self.reader = csvFileReader
    }
    
    func createDefaultDatabase() -> OpaquePointer? {
        if self.database != nil { return self.database }
        var db: OpaquePointer?
        guard let filePath = try? FileManager.default.url(for: .documentDirectory,
                                                          in: .userDomainMask,
                                                          appropriateFor: nil,
                                                          create: false).appendingPathComponent(Constants.SqliteDatabase.productSqliteDBName) else { return nil }
        
        if sqlite3_open(filePath.path, &db) == SQLITE_OK, let database = db {
            self.database = database
        }
        return self.database
    }
    
    deinit {
        if let db = self.database {
            sqlite3_close(db)
            self.database = nil
        }
    }
}

//

// MARK: SqliteWriteProvider

//
extension SqliteService {
    func cancel() {
        // _ = isCancelled.testAndSet(value: true)
    }
    
    func startImport(_ csvReader: CSVReaderProtocol? = nil) -> Bool {
        var status: Bool = true
        self.queue.sync {
            if  self.createDefaultDatabase() != nil {
                _ = self.dropTable()
                status = self.createTable()
            }
            else {
                status = false
            }
        }
        return status
    }
    
    func pouplateAllData(_ csvReader: CSVReaderProtocol) {
        self.queue.async {
            typealias Products = [Product]
            let dataQueue = DataQueue<Products>()
            
            //reading task
            Task {
                repeat {
                    let products = csvReader.getNextProducts(self.batchSize)
                    if products.count > 0 {
                        await dataQueue.enqueue(key: products)
                    }
                    else {
                        await dataQueue.notifyDoneReading()
                        break
                    }
                } while true
            }
            
            //writing task
            Task {
                var status: Bool = true
                repeat {
                    let done = await dataQueue.isReadingDone()
                    let empty = await dataQueue.isEmpty
                    if !done || !empty {
                        if let products = await dataQueue.dequeue(), products.count > 0 {
                            status  = self.insertProducts(products)
                            if status {
                                self.current += products.count
                                if self.current % 2000 == 0 {
                                    self.notifyProgress(at: self.current, of: csvReader.totalRecord)
                                }
                            }
                            else {
                                break
                            }
                        }
                    }
                    else {
                        break
                    }
                } while true
                self.notifyStatus(status)
            }
        }
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
        
        var statement: OpaquePointer?
        defer { if statement != nil { sqlite3_finalize(statement!); statement = nil }}
        
        if sqlite3_prepare_v2(self.database, query, -1, &statement, nil) == SQLITE_OK,
           sqlite3_step(statement) == SQLITE_DONE
        {
            return true
        }
        return false
    }
    
    func createTable() -> Bool {
        let query = "CREATE TABLE IF NOT EXISTS \(Constants.SqliteDatabase.productsTableName)(productId TEXT PRIMARY KEY, title TEXT, listPrice INTEGER, salesPrice INTEGER, color TEXT, size TEXT);"
        var statement: OpaquePointer?
        defer { if statement != nil { sqlite3_finalize(statement!); statement = nil }}
        
        if sqlite3_prepare_v2(self.database, query, -1, &statement, nil) == SQLITE_OK,
           sqlite3_step(statement) == SQLITE_DONE
        {
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
        var statement: OpaquePointer?
        defer { if statement != nil { sqlite3_finalize(statement!); statement = nil }}
        
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
       
        var statement: OpaquePointer?
        defer { if statement != nil { sqlite3_finalize(statement!); statement = nil }}
       
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

// MARK: SqliteReaderProvider

//
extension SqliteService {
    func getProducts(with productId_Prefix: String = "", from: Int, _ maxLimit: Int) -> ([Product], Int) {
        var results: [Product] = []
        
        var statement: OpaquePointer?
        defer { if statement != nil { sqlite3_finalize(statement!); statement = nil }}
       
        self.queue.sync {
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
                    let id = String(cString: sqlite3_column_text(statement, 0))
                    let title = String(cString: sqlite3_column_text(statement, 1))
                    let listPrice = sqlite3_column_int64(statement, 2)
                    let salesPrice = sqlite3_column_int64(statement, 3)
                    let color = String(cString: sqlite3_column_text(statement, 4))
                    let size = String(cString: sqlite3_column_text(statement, 5))
                    let product = Product(productId: id, title: title, listPrice: Int(listPrice), salesPrice: Int(salesPrice), color: color, size: size)
                   
                    results.append(product)
                }
            }
        }
        return (results, self.searchCount)
    }
}
