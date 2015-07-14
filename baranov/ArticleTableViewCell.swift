//
//  ArticleTableViewCell.swift
//  baranov
//
//  Created by Ivan on 04/07/15.
//  Copyright (c) 2015 Rabotyaga. All rights reserved.
//

import UIKit

class ArticleTableViewCell: UITableViewCell {

    @IBOutlet weak var arInfLabel: UILabel!
    @IBOutlet weak var translationTextView: UITextView!
    
    @IBOutlet weak var homonymNrLabel: UILabel!

    @IBOutlet weak var vocalizationLabel: UILabel!
    
    @IBOutlet weak var transcriptionLabel: UILabel!
    
    @IBOutlet weak var optsLabel: UILabel!
    @IBOutlet weak var formLabel: UILabel!
    
    @IBOutlet weak var optsTopSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var formTopSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var optsHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var formHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let bgSelectedView = UIView()
        bgSelectedView.backgroundColor = UIColor.selectedBg()
        self.selectedBackgroundView = bgSelectedView
        
        //accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
