//
//  AboutViewController.swift
//  baranov
//
//  Created by Ivan on 12/07/15.
//  Copyright (c) 2015 Rabotyaga. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    
    let siteUrl = "https://desolate-island-2917.herokuapp.com/about"
    let itunesUrl = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=APP_ID&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software"
    let appId = "123456789";
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var appNameLongLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var copyrightLabel: UILabel!
    @IBOutlet weak var makeReviewButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var description2Label: UILabel!
    @IBOutlet weak var goToSiteButton: UIButton!

    @IBOutlet var mainView: UIView!
    @IBOutlet weak var topSpace: NSLayoutConstraint!
    @IBOutlet weak var bottomSpace: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appNameLongLabel.text = NSLocalizedString("appNameLong", comment: "")
        if let appVersion = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String {
            versionLabel.text = NSLocalizedString("version", comment: "") + appVersion
        } else {
            versionLabel.text = NSLocalizedString("version", comment: "")
        }

        copyrightLabel.text = NSLocalizedString("copyright", comment: "")
        makeReviewButton.setTitle(NSLocalizedString("makeReview", comment: ""), forState: .Normal)
        descriptionLabel.text = NSLocalizedString("description", comment: "")
        descriptionLabel.sizeToFit()
        description2Label.text = NSLocalizedString("description2", comment: "")
        description2Label.sizeToFit()
        goToSiteButton.setTitle(NSLocalizedString("goToSite", comment: ""), forState: .Normal)
        
        // hide navigationController's builtin toolbar
        self.navigationController?.setToolbarHidden(true, animated: false)
        
        // adjust top & bottom space constraints
        var vertSpace: CGFloat
        if (mainView.bounds.height <= 480) {
            vertSpace = mainView.bounds.height / 20
        } else {
            if (mainView.bounds.height <= 568) {
                vertSpace = mainView.bounds.height / 10
            } else {
                vertSpace = mainView.bounds.height / 5
            }
        }
        topSpace.constant = vertSpace
        bottomSpace.constant = vertSpace
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Storyboard connected buttons actions
    
    @IBAction func makeReviewButtonClicked(sender: AnyObject) {
        if let url = NSURL(string: itunesUrl.stringByReplacingOccurrencesOfString("APP_ID", withString: appId, options: .LiteralSearch, range: nil)) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    @IBAction func goToSiteButtonClicked(sender: AnyObject) {
        if let url = NSURL(string: siteUrl) {
            UIApplication.sharedApplication().openURL(url)
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
