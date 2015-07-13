//
//  AlphabetTableViewCell.swift
//  baranov
//
//  Created by Ivan on 13/07/15.
//  Copyright (c) 2015 Rabotyaga. All rights reserved.
//

import UIKit

class AlphabetTableViewCell: UITableViewCell {

    @IBOutlet weak var nrLabel: UILabel!
    @IBOutlet weak var letterLabel: UILabel!
    @IBOutlet weak var nvLabel: UILabel!
    @IBOutlet weak var inTheBeginningLabel: UILabel!
    @IBOutlet weak var inTheMiddleLabel: UILabel!
    @IBOutlet weak var inTheEndLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var nvLabelTopSpace: NSLayoutConstraint!
    @IBOutlet weak var nvLabelHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
