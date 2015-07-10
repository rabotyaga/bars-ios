//
//  DetailsViewController.swift
//  baranov
//
//  Created by Ivan on 10/07/15.
//  Copyright (c) 2015 Rabotyaga. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController, ArticleLoaderDelegate {
    
    var articleToLoad: Article?

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progressActivityIndicator: UIActivityIndicatorView!
    
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
        
        if let article = articleToLoad {
            articleLoader.loadArticlesByQuery(AQuery.Root(article.root))
            self.title = NSLocalizedString("root", comment: "") + article.root
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - ArtcileLoaderDelegate
    
    func loaderWillLoad() {
        self.showProgressIndicator()
    }
    
    func loaderDidLoad(queryResult: QueryResult) {
        self.hideProgressIndicator()
        self.detailsDataSource.articles = queryResult.articles
        self.tableView.reloadData()
        if let a = articleToLoad {
            if let i = find(queryResult.articles, a) {
                let selectedIndexPath = NSIndexPath(forRow: i, inSection: 0)
                
                // there is a bug in iOS 7.x-8.4
                // with scrolling tableView with autoLayout cell height
                // as a dirty workaround sometimes helps calling scroll twice
                self.tableView.selectRowAtIndexPath(selectedIndexPath, animated: false, scrollPosition: .Top)
                self.tableView.selectRowAtIndexPath(selectedIndexPath, animated: true, scrollPosition: .Top)
            }
        }
        self.tableView.allowsSelection = false
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
