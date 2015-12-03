//
//  DetailsDataSource.swift
//  baranov
//
//  Created by Ivan on 10/07/15.
//  Copyright (c) 2015 Rabotyaga. All rights reserved.
//

import UIKit

class DetailsDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var articles: [Article] = []
    
    override init() {
        super.init()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.articles.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DetailsCell", forIndexPath: indexPath) as! ArticleTableViewCell
        let article = articles[indexPath.row]
        
        cell.accessoryType = UITableViewCellAccessoryType.None
        
        cell.arInfLabel.attributedText = article.ar_inf
        cell.translationTextView.attributedText = article.translation
        cell.transcriptionLabel.text = article.transcription
        
        if (!article.form.isEmpty) {
            cell.formLabel.text = article.form
            cell.formHeightConstraint.constant = 20.0
            cell.formTopSpaceConstraint.constant = 5.0
        } else {
            cell.formLabel.text = ""
            cell.formHeightConstraint.constant = 0.0
            cell.formTopSpaceConstraint.constant = 0.0
        }
        if (article.opts.length > 0) {
            cell.optsLabel.attributedText = article.opts
            cell.optsHeightConstraint.constant = 20.0
            cell.optsTopSpaceConstraint.constant = 5.0
        } else {
            cell.optsLabel.text = ""
            cell.optsHeightConstraint.constant = 0.0
            cell.optsTopSpaceConstraint.constant = 0.0
        }
        
        if let v = article.vocalization {
            cell.vocalizationLabel.text = v
        } else {
            cell.vocalizationLabel.text = ""
        }
        
        if let h = article.homonym_nr {
            cell.homonymNrLabel.text = h.description
        } else {
            cell.homonymNrLabel.text = ""
        }
        
        // seems here auto layout & cell height do their work right
        // no need to do extra
        //cell.layoutIfNeeded()
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, shouldShowMenuForRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, canPerformAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        if (action == "copy:") {
            return true
        }
        return false
    }
    
    func tableView(tableView: UITableView, performAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
        if (action == "copy:") {
            articles[indexPath.row].copyToClipboard()
        }
    }
}
