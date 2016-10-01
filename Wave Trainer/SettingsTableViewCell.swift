//
//  SettingsTableViewCell.swift
//  WaveTrainer
//
//  Created by Brian Josel on 9/26/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import UIKit

//custom cell for settingsVC
class SettingsTableViewCell: UITableViewCell {

    //editable textField
    @IBOutlet weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
