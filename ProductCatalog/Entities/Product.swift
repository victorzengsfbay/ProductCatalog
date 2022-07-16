//
//  Product.swift
//  ProductCatalog
//
//

import Foundation

struct Product {
    let productId: String
    let title: String
    let listPrice: Int
    let salesPrice: Int
    let color: String
    let size: String
    
    init( productId: String, title: String, listPrice: Int, salesPrice: Int, color: String, size: String) {
        self.productId = productId
        self.title = title
        self.listPrice = listPrice
        self.salesPrice = salesPrice
        self.color = color
        self.size = size
    }
    
    init?(_ string: String) {
        
        let components = string.components(separatedBy: ",")
        if components.count != Constants.CSVFile.productKeyCount {
            return nil
        }
        if let listPrice = Double(components[2]),
           let salesPrice = Double(components[3])
        {
            self.productId = String(components[0])
            self.listPrice = Int(listPrice * 100.0)
            self.salesPrice = Int(salesPrice * 100.0)
            self.title = String(components[1].replacingOccurrences(of: "\\'", with: "'"))
            self.color = components[4]
            self.size = components[5]
        }
        else {
            return nil
        }
    }
}
