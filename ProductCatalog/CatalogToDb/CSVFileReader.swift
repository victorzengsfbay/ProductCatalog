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
}
//https://drive.google.com/uc?export=download&id=16jxfVYEM04175AMneRlT0EKtaDhhdrrv
class CSVFileReader: CSVReaderProtocol {    
    let path: String
    let totalRecord: Int
    let keys: String
    var dataLines: [String]
    var currentIndex: Int = 0
    
    init?(_ filePath: String) {
        self.path = filePath
        if let data = try?  String(contentsOfFile: filePath) {
            var lines = data.components(separatedBy: .newlines).map {String($0)}
            if lines.count == 0 {
                return nil
            }
            self.keys = lines[0]
            lines.remove(at: 0)
            if let last = lines.last, last.count < 10 {
                lines.removeLast()
            }
            dataLines = lines
            totalRecord = dataLines.count
        }
        else {
            return nil
        }
    }
    
    func getNextLine() -> String? {
        if currentIndex < dataLines.count {
            let line = dataLines[currentIndex]
            currentIndex += 1
            return line
        }
        return nil
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
     }
