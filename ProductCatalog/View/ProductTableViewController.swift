//
//  ProductTableViewController.swift
//  ProductCatalog
//
//

import UIKit

class ProductTableViewController: UITableViewController,
                                    UISearchResultsUpdating,
                                    UISearchControllerDelegate,
                                    UISearchBarDelegate
{
    let reuseId = "reuseId"
    var listVM: CatalogListVM?
    var finishLoad: Bool = false
    var totalResults: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.clipsToBounds = true
        self.title = Constants.App.appTitle
        
        self.tableView.register(ProductTableViewCell.self, forCellReuseIdentifier: reuseId)
        self.tableView.rowHeight = UITableView.automaticDimension
        
        self.addSearchController()
        
        self.setupViewModel()
    }

    func setupViewModel() {
        let vm =  CatalogListVM()
        vm.onLoaded = { total in
            self.onLoaded(total)
        }
        vm.onRowsAdded = { rows in
            self.onRowsAdded(rows)
        }
        self.listVM = vm
        self.listVM?.load("")
    }
    
}

//MARK: Observing data from ViewModel
extension ProductTableViewController {
    func onLoaded(_ total: Int) {
        self.totalResults = total
        finishLoad = true
        self.tableView.reloadData()
    }
    
    func onRowsAdded(_ range: ClosedRange<Int>?) {
        finishLoad = true
        
        if let range = range, range.count > 0 {
            
            let indexPaths = range.map { r in
                IndexPath(row: r, section: 0)
            }
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: indexPaths, with: UITableView.RowAnimation.automatic)
            self.tableView.endUpdates()            
        }
        
    }
}

//MARK: UITableViewDataSource
extension ProductTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.listVM?.numberOfProducts() ?? 0
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseId,
                                                       for: indexPath) as? ProductTableViewCell else {return UITableViewCell()}
        if let product = listVM?.product(at: indexPath.row) {
            cell.configure(product)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return TableSectionHeader()
    }
}

//MARK: respond to user scroll
extension ProductTableViewController {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if (scrollView.contentSize.height - scrollView.contentOffset.y) < scrollView.bounds.height {
            if self.finishLoad {
                self.finishLoad = false
                self.listVM?.loadMore()
            }
        }
        
    }
}

//
// MARK: Search implementation
//
extension ProductTableViewController {
    func addSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.searchTextField.placeholder = NSLocalizedString("Enter a product ID", comment: "")
        searchController.searchBar.returnKeyType = .done

        navigationItem.searchController = searchController
            
        navigationItem.hidesSearchBarWhenScrolling = false

        searchController.delegate = self

        searchController.searchBar.delegate = self
    }
    func updateSearchResults(for searchController: UISearchController) {
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.listVM?.load(searchText)
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.listVM?.load("")
    }
}

