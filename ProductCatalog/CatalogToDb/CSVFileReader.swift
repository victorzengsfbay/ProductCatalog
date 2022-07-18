//
//  CSVFileReader.swift
//  ProductCatalog
//
//

import Foundation

protocol CSVReaderProtocol {
    var totalRecord: Int {get}
    var keys: String {get}
    func getNextLine() -> String?
    func getNextProducts(_ n: Int) -> [Product]
}

struct CSVFileReader: CSVReaderProtocol {    
    let path: String
    let totalRecord: Int
    let keys: String
    var currentIndex: Int = 0
    var reader: StreamReader?
    
    init?(_ filePath: String) {
        self.path = filePath
        if let reader = StreamReader(url: URL(fileURLWithPath: filePath)) {
            self.reader = reader
            totalRecord = (self.reader?.numberOfNoEmptylines(10) ?? 1) - 1
            self.keys = self.reader?.nextLine() ?? ""
        }
        else {
            return nil
        }
    }
    
    func getNextLine() -> String? {
        self.reader?.nextLine()
    }
    
    func getNextProducts(_ n: Int = 100) -> [Product] {
        var products = [Product]()
        while products.count < n {
            if let line = reader?.nextLine(), let product = Product(line) {
                products.append(product)
            }
            else {
                break
            }
        }
        return products
    }
}

     class StreamReader {
         let encoding: String.Encoding
         let chunkSize: Int
         let fileHandle: FileHandle
         var buffer: Data
         let delimPattern : Data
         var isAtEOF: Bool = false
         
         init?(url: URL, delimeter: String = "\n", encoding: String.Encoding = .utf8, chunkSize: Int = 4096)
         {
             guard let fileHandle = try? FileHandle(forReadingFrom: url) else { return nil }
             self.fileHandle = fileHandle
             self.chunkSize = chunkSize
             self.encoding = encoding
             buffer = Data(capacity: chunkSize)
             delimPattern = delimeter.data(using: .utf8)!
         }
         
         deinit {
             fileHandle.closeFile()
         }
         
         func rewind() {
             fileHandle.seek(toFileOffset: 0)
             buffer.removeAll(keepingCapacity: true)
             isAtEOF = false
         }
         
         func nextLine() -> String? {
             if isAtEOF { return nil }
             
             repeat {
                 if let range = buffer.range(of: delimPattern, options: [], in: buffer.startIndex..<buffer.endIndex) {
                     let subData = buffer.subdata(in: buffer.startIndex..<range.lowerBound)
                     let line = String(data: subData, encoding: encoding)
                     buffer.replaceSubrange(buffer.startIndex..<range.upperBound, with: [])
                     return line
                 } else {
                     let tempData = fileHandle.readData(ofLength: chunkSize)
                     if tempData.count == 0 {
                         isAtEOF = true
                         return (buffer.count > 0) ? String(data: buffer, encoding: encoding) : nil
                     }
                     buffer.append(tempData)
                 }
             } while true
         }
         func numberOfNoEmptylines(_ minLen: Int) -> Int {
             self.rewind()
             var ct = 0
             while let line = nextLine(), line.count >= minLen {
                 ct += 1
             }
             self.rewind()
             return ct
         }
     }
