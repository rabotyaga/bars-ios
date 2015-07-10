//
//  MainViewController.swift
//  baranov
//
//  Created by Ivan on 06/07/15.
//  Copyright (c) 2015 Rabotyaga. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, ArticleLoaderDelegate {

    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progressActivityIndicator: UIActivityIndicatorView!
    
    // later
    @IBOutlet weak var searchAutocompleteTableView: UITableView!

    
    var searchBar: UISearchBar!
    var navHairline: UIImageView?
    var segmentedControl: UISegmentedControl!
    var tableHeaderLabel: UILabel!
    
    let articleDataSourceDelegate = ArticleDataSourceDelegate.sharedInstance
    var articleLoader : ArticleLoader!
    
    var query: AQuery {
        get {
            if (segmentedControl.selectedSegmentIndex == 0) {
                return AQuery.Like(searchBar.text.lowercaseString)
            } else {
                return AQuery.Exact(searchBar.text.lowercaseString)
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
        
        // special imageView with 0.5px height line at the bottom of navbar
        // find & store it for later hiding/showing
        // when showing/hiding toolbar
        // to make toolbat visually extend navbar
        navHairline = findNavBarHairline()
        
        // main table view setup
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 130
        tableView.delegate = self.articleDataSourceDelegate
        tableView.dataSource = self.articleDataSourceDelegate
        
        // results count indicator
        // as a main table header
        self.makeTableHeaderView()
        
        
        
        //??
        //definesPresentationContext = true
        
        // autocomplete table setup
        // just hide it - it doesn't work
        searchAutocompleteTableView.hidden = true
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func makeTableHeaderView() {
        let view = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 22))
        view.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        let label = UILabel(frame: CGRectMake(0, 0, tableView.frame.size.width, 22))
        label.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        view.addSubview(label)
        label.textAlignment = .Center
        
        self.tableHeaderLabel = label
        
        self.tableView.tableHeaderView = view
    }
    
    func updateResultsIndicator(count : Int) {
        self.tableHeaderLabel.text = String(format: NSLocalizedString("results", comment: ""), arguments: [count])
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.text = searchBar.text.stripForbiddenCharacters()
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
            
            self.segmentedControl.selectedSegmentIndex = 1
            
            presentViewController(alertController, animated: true, completion: nil)
        }
        
        self.articleLoader.loadArticlesByQuery(self.query)
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.showToolBar()
        //showAutocompleteTable()
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        self.hideToolBar()
        //hideAutocompleteTable()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        // for autocomplete
        //println("s \(searchText)")
    }
    
    // MARK: - ArtcileLoaderDelegate
    
    func loaderWillLoad() {
        self.showProgressIndicator()
    }
    
    func loaderDidLoad(queryResult: QueryResult) {
        self.hideProgressIndicator()
        self.articleDataSourceDelegate.articles_count = queryResult.articles.count
        self.articleDataSourceDelegate.sections = queryResult.sections
        self.tableView.reloadData()
        self.updateResultsIndicator(self.articleDataSourceDelegate.articles_count)
    }
    
    // MARK: - UI Show & Hide
    
    func showToolBar() {
        self.toolBar.hidden = false
        UIView.animateWithDuration(0.3, animations: {
            self.toolBar.alpha = 1.0
            self.navHairline?.alpha = 0.0
            }, completion: {
                (value: Bool) in
                self.navHairline?.hidden = true
        })
    }
    
    func hideToolBar() {
        self.navHairline?.hidden = false
        UIView.animateWithDuration(0.3, animations: {
            self.toolBar.alpha = 0.0
            self.navHairline?.alpha = 1.0
            }, completion: {
                (value: Bool) in
                self.toolBar.hidden = true
        })
        
    }
    
    func showProgressIndicator() {
        self.progressActivityIndicator.startAnimating()
        self.tableView.hidden = true
    }
    
    func hideProgressIndicator() {
        self.progressActivityIndicator.stopAnimating()
        self.tableView.hidden = false
    }

    /*
    func showAutocompleteTable() {
        self.searchAutocompleteTableView.hidden = false
    }
    
    func hideAutocompleteTable() {
        self.searchAutocompleteTableView.hidden = true
    }
    
    */
    
    

}