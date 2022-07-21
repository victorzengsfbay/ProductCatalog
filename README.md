# README #
What're included?

## Design doc ##

* Describe the components and interactions. The design doc needs to update. The current implementation is slightly different by using Combine framework to watch the state of downloading and importing. It is much simpler than described delegate patterns in design doc.

## Testcases ##

* Plan to test various components and functions

## Source code ##
* Main flow: `HomeViewController` is initial view controller, which starts `CSVURLDownloader` to download csv file. It also observe downloading progress and populate the information to `ActivityProgressView`. Once download finishes, `HomeViewController` starts `ProductDatabaseBuilder`, observe the database importing progress, populating the information on `ActivityProgressView`. `ProductDatabaseBuilder` will create `SqliteService` object and pass it `CSVFileReader`. `SqliteService` has method *`pouplateAllData`*. This method manages concurrent tasks of reading file and inserting database. Once `HomeViewController` notices that the importing job done, it will launch `ProductTableViewController` to display products and search results. Its viewmodel (`CatalogListVM` class) is responsible to load and search for products.
`ProductTableViewController` and `CatalogListVM` collaborates on Infinite Scroll and animated product rows appending. `ProductTableViewCell` presents a single product. Its viewmodel is `Product`.

* Launch XCode to run in simulators. Note: requires iOS 15.x. Use Swift concurrency capability to coordinate read file & write database, with an "actor" of FIFO queue for data exchange.

Screenshots:
![Download](https://github.com/victorzengsfbay/ProductCatalog/blob/main/Simulator%20Screen%20Shot%20-%20iPod%20touch%20(7th%20generation)%20-%202022-07-16%20at%2013.19.20.png)

![Download](https://github.com/victorzengsfbay/ProductCatalog/blob/main/Simulator%20Screen%20Shot%20-%20iPod%20touch%20(7th%20generation)%20-%202022-07-16%20at%2013.19.51.png)

![Import](https://github.com/victorzengsfbay/ProductCatalog/blob/main/Simulator%20Screen%20Shot%20-%20iPod%20touch%20(7th%20generation)%20-%202022-07-16%20at%2013.20.36.png)

![Import](https://github.com/victorzengsfbay/ProductCatalog/blob/main/Simulator%20Screen%20Shot%20-%20iPod%20touch%20(7th%20generation)%20-%202022-07-16%20at%2013.20.48.png)

![UI](https://github.com/victorzengsfbay/ProductCatalog/blob/main/Simulator%20Screen%20Shot%20-%20iPod%20touch%20(7th%20generation)%20-%202022-07-16%20at%2013.21.21.png)

![UI](https://github.com/victorzengsfbay/ProductCatalog/blob/main/Simulator%20Screen%20Shot%20-%20iPod%20touch%20(7th%20generation)%20-%202022-07-16%20at%2013.21.28.png)

