//
//  Constants.swift
//  ProductCatalog
//
//

import Foundation
import UIKit

struct Constants {
    
    //MARK: csv file
    struct CSVFile {
        static let productCatalogURLPath: String = "https://drive.google.com/uc?export=download&id=16jxfVYEM04175AMneRlT0EKtaDhhdrrv"
        static let productCatalogFilePath: String = "productcatalog.csv"
        static let productKeyCount = 6
        
        static let progressViewTitle = "Download Product Catalog"
        static let messageFormat = "%d of %d bytes downloaded"
    }
    
    //MARK: database
    struct SqliteDatabase {
        static let productSqliteDBName = "productcatalog.sqlite"
        static let productsTableName = "products"
    }
    
    //MARK: DatabaseImporter
    struct ImportDatabase {
        static let title = "Import Product Catalog"
        static let messageFormat = "Add %d items of %d"
    }
    
    //MARK: App
    struct App {
        static let appTitle = "Product Catalog"
    }
    
    //MARK: View
    struct ProductCataView {
        //Product Cell
        static let productCellInsets: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        static let productInfoFont: UIFont = UIFont.systemFont(ofSize:  14.0, weight: UIFont.Weight.medium)
        static let productIdFont: UIFont = UIFont.systemFont(ofSize:  14.0, weight: UIFont.Weight.bold)
        static let productPriceFont: UIFont = UIFont.italicSystemFont(ofSize: 14.0)
        
        //MARK: Home TableView Section Header
        static let homeTableViewSectionHeaderHeight: CGFloat = 40
        static let homeTableViewSectionHeaderFont = UIFont.boldSystemFont(ofSize: 16.0)
        static let homeTableViewSectionHeaderTitleLeft = "Product"
        static let homeTableViewSectionHeaderTitleRight = "Price(List/Sales)"
    }
    
    //MARK: UserDefaults Key
    struct UserDefaultsKey {
        static let csvFileCreationTimestamp: String = "csvFileCeationTimestampKey"
        static let databasePopulatedTimestamp: String = "databasePopulatedTimestampKey"        
    }
}
