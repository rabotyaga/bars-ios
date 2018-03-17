//
//  MainViewController.swift
//  baranov
//
//  Created by Ivan on 06/07/15.
//  Copyright (c) 2015 Rabotyaga. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UISearchBarDelegate, ArticleLoaderDelegate {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progressActivityIndicator: UIActivityIndicatorView!
    
    var searchBar: UISearchBar!
    var navHairline: UIImageView?
    var segmentedControl: UISegmentedControl!
    var tableHeaderLabel: UILabel!
    
    var toolBarShown: Bool = false
    
    var searchAutocomplete = SearchAutocompleteTableViewController()
    
    let articleDataSourceDelegate = ArticleDataSourceDelegate()
    var articleLoader : ArticleLoader!
    
    var query: AQuery {
        get {
            if (segmentedControl.selectedSegmentIndex == 0) {
                return AQuery.like(searchBar.text!.format_for_query())
            } else {
                return AQuery.exact(searchBar.text!.format_for_query())
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // loader setup
        articleLoader = ArticleLoader(delegate: self)
        
        // search bar setup
        searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = NSLocalizedString("searchPlaceholder", comment: "")
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        
        // toolbar setup
        segmentedControl = UISegmentedControl(items: [NSLocalizedString("searchLike", comment: ""), NSLocalizedString("searchExact", comment: "")])
        segmentedControl.setTitle(NSLocalizedString("searchLike", comment: ""), forSegmentAt: 0)
        segmentedControl.setTitle(NSLocalizedString("searchExact", comment: ""), forSegmentAt: 1)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(MainViewController.segmentedControlChanged(_:)), for: .valueChanged)
        let barb = UIBarButtonItem(customView: segmentedControl)
        let flex = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.items = [flex, barb, flex]
        
        // hide navigationController's builtin toolbar at start
        navigationController?.isToolbarHidden = true
        
        // special imageView with 0.5px height line at the bottom of navbar
        // find & store it for later hiding/showing
        // when showing/hiding toolbar
        // to make toolbat visually extend navbar
        navHairline = findNavBarHairline()
        
        // main table view setup
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 180
        tableView.delegate = self.articleDataSourceDelegate
        tableView.dataSource = self.articleDataSourceDelegate
        
        // results count indicator
        // as a main table header
        self.makeTableHeaderView()
        
        //??
        //definesPresentationContext = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.orientationChanged(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        searchAutocomplete.setup(view, searchBarDelegate: self, searchBar: searchBar)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // submit new search after search type changed
    // if there is some text in search bar
    @objc func segmentedControlChanged(_ sender: AnyObject) {
        if (!searchBar.text!.isEmpty) {
            searchBarSearchButtonClicked(searchBar)
        }
    }
    
    func findNavBarHairline() -> UIImageView? {
        for a in (navigationController?.navigationBar.subviews)! as [UIView] {
            for b in a.subviews {
                if (b.isKind(of: UIImageView.self) && b.bounds.size.width == self.navigationController?.navigationBar.frame.size.width &&
                    b.bounds.size.height < 2) {
                        return b as? UIImageView
                }
            }
        }
        return nil
    }
    
    func makeTableHeaderView() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 22))
        view.autoresizingMask = UIViewAutoresizing.flexibleWidth
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 22))
        label.autoresizingMask = UIViewAutoresizing.flexibleWidth
        view.addSubview(label)
        label.textAlignment = .center
        
        tableHeaderLabel = label
        
        tableView.tableHeaderView = view
    }
    
    func updateResultsIndicator(_ count : Int) {
        self.tableHeaderLabel.text = String(format: NSLocalizedString("results", comment: ""), arguments: [count])
    }
    
    // MARK: - Storyboard connected actions
    
    @IBAction func menuButtonClicked(_ sender: AnyObject) {
        if (sideMenuController()?.sideMenu?.isMenuOpen == true) {
            hideSideMenuView()
        } else {
            showSideMenuView()
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        hideSideMenuView()
        if let detailsViewController = segue.destination as? DetailsViewController {
            if let cell = sender as? ArticleTableViewCell {
                if let indexPath = self.tableView.indexPath(for: cell) {
                    let article = self.articleDataSourceDelegate.articleForIndexPath(indexPath)
                    detailsViewController.articleToLoad = article
                }
            }
        }
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        hideSideMenuView()
        searchBar.text = searchBar.text!.format_for_query()
        if (searchBar.text!.length == 0) {
            return
        }
        searchBar.resignFirstResponder()
        
        if (searchBar.text!.count == 1 && segmentedControl.selectedSegmentIndex == 0) {
            let title = NSLocalizedString("youEnteredOnlyOneCharacter", comment: "")
            let message = NSLocalizedString("theSearchWillBeMadeInExactMode", comment: "")
            let cancelButtonTitle = NSLocalizedString("OK", comment: "")
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel) { action in
                // do nothing
            }
            alertController.addAction(cancelAction)
            
            segmentedControl.selectedSegmentIndex = 1
            
            present(alertController, animated: true, completion: nil)
        }
        
        if (articleLoader.queryResult?.query != query) {
            articleLoader.loadArticlesByQuery(query)
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        hideSideMenuView()
        showToolBar()
        searchAutocomplete.textDidChange(searchBar.text!)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        hideToolBar()
        searchAutocomplete.hideAutocompleteTable()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchAutocomplete.textDidChange(searchText)
    }
    
    // MARK: - ArtcileLoaderDelegate
    
    func loaderWillLoad() {
        showProgressIndicator()
    }
    
    func loaderDidLoad(_ queryResult: QueryResult) {
        hideProgressIndicator()
        articleDataSourceDelegate.articles_count = queryResult.articles.count
        articleDataSourceDelegate.sections = queryResult.sections
        tableView.reloadData()
        updateResultsIndicator(articleDataSourceDelegate.articles_count)
        tableView.setContentOffset(CGPoint.zero, animated: true)
        
        if (queryResult.articles.count == 0) && (segmentedControl.selectedSegmentIndex == 1) && (searchBar.text!.length > 1) {
            let title = NSLocalizedString("nothingFound", comment: "")
            let message = NSLocalizedString("youDidSearchUsingExactMode", comment: "")
            let okButtonTitle = NSLocalizedString("OK", comment: "")
            let cancelButtonTitle = NSLocalizedString("Cancel", comment: "")
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: okButtonTitle, style: .cancel) { action in
                // resubmit query in Like mode
                self.segmentedControl.selectedSegmentIndex = 0
                self.searchBarSearchButtonClicked(self.searchBar)
            }
            let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .default) { action in
                // make searchBar active
                self.searchBar.becomeFirstResponder()
            }
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)

            present(alertController, animated: true, completion: nil)
        }
        
        if let firstArticle = queryResult.sections.first?.articles.first {
            // save search history
            var detailsString = firstArticle.ar_inf.string.bidiWrapped() + ": "
            if (firstArticle.translation.string.length > 30) {
                detailsString += "\((firstArticle.translation.string as NSString).substring(to: 30))...".bidiWrapped(true)
            } else {
                detailsString += firstArticle.translation.string.bidiWrapped(true)
            }
            
            let sh = SearchHistory(searchString: getStringFromQuery(queryResult.query), details: detailsString.bidiWrapped(true))

            searchAutocomplete.saveSearchHistory(sh)
        }
    }
    
    // MARK: - UIDeviceOrientationDidChangeNotification
    
    @objc func orientationChanged(_ notification: Notification) {
        // orientation change while toolBar is shown
        // should recalc its frame and redraw it
        if (toolBarShown) {
            toolBarShown = false
            showToolBar()
        }
    }
    
    // MARK: - UI Show & Hide
    
    func showToolBar() {
        // slide down top tool bar that extends nav bar
        if (!toolBarShown) {
            // slide down top tool bar that extends nav bar
            let frame = CGRect(x: 0, y: toolBar.frame.origin.y + toolBar.frame.height, width: toolBar.frame.width, height: toolBar.frame.height)
            UIView.animate(withDuration: 0.3, animations: {
                self.toolBar.frame = frame
                self.navHairline?.alpha = 0.0
                self.toolBar.alpha = 1.0
            })
            toolBarShown = true
        }
    }
    
    func hideToolBar() {
        // slide up top tool bar that extends nav bar
        if (toolBarShown) {
            let frame = CGRect(x: 0, y: toolBar.frame.origin.y - toolBar.frame.height, width: toolBar.frame.width, height: toolBar.frame.height)
            UIView.animate(withDuration: 0.3, animations: {
                self.toolBar.frame = frame
                self.navHairline?.alpha = 1.0
                self.toolBar.alpha = 0.0
            })
            toolBarShown = false
        }
    }
    
    func showProgressIndicator() {
        progressActivityIndicator.startAnimating()
        tableView.isHidden = true
    }
    
    func hideProgressIndicator() {
        progressActivityIndicator.stopAnimating()
        tableView.isHidden = false
    }
    
    func selectMenuButton(_ selected: Bool) {
        if (selected) {
            searchBar.resignFirstResponder()
            menuButton.tintColor = UIColor.tintSelected()
        } else {
            menuButton.tintColor = self.view.tintColor
        }
    }
}
