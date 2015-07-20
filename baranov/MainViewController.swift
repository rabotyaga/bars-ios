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
                return AQuery.Like(searchBar.text.format_for_query())
            } else {
                return AQuery.Exact(searchBar.text.format_for_query())
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // loader setup
        articleLoader = ArticleLoader(delegate: self)
        
        // search bar setup
        searchBar = UISearchBar()
        searchBar.searchBarStyle = .Minimal
        searchBar.placeholder = NSLocalizedString("searchPlaceholder", comment: "")
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        
        // toolbar setup
        segmentedControl = UISegmentedControl(items: [NSLocalizedString("searchLike", comment: ""), NSLocalizedString("searchExact", comment: "")])
        segmentedControl.setTitle(NSLocalizedString("searchLike", comment: ""), forSegmentAtIndex: 0)
        segmentedControl.setTitle(NSLocalizedString("searchExact", comment: ""), forSegmentAtIndex: 1)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: "segmentedControlChanged:", forControlEvents: .ValueChanged)
        let barb = UIBarButtonItem(customView: segmentedControl)
        let flex = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        toolBar.items = [flex, barb, flex]
        
        // hide navigationController's builtin toolbar at start
        navigationController?.toolbarHidden = true
        
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "orientationChanged:", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        searchAutocomplete.setup(view, searchBarDelegate: self, searchBar: searchBar)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // submit new search after search type changed
    // if there is some text in search bar
    func segmentedControlChanged(sender: AnyObject) {
        if (!searchBar.text.isEmpty) {
            searchBarSearchButtonClicked(searchBar)
        }
    }
    
    func findNavBarHairline() -> UIImageView? {
        var a,b: UIView
        for a in navigationController?.navigationBar.subviews as! [UIView] {
            for b in a.subviews as! [UIView] {
                if (b.isKindOfClass(UIImageView) && b.bounds.size.width == self.navigationController?.navigationBar.frame.size.width &&
                    b.bounds.size.height < 2) {
                        return b as? UIImageView
                }
            }
        }
        return nil
    }
    
    func makeTableHeaderView() {
        let view = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 22))
        view.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        let label = UILabel(frame: CGRectMake(0, 0, tableView.frame.size.width, 22))
        label.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        view.addSubview(label)
        label.textAlignment = .Center
        
        tableHeaderLabel = label
        
        tableView.tableHeaderView = view
    }
    
    func updateResultsIndicator(count : Int) {
        self.tableHeaderLabel.text = String(format: NSLocalizedString("results", comment: ""), arguments: [count])
    }
    
    // MARK: - Storyboard connected actions
    
    @IBAction func menuButtonClicked(sender: AnyObject) {
        if (sideMenuController()?.sideMenu?.isMenuOpen == true) {
            hideSideMenuView()
        } else {
            showSideMenuView()
        }
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        hideSideMenuView()
        if let detailsViewController = segue.destinationViewController as? DetailsViewController {
            if let cell = sender as? ArticleTableViewCell {
                if let indexPath = self.tableView.indexPathForCell(cell) {
                    let article = self.articleDataSourceDelegate.articleForIndexPath(indexPath)
                    detailsViewController.articleToLoad = article
                }
            }
        }
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        hideSideMenuView()
        searchBar.text = searchBar.text.format_for_query()
        if (searchBar.text.length == 0) {
            return
        }
        searchBar.resignFirstResponder()
        
        if (count(searchBar.text) == 1 && segmentedControl.selectedSegmentIndex == 0) {
            let title = NSLocalizedString("youEnteredOnlyOneCharacter", comment: "")
            let message = NSLocalizedString("theSearchWillBeMadeInExactMode", comment: "")
            let cancelButtonTitle = NSLocalizedString("OK", comment: "")
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .Cancel) { action in
                // do nothing
            }
            alertController.addAction(cancelAction)
            
            segmentedControl.selectedSegmentIndex = 1
            
            presentViewController(alertController, animated: true, completion: nil)
        }
        
        if (articleLoader.queryResult?.query != query) {
            articleLoader.loadArticlesByQuery(query)
        }
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        hideSideMenuView()
        showToolBar()
        searchAutocomplete.textDidChange(searchBar.text)
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        hideToolBar()
        searchAutocomplete.hideAutocompleteTable()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchAutocomplete.textDidChange(searchText)
    }
    
    // MARK: - ArtcileLoaderDelegate
    
    func loaderWillLoad() {
        showProgressIndicator()
    }
    
    func loaderDidLoad(queryResult: QueryResult) {
        hideProgressIndicator()
        articleDataSourceDelegate.articles_count = queryResult.articles.count
        articleDataSourceDelegate.sections = queryResult.sections
        tableView.reloadData()
        updateResultsIndicator(articleDataSourceDelegate.articles_count)
        tableView.setContentOffset(CGPointZero, animated: true)
        
        if (queryResult.articles.count == 0) && (segmentedControl.selectedSegmentIndex == 1) && (searchBar.text.length > 1) {
            let title = NSLocalizedString("nothingFound", comment: "")
            let message = NSLocalizedString("youDidSearchUsingExactMode", comment: "")
            let okButtonTitle = NSLocalizedString("OK", comment: "")
            let cancelButtonTitle = NSLocalizedString("Cancel", comment: "")
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            let okAction = UIAlertAction(title: okButtonTitle, style: .Cancel) { action in
                // resubmit query in Like mode
                self.segmentedControl.selectedSegmentIndex = 0
                self.searchBarSearchButtonClicked(self.searchBar)
            }
            let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .Default) { action in
                // make searchBar active
                self.searchBar.becomeFirstResponder()
            }
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)

            presentViewController(alertController, animated: true, completion: nil)
        }
        
        if let firstArticle = queryResult.sections.first?.articles.first {
            // save search history
            var detailsString = firstArticle.ar_inf.string.bidiWrapped() + ": "
            if (firstArticle.translation.string.length > 30) {
                detailsString += "\((firstArticle.translation.string as NSString).substringToIndex(30))...".bidiWrapped(true)
            } else {
                detailsString += firstArticle.translation.string.bidiWrapped(true)
            }
            
            let sh = SearchHistory(searchString: getStringFromQuery(queryResult.query), details: detailsString.bidiWrapped(true))

            searchAutocomplete.saveSearchHistory(sh)
        }
    }
    
    // MARK: - UIDeviceOrientationDidChangeNotification
    
    func orientationChanged(notification: NSNotification) {
        // orientation change while toolBar is shown
        // should recalc its frame and redraw it
        // toolBar.frame.origin.y should be 20 in portrait mode (64 - 44)
        // and -12 in landscape mode (32 - 44)
        if (toolBarShown && toolBar.frame.origin.y <= 20) {
            toolBarShown = false
            showToolBar()
        }
    }
    
    // MARK: - UI Show & Hide
    
    func showToolBar() {
        // slide down top tool bar that extends nav bar
        if (!toolBarShown) {
            // slide down top tool bar that extends nav bar
            let frame = CGRectMake(0, toolBar.frame.origin.y + toolBar.frame.height, toolBar.frame.width, toolBar.frame.height)
            UIView.animateWithDuration(0.3, animations: {
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
            let frame = CGRectMake(0, toolBar.frame.origin.y - toolBar.frame.height, toolBar.frame.width, toolBar.frame.height)
            UIView.animateWithDuration(0.3, animations: {
                self.toolBar.frame = frame
                self.navHairline?.alpha = 1.0
                self.toolBar.alpha = 0.0
            })
            toolBarShown = false
        }
    }
    
    func showProgressIndicator() {
        progressActivityIndicator.startAnimating()
        tableView.hidden = true
    }
    
    func hideProgressIndicator() {
        progressActivityIndicator.stopAnimating()
        tableView.hidden = false
    }
    
    func selectMenuButton(selected: Bool) {
        if (selected) {
            searchBar.resignFirstResponder()
            menuButton.tintColor = UIColor.tintSelected()
        } else {
            menuButton.tintColor = self.view.tintColor
        }
    }
}
