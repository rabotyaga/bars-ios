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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ArticleTableViewCell
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
        cell.bounds = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 99999)
        cell.contentView.bounds = cell.bounds
        cell.layoutIfNeeded()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 22))
        view.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 22))
        label.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
        label.text = self.sections[section].name
        view.addSubview(label)
        view.backgroundColor = UIColor.headerBg()
        label.textAlignment = .center
        return view
    }
    
    func articleForIndexPath(_ indexPath: IndexPath) -> Article {
        let article = self.sections[indexPath.section].articles[indexPath.row]
        return article
    }
    
    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        if (action == #selector(UIResponderStandardEditActions.copy(_:))) {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        if (action == #selector(UIResponderStandardEditActions.copy(_:))) {
            articleForIndexPath(indexPath).copyToClipboard()
        }
    }
}
