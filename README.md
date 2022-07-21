# README #
What're included?

## Design doc ##

* Describe the components and interactions. The design doc needs to update. The current implementation is slightly different by using Combine framework to watch the state of downloading and importing. It is much simpler than described delegate patterns in design doc.

## Testcases ##

* Plan to test various components and functions

## Source code ##

* Launch XCode to run in simulators. Note: requires iOS 15.x. Use Swift concurrency capability to coordinate read file & write database, with an "actor" of FIFO queue for data exchange.

Screenshots:
![Download](https://github.com/victorzengsfbay/ProductCatalog/blob/main/Simulator%20Screen%20Shot%20-%20iPod%20touch%20(7th%20generation)%20-%202022-07-16%20at%2013.19.20.png)

![Download](https://github.com/victorzengsfbay/ProductCatalog/blob/main/Simulator%20Screen%20Shot%20-%20iPod%20touch%20(7th%20generation)%20-%202022-07-16%20at%2013.19.51.png)

![Import](https://github.com/victorzengsfbay/ProductCatalog/blob/main/Simulator%20Screen%20Shot%20-%20iPod%20touch%20(7th%20generation)%20-%202022-07-16%20at%2013.20.36.png)

![Import](https://github.com/victorzengsfbay/ProductCatalog/blob/main/Simulator%20Screen%20Shot%20-%20iPod%20touch%20(7th%20generation)%20-%202022-07-16%20at%2013.20.48.png)

![UI](https://github.com/victorzengsfbay/ProductCatalog/blob/main/Simulator%20Screen%20Shot%20-%20iPod%20touch%20(7th%20generation)%20-%202022-07-16%20at%2013.21.21.png)

![UI](https://github.com/victorzengsfbay/ProductCatalog/blob/main/Simulator%20Screen%20Shot%20-%20iPod%20touch%20(7th%20generation)%20-%202022-07-16%20at%2013.21.28.png)

