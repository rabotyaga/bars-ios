//
//  SearchAutocompleteTableView.swift
//  baranov
//
//  Created by Ivan on 06/07/15.
//  Copyright (c) 2015 Rabotyaga. All rights reserved.
//

import UIKit

struct searchHistoryStruct {
    var str1 : String
    var str2 : String
}

class SearchAutocompleteTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    var searchHistory : [searchHistoryStruct]!
    //var tableView: UITableView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    

    func configure() {
        searchHistory = []
        var i = 0
        for i in 0...10 {
            let a = searchHistoryStruct(str1: "str1 \(i)", str2: "")
            searchHistory.append(a)
        }
        
        //tableView = UITableView(frame: CGRectMake(0, 0, self.frame.width, self.frame.height))

        delegate = self
        dataSource = self
        backgroundColor = UIColor.navBarBg()
        //tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        //self.addSubview(tableView)
        //reloadData()
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
       let cell = tableView.dequeueReusableCellWithIdentifier("AutocompleteCell", forIndexPath: indexPath) as! UITableViewCell
        
        cell.backgroundColor = UIColor.clearColor()

        cell.detailTextLabel?.text = searchHistory[indexPath.row].str1
        cell.textLabel?.text = searchHistory[indexPath.row].str2
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        return
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchHistory.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    
}
