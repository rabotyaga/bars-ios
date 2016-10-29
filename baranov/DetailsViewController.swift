//
//  DetailsViewController.swift
//  baranov
//
//  Created by Ivan on 10/07/15.
//  Copyright (c) 2015 Rabotyaga. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController, ArticleLoaderDelegate, UINavigationControllerDelegate, UITableViewDelegate {
    
    var articleToLoad: Article?

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progressActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var backToolbarButton: UIBarButtonItem!
    @IBOutlet weak var forwardToolbarButton: UIBarButtonItem!
    
    let detailsDataSource = DetailsDataSource()
    var articleLoader: ArticleLoader!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // loader setup
        articleLoader = ArticleLoader(delegate: self)

        // main table view setup
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 130
        tableView.dataSource = self.detailsDataSource
        tableView.delegate = self.detailsDataSource
        
        if let article = articleToLoad {
            articleLoader.loadArticlesByQuery(AQuery.root(article.root))
            self.title = NSLocalizedString("root", comment: "") + article.root
        }
        
        self.navigationController?.delegate = self
        self.navigationController?.isToolbarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

    }*/
    
    // MARK: - UINavigationControllerDelegate

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        // hiding navigationController's builtin toolbar
        // when going back to MainViewController
        if let _ = viewController as? MainViewController {
            self.navigationController?.setToolbarHidden(true, animated: true)
        }
    }
    
    // MARK: - ArtcileLoaderDelegate
    
    func loaderWillLoad() {
        self.showProgressIndicator()
    }
    
    func loaderDidLoad(_ queryResult: QueryResult) {
        self.hideProgressIndicator()
        if let root = queryResult.articles.first?.root {
            self.title = NSLocalizedString("root", comment: "") + root
        }
        self.detailsDataSource.articles = queryResult.articles
        self.tableView.reloadData()
        if let a = articleToLoad {
            if let i = queryResult.articles.index(of: a) {
                let selectedIndexPath = IndexPath(row: i, section: 0)
                
                // there is a bug in iOS 7.x-8.4
                // with scrolling tableView with autoLayout cell height
                // as a dirty workaround sometimes helps calling scroll twice
                self.tableView.selectRow(at: selectedIndexPath, animated: false, scrollPosition: .bottom)
                self.tableView.selectRow(at: selectedIndexPath, animated: true, scrollPosition: .middle)
            }
        } else {
            self.tableView.setContentOffset(CGPoint.zero, animated: true)
        }
        if (queryResult.articles.first?.nr == 1) {
            backToolbarButton.isEnabled = false
        } else {
            backToolbarButton.isEnabled = true
            if (queryResult.articles.last?.nr == articleLoader.lastArticleNr()) {
                forwardToolbarButton.isEnabled = false
            } else {
                forwardToolbarButton.isEnabled = true
            }
        }
        self.tableView.allowsSelection = false
    }
    
    // MARK: - Storyboard connected toolbar buttons actions
    
    @IBAction func loadPreviousRoot(_ sender: AnyObject) {
        if let _ = articleToLoad {
            articleToLoad = nil
        }
        try! articleLoader.loadPreviousRoot();
    }
    
    @IBAction func loadNextRoot(_ sender: AnyObject) {
        if let _ = articleToLoad {
            articleToLoad = nil
        }
        try! articleLoader.loadNextRoot();
    }
    
    // MARK: - UI Show & Hide
    
    func showProgressIndicator() {
        self.progressActivityIndicator.startAnimating()
        self.tableView.isHidden = true
    }
    
    func hideProgressIndicator() {
        self.progressActivityIndicator.stopAnimating()
        self.tableView.isHidden = false
    }
}
