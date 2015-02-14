//
//  LabelCell.swift
//  Yelp
//
//  Created by Kristen on 2/13/15.
//  Copyright (c) 2015 Kristen Sundquist. All rights reserved.
//

import UIKit

class LabelCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .None
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
