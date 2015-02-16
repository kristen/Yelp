//
//  SwitchCell.swift
//  Yelp
//
//  Created by Kristen on 2/12/15.
//  Copyright (c) 2015 Kristen Sundquist. All rights reserved.
//

import UIKit

protocol SwitchCellDelegate : class {
    func switchCell(switchCell: SwitchCell, didUpdateValue value: Bool)
}

class SwitchCell: UITableViewCell {
    @IBOutlet weak var toggleSwitch: UISwitch!
    @IBOutlet weak var titleLabel: UILabel!
    
    weak var delegate: SwitchCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .None
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction private func switchValueChanged(sender: AnyObject) {
        delegate?.switchCell(self, didUpdateValue: toggleSwitch.on)
    }
}
