//
//  MenuTableViewController.swift
//  baranov
//
//  Created by Ivan on 13/07/15.
//  Copyright (c) 2015 Rabotyaga. All rights reserved.
//

import UIKit

struct MenuItem {
    let name: String
    let controllerName: String
}

class MenuTableViewController: UITableViewController {
    
    let myDatabase = MyDatabase.sharedInstance
    
    let menu = [
        MenuItem(name: NSLocalizedString("alphabet", comment: ""), controllerName: "AlphabetViewController"),
        MenuItem(name: NSLocalizedString("about", comment: ""), controllerName: "AboutViewController"),
        MenuItem(name: "", controllerName: ""),
        MenuItem(name: NSLocalizedString("deleteSearchHistory", comment: ""), controllerName: "")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Customize apperance of table view
        tableView.contentInset = UIEdgeInsetsMake(64.0, 0, 0, 0) //
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor.clearColor()
        tableView.scrollsToTop = false
        
        self.clearsSelectionOnViewWillAppear = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu.count
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if (indexPath.row == 2) {
            // "separator"/empty menu line
            return nil
        }
        
        if (indexPath.row == 3) {
            if (myDatabase.searchHistoryCount() == 0) {
                return nil
            }
        }
        
        return indexPath
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("MenuCell") as? UITableViewCell
        
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "MenuCell")
            cell!.backgroundColor = UIColor.clearColor()
            cell!.textLabel?.textColor = UIColor.darkGrayColor()
            let selectedBackgroundView = UIView(frame: CGRectMake(0, 0, cell!.frame.size.width, cell!.frame.size.height))
            selectedBackgroundView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
            cell!.selectedBackgroundView = selectedBackgroundView
        }
        
        cell!.textLabel?.text = menu[indexPath.row].name
        
        if (indexPath.row == 3) {
            cell!.textLabel?.font = UIFont.systemFontOfSize(14)
            cell!.textLabel?.lineBreakMode = .ByWordWrapping
            cell!.textLabel?.preferredMaxLayoutWidth = cell!.frame.size.width
            cell!.textLabel?.numberOfLines = 0
            if (myDatabase.searchHistoryCount() == 0) {
                cell!.textLabel?.textColor = UIColor.lightGrayColor()
            } else {
                cell!.textLabel?.textColor = UIColor.darkGrayColor()
            }
        }
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)

        toggleSideMenuView()
        
        // first & 2nd menu lines have controllerName
        if (!menu[indexPath.row].controllerName.isEmpty) {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
            let destViewController = mainStoryboard.instantiateViewControllerWithIdentifier(menu[indexPath.row].controllerName) as! UIViewController
            
            sideMenuController()?.pushViewController(destViewController)
        }
        
        //last one - delete search history
        if indexPath.row == 3 {
            let message = NSLocalizedString("deleteSearchHistory", comment: "") + "?"
            let okButtonTitle = NSLocalizedString("delete", comment: "")
            let cancelButtonTitle = NSLocalizedString("Cancel", comment: "")
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
            let okAction = UIAlertAction(title: okButtonTitle, style: .Cancel) { action in
                // delete
                self.myDatabase.clearSearchHistory()
            }
            let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .Default) { action in
                // do nothing
            }
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            
            sideMenuController()?.presentViewController(alertController, animated: true, completion: nil)
        }
    }
}
