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

        sideMenu = ENSideMenu(sourceView: self.view, menuViewController: MenuTableViewController(), menuPosition:.Left)
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
        if let mainViewController = topViewController as? MainViewController {
            return true
        } else {
            return false
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
