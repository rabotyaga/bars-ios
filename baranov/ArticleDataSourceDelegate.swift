//
//  ArticleDataSource.swift
//  baranov
//
//  Created by Ivan on 07/07/15.
//  Copyright (c) 2015 Rabotyaga. All rights reserved.
//

import UIKit

class ArticleDataSourceDelegate: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var articles_count: Int = 0
    var sections: [SectionInfo] = []
    //var selectedArticle: Article?
    
    override init() {
        super.init()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].rows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ArticleTableViewCell
        let article = articleForIndexPath(indexPath)
        
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
        
        // needed for the 1st run to place label & textView correctly
        //cell.layoutIfNeeded()
        cell.bounds = CGRect(x: 0, y: 0, width: CGRectGetWidth(tableView.bounds), height: 99999)
        cell.contentView.bounds = cell.bounds
        cell.layoutIfNeeded()
        
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 22))
        view.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        let label = UILabel(frame: CGRectMake(0, 0, tableView.frame.size.width, 22))
        label.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        label.text = self.sections[section].name
        view.addSubview(label)
        view.backgroundColor = UIColor.headerBg()
        label.textAlignment = .Center
        return view
    }
    
    func articleForIndexPath(indexPath: NSIndexPath) -> Article {
        let article = self.sections[indexPath.section].articles[indexPath.row]
        return article
    }
    
    func tableView(tableView: UITableView, shouldShowMenuForRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, canPerformAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject) -> Bool {
        if (action == "copy:") {
            return true
        }
        return false
    }
    
    func tableView(tableView: UITableView, performAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject!) {
        if (action == "copy:") {
            articleForIndexPath(indexPath).copyToClipboard()
        }
    }
}
