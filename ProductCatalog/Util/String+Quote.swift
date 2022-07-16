//
//  String+Quote.swift
//  ProductCatalog
//
//

import Foundation

extension String {
    func sanitize() -> String {
        return self.replacingOccurrences(of: "'", with: "''").replacingOccurrences(of: "\"", with: "\"\"")
    }
}
