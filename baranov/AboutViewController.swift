//
//  AboutViewController.swift
//  baranov
//
//  Created by Ivan on 12/07/15.
//  Copyright (c) 2015 Rabotyaga. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    
    let siteUrl = "http://bars.org.ru/about"
    let itunesUrl = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=APP_ID&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software"
    let appId = "1021251680";
    
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
        
        self.title = NSLocalizedString("about", comment: "")
        
        appNameLongLabel.text = NSLocalizedString("appNameLong", comment: "")
        if let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            versionLabel.text = NSLocalizedString("version", comment: "") + appVersion
        } else {
            versionLabel.text = NSLocalizedString("version", comment: "")
        }

        copyrightLabel.text = NSLocalizedString("copyright", comment: "")
        makeReviewButton.setTitle(NSLocalizedString("makeReview", comment: ""), for: UIControl.State())
        descriptionLabel.text = NSLocalizedString("description", comment: "")
        descriptionLabel.sizeToFit()
        description2Label.text = NSLocalizedString("description2", comment: "")
        description2Label.sizeToFit()
        goToSiteButton.setTitle(NSLocalizedString("goToSite", comment: ""), for: UIControl.State())
        
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
    
    @IBAction func makeReviewButtonClicked(_ sender: AnyObject) {
        if let url = URL(string: itunesUrl.replacingOccurrences(of: "APP_ID", with: appId, options: .literal, range: nil)) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func goToSiteButtonClicked(_ sender: AnyObject) {
        if let url = URL(string: siteUrl) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
