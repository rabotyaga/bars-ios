//
//  MyNavigationController.swift
//  baranov
//
//  Created by Ivan on 13/07/15.
//  Copyright (c) 2015 Rabotyaga. All rights reserved.
//

import UIKit

class MyNavigationController: ENSideMenuNavigationController, ENSideMenuDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        sideMenu = ENSideMenu(sourceView: self.view, menuViewController: MenuTableViewController(), menuPosition: .Left)
        sideMenu?.delegate = self
        //sideMenu?.bouncingEnabled = false
        
        // make navigation bar showing over side menu
        view.bringSubviewToFront(navigationBar)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - ENSideMenu Delegate
    
    func sideMenuShouldOpenSideMenu() -> Bool {
        // open side menu only in MainViewController
        if let _ = topViewController as? MainViewController {
            return true
        } else {
            return false
        }
    }
    
    func sideMenuWillClose() {
        if let mainViewController = topViewController as? MainViewController {
            mainViewController.selectMenuButton(false)
        }
    }
    
    func sideMenuWillOpen() {
        if let menuTableViewController = sideMenu?.menuViewController as? UITableViewController {
            // reload menu table to check search history emptyness
            menuTableViewController.tableView.reloadData()
        }

        if let mainViewController = topViewController as? MainViewController {
            mainViewController.selectMenuButton(true)
        }
    }
}
