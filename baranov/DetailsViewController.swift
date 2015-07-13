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
            articleLoader.loadArticlesByQuery(AQuery.Root(article.root))
            self.title = NSLocalizedString("root", comment: "") + article.root
        }
        
        self.navigationController?.delegate = self
        self.navigationController?.toolbarHidden = false
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

    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        // hiding navigationController's builtin toolbar
        // when going back to MainViewController
        if let vc = viewController as? MainViewController {
            self.navigationController?.setToolbarHidden(true, animated: true)
        }
    }
    
    // MARK: - ArtcileLoaderDelegate
    
    func loaderWillLoad() {
        self.showProgressIndicator()
    }
    
    func loaderDidLoad(queryResult: QueryResult) {
        self.hideProgressIndicator()
        if let root = queryResult.articles.first?.root {
            self.title = NSLocalizedString("root", comment: "") + root
        }
        self.detailsDataSource.articles = queryResult.articles
        self.tableView.reloadData()
        if let a = articleToLoad {
            if let i = find(queryResult.articles, a) {
                let selectedIndexPath = NSIndexPath(forRow: i, inSection: 0)
                
                // there is a bug in iOS 7.x-8.4
                // with scrolling tableView with autoLayout cell height
                // as a dirty workaround sometimes helps calling scroll twice
                self.tableView.selectRowAtIndexPath(selectedIndexPath, animated: false, scrollPosition: .Bottom)
                self.tableView.selectRowAtIndexPath(selectedIndexPath, animated: true, scrollPosition: .Middle)
            }
        } else {
            self.tableView.setContentOffset(CGPointZero, animated: true)
        }
        if (queryResult.articles.first?.nr == 1) {
            backToolbarButton.enabled = false
        } else {
            backToolbarButton.enabled = true
            if (queryResult.articles.last?.nr == articleLoader.lastArticleNr()) {
                forwardToolbarButton.enabled = false
            } else {
                forwardToolbarButton.enabled = true
            }
        }
        self.tableView.allowsSelection = false
    }
    
    // MARK: - Storyboard connected toolbar buttons actions
    
    @IBAction func loadPreviousRoot(sender: AnyObject) {
        if let a = articleToLoad {
            articleToLoad = nil
        }
        articleLoader.loadPreviousRoot();
    }
    
    @IBAction func loadNextRoot(sender: AnyObject) {
        if let a = articleToLoad {
            articleToLoad = nil
        }
        articleLoader.loadNextRoot();
    }
    
    // MARK: - UI Show & Hide
    
    func showProgressIndicator() {
        self.progressActivityIndicator.startAnimating()
        self.tableView.hidden = true
    }
    
    func hideProgressIndicator() {
        self.progressActivityIndicator.stopAnimating()
        self.tableView.hidden = false
    }
}
