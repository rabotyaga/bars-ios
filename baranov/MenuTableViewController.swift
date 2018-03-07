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
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.clear
        tableView.scrollsToTop = false
        
        self.clearsSelectionOnViewWillAppear = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu.count
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell")
        
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "MenuCell")
            cell!.backgroundColor = UIColor.clear
            cell!.textLabel?.textColor = UIColor.darkGray
            let selectedBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: cell!.frame.size.width, height: cell!.frame.size.height))
            selectedBackgroundView.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
            cell!.selectedBackgroundView = selectedBackgroundView
        }
        
        cell!.textLabel?.text = menu[indexPath.row].name
        
        if (indexPath.row == 3) {
            cell!.textLabel?.font = UIFont.systemFont(ofSize: 14)
            cell!.textLabel?.lineBreakMode = .byWordWrapping
            cell!.textLabel?.preferredMaxLayoutWidth = cell!.frame.size.width
            cell!.textLabel?.numberOfLines = 0
            if (myDatabase.searchHistoryCount() == 0) {
                cell!.textLabel?.textColor = UIColor.lightGray
            } else {
                cell!.textLabel?.textColor = UIColor.darkGray
            }
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        toggleSideMenuView()
        
        // first & 2nd menu lines have controllerName
        if (!menu[indexPath.row].controllerName.isEmpty) {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
            let destViewController = mainStoryboard.instantiateViewController(withIdentifier: menu[indexPath.row].controllerName) 
            
            sideMenuController()?.pushViewController(destViewController)
        }
        
        //last one - delete search history
        if indexPath.row == 3 {
            let message = NSLocalizedString("deleteSearchHistory", comment: "") + "?"
            let okButtonTitle = NSLocalizedString("delete", comment: "")
            let cancelButtonTitle = NSLocalizedString("Cancel", comment: "")
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: okButtonTitle, style: .cancel) { action in
                // delete
                self.myDatabase.clearSearchHistory()
            }
            let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .default) { action in
                // do nothing
            }
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            
            sideMenuController()?.present(alertController, animated: true, completion: nil)
        }
    }
}
