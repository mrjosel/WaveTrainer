//
//  SettingItemCell.swift
//  WaveTrainer
//
//  Created by Brian Josel on 10/2/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import UIKit

//custom cell that has textField
class SettingItemCell: UITableViewCell {

    //textField outlet
    @IBOutlet weak var textField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
