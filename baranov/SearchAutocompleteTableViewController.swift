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

        tableView.backgroundColor = UIColor.clear
        tableView.scrollsToTop = false
        
        self.clearsSelectionOnViewWillAppear = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(SearchAutocompleteTableViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SearchAutocompleteTableViewController.orientationChanged(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source & delegate

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchHistory.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell
        var cell = tableView.dequeueReusableCell(withIdentifier: "SearchHistoryCell")
        
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "SearchHistoryCell")
            cell!.backgroundColor = UIColor.clear
            //cell!.textLabel?.textColor = UIColor.darkGrayColor()
            let selectedBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: cell!.frame.size.width, height: cell!.frame.size.height))
            selectedBackgroundView.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
            cell!.selectedBackgroundView = selectedBackgroundView
        }
        
        cell!.textLabel?.text = searchHistory[indexPath.row].searchString
        cell!.detailTextLabel?.text = searchHistory[indexPath.row].details
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        searchBar.text = searchHistory[indexPath.row].searchString
        searchBarDelegate.searchBarSearchButtonClicked?(searchBar)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Allow edit
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            myDatabase.deleteSearchHistory(searchHistory[indexPath.row])
            searchHistory.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            if (searchHistory.count == 0) {
                hideAutocompleteTable()
            }
        }
    }
    
    // MARK: - search history logics
    
    func textDidChange(_ searchText: String) {
        searchHistory = myDatabase.getSearchHistory(searchText)
        tableView.reloadData()
        if (showing && searchHistory.count == 0) {
             hideAutocompleteTable()
        }
        if (!showing && searchHistory.count > 0) {
            showAutocompleteTable()
        }
    }
    
    func saveSearchHistory(_ searchHistory: SearchHistory) {
        myDatabase.saveSearchHistory(searchHistory)
    }
    
    func clearSearchHistory() {
        myDatabase.clearSearchHistory()
    }
    
    // MARK: - UIKeyboardWillShowNotification
    
    @objc func keyboardWillShow(_ notification: Notification) {
        let info = notification.userInfo!
        let value: AnyObject = info[UIKeyboardFrameEndUserInfoKey]! as AnyObject
        let rawFrame = value.cgRectValue
        let keyboardFrame = view.convert(rawFrame!, from: nil)

        let delta = keyboardFrame.height - keyboardHeight
        
        if (delta != 0) {
            //let animationDurationObj: AnyObject = info[UIKeyboardAnimationDurationUserInfoKey]!
            //let animationDuration = animationDurationObj.doubleValue!
            
            adjustContainerViewHeight(delta)//, duration: animationDuration)
            keyboardHeight = keyboardFrame.height
        }
    }
    
    // MARK: - UIDeviceOrientationDidChangeNotification
    
    @objc func orientationChanged(_ notification: Notification) {
        let orientation = UIDevice.current.orientation
        if (orientation == .faceDown || orientation == .faceUp) {
            // just ignore
            return
        }

        if #available(iOS 11.0, *) {
            originY = parentView.safeAreaInsets.top + 44
        } else {
            // iOS 10 / iPhone 5 default
            if (orientation == .landscapeLeft || orientation == .landscapeRight || orientation == .portraitUpsideDown) {
                originY = 76 //originYinLandscape: CGFloat = 76  // 32 nav bar + 44 tool bar
            } else {
                originY = 108 //originYinPortrait : CGFloat = 108 // 64 nav bar + 44 tool bar
            }
        }

        if (showing) {
            adjustContainerView()
        }
    }
    
    // MARK: - UI: frame adjust, show & hide
    
    func adjustContainerViewHeight(_ delta: CGFloat) {//, duration: Double) {
        myHeight = parentView.frame.height - originY - keyboardHeight - delta
        
        let frame = CGRect(x: containerView.frame.origin.x, y: containerView.frame.origin.y, width: containerView.frame.width, height: myHeight)

        //UIView.animateWithDuration(duration, animations: {
            self.containerView.frame = frame
        //})
    }
    
    func adjustContainerView() {
        myHeight = parentView.frame.height - originY - keyboardHeight
        containerView.frame = CGRect(x: showing ? parentView.frame.width - myWidth : parentView.frame.width, y: originY, width: myWidth, height: myHeight)
    }
    
    func showAutocompleteTable() {
        if (showing) {
            return
        }
        let frame = CGRect(x: parentView.frame.width - myWidth, y: originY, width: myWidth, height: myHeight)
        adjustContainerView()
        containerView.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
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
        let frame = CGRect(x: parentView.frame.width, y: originY, width: myWidth, height: myHeight)
        UIView.animate(withDuration: 0.3, animations: {
            self.containerView.frame = frame
            }, completion: {
                a in
                self.showing = false
                self.containerView.isHidden = true
            }
        )
    }
    
    // MARK: - Setup, called from MainViewController
    
    func setup(_ parentView: UIView, searchBarDelegate: UISearchBarDelegate, searchBar: UISearchBar) {
        self.parentView = parentView
        self.searchBarDelegate = searchBarDelegate
        self.searchBar = searchBar
        
        originY = 108 // iOS 10 /iPhone 5 default = originYinPortrait : CGFloat = 108 // 64 nav bar + 44 tool bar
        myHeight = parentView.frame.height - originY
        containerView.frame = CGRect(x: parentView.frame.width, y: originY, width: myWidth, height: myHeight)
        
        containerView.backgroundColor = UIColor.clear
        containerView.clipsToBounds = false
        containerView.layer.masksToBounds = false
        containerView.layer.shadowOffset = CGSize(width: -1.0, height: -1.0)
        containerView.layer.shadowRadius = 1.0
        containerView.layer.shadowOpacity = 0.125
        containerView.layer.shadowPath = UIBezierPath(rect: view.bounds).cgPath
        
        // Add blur view
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light)) as UIVisualEffectView
        visualEffectView.frame = containerView.bounds
        visualEffectView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        containerView.addSubview(visualEffectView)

        view.frame = containerView.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        containerView.addSubview(view)
        parentView.addSubview(containerView)
        
        containerView.isHidden = true
    }
}
