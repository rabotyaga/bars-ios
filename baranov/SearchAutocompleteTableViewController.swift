//
//  SearchAutocompleteTableViewController.swift
//  baranov
//
//  Created by Ivan on 15/07/15.
//  Copyright (c) 2015 Rabotyaga. All rights reserved.
//

import UIKit

struct SearchHistory {
    var searchString: String
    var details: String
}

class SearchAutocompleteTableViewController: UITableViewController, UISearchBarDelegate {
    
    let myDatabase = MyDatabase.sharedInstance
    
    let originYinPortrait : CGFloat = 108 // 64 nav bar + 44 tool bar
    let originYinLandscape: CGFloat = 76  // 32 nav bar + 44 tool bar
    
    let myWidth : CGFloat = 220
    // height & originY will change due to orientation change and keyboard
    var originY: CGFloat = 0
    var myHeight: CGFloat = 0
    var keyboardHeight: CGFloat = 0
    
    var showing: Bool = false

    weak var parentView: UIView!
    var containerView = UIView()
    
    var searchBar: UISearchBar!
    var searchBarDelegate: UISearchBarDelegate!

    var searchHistory: [SearchHistory] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundColor = UIColor.clearColor()
        tableView.scrollsToTop = false
        
        self.clearsSelectionOnViewWillAppear = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "orientationChanged:", name: UIDeviceOrientationDidChangeNotification, object: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source & delegate

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchHistory.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell
        var cell = tableView.dequeueReusableCellWithIdentifier("SearchHistoryCell") as? UITableViewCell
        
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "SearchHistoryCell")
            cell!.backgroundColor = UIColor.clearColor()
            //cell!.textLabel?.textColor = UIColor.darkGrayColor()
            let selectedBackgroundView = UIView(frame: CGRectMake(0, 0, cell!.frame.size.width, cell!.frame.size.height))
            selectedBackgroundView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
            cell!.selectedBackgroundView = selectedBackgroundView
        }
        
        cell!.textLabel?.text = searchHistory[indexPath.row].searchString
        cell!.detailTextLabel?.text = searchHistory[indexPath.row].details
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        searchBar.text = searchHistory[indexPath.row].searchString
        searchBarDelegate.searchBarSearchButtonClicked?(searchBar)
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Allow edit
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            myDatabase.deleteSearchHistory(searchHistory[indexPath.row])
            searchHistory.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    // MARK: - search history logics
    
    func textDidChange(searchText: String) {
        searchHistory = myDatabase.getSearchHistory(searchText)
        tableView.reloadData()
        if (showing && searchHistory.count == 0) {
             hideAutocompleteTable()
        }
        if (!showing && searchHistory.count > 0) {
            showAutocompleteTable()
        }
    }
    
    func saveSearchHistory(searchHistory: SearchHistory) {
        myDatabase.saveSearchHistory(searchHistory)
    }
    
    func clearSearchHistory() {
        myDatabase.clearSearchHistory()
    }
    
    // MARK: - UIKeyboardWillShowNotification
    
    func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let value: AnyObject = info[UIKeyboardFrameEndUserInfoKey]!
        let rawFrame = value.CGRectValue()
        let keyboardFrame = view.convertRect(rawFrame, fromView: nil)

        let delta = keyboardFrame.height - keyboardHeight
        
        if (delta != 0) {
            //let animationDurationObj: AnyObject = info[UIKeyboardAnimationDurationUserInfoKey]!
            //let animationDuration = animationDurationObj.doubleValue!
            
            adjustContainerViewHeight(delta)//, duration: animationDuration)
            keyboardHeight = keyboardFrame.height
        }
    }
    
    // MARK: - UIDeviceOrientationDidChangeNotification
    
    func orientationChanged(notification: NSNotification) {
        let orientation = UIDevice.currentDevice().orientation
        if (orientation == .FaceDown || orientation == .FaceUp) {
            // just ignore
            return
        }
        if (orientation == .LandscapeLeft || orientation == .LandscapeRight || orientation == .PortraitUpsideDown) {
            originY = originYinLandscape
        } else {
            originY = originYinPortrait
        }
        if (showing) {
            adjustContainerView()
        }
    }
    
    // MARK: - UI: frame adjust, show & hide
    
    func adjustContainerViewHeight(delta: CGFloat) {//, duration: Double) {
        myHeight = parentView.frame.height - originY - keyboardHeight - delta
        
        let frame = CGRectMake(containerView.frame.origin.x, containerView.frame.origin.y, containerView.frame.width, myHeight)

        //UIView.animateWithDuration(duration, animations: {
            self.containerView.frame = frame
        //})
    }
    
    func adjustContainerView() {
        myHeight = parentView.frame.height - originY - keyboardHeight
        containerView.frame = CGRectMake(showing ? parentView.frame.width - myWidth : parentView.frame.width, originY, myWidth, myHeight)
    }
    
    func showAutocompleteTable() {
        if (showing) {
            return
        }
        let frame = CGRectMake(parentView.frame.width - myWidth, originY, myWidth, myHeight)
        adjustContainerView()
        containerView.hidden = false
        UIView.animateWithDuration(0.3, animations: {
            self.containerView.frame = frame
            }, completion: {
                a in
                self.showing = true
            }
        )
    }
    
    func hideAutocompleteTable() {
        if (!showing) {
            return
        }
        let frame = CGRectMake(parentView.frame.width, originY, myWidth, myHeight)
        UIView.animateWithDuration(0.3, animations: {
            self.containerView.frame = frame
            }, completion: {
                a in
                self.showing = false
            }
        )
    }
    
    // MARK: - Setup, called from MainViewController
    
    func setup(parentView: UIView, searchBarDelegate: UISearchBarDelegate, searchBar: UISearchBar) {
        self.parentView = parentView
        self.searchBarDelegate = searchBarDelegate
        self.searchBar = searchBar
        
        originY = originYinPortrait
        myHeight = parentView.frame.height - originY
        containerView.frame = CGRectMake(parentView.frame.width, originY, myWidth, myHeight)
        
        containerView.backgroundColor = UIColor.clearColor()
        containerView.clipsToBounds = false
        containerView.layer.masksToBounds = false
        containerView.layer.shadowOffset = CGSizeMake(1.0, 1.0)
        containerView.layer.shadowRadius = 1.0
        containerView.layer.shadowOpacity = 0.125
        containerView.layer.shadowPath = UIBezierPath(rect: view.bounds).CGPath
        
        // Add blur view
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light)) as UIVisualEffectView
        visualEffectView.frame = containerView.bounds
        visualEffectView.autoresizingMask = .FlexibleHeight | .FlexibleWidth
        containerView.addSubview(visualEffectView)

        view.frame = containerView.bounds
        containerView.autoresizingMask = .FlexibleHeight | .FlexibleWidth
        
        containerView.addSubview(view)
        parentView.addSubview(containerView)
        
        containerView.hidden = true
    }

}
