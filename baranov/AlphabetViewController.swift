//
//  AlphabetViewController.swift
//  baranov
//
//  Created by Ivan on 12/07/15.
//  Copyright (c) 2015 Rabotyaga. All rights reserved.
//

import UIKit

class AlphabetViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // hide navigationController's builtin toolbar
        self.navigationController?.setToolbarHidden(true, animated: true)

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

}
