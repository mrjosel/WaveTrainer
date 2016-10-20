//
//  OneRepMaxTableViewCell.swift
//  WaveTrainer
//
//  Created by Brian Josel on 10/12/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import UIKit

//sell for one rep max table
class OneRepMaxTableViewCell: UITableViewCell, UITextFieldDelegate {

    //outlets
    @IBOutlet weak var textField: UITextField!
    
    //core lift, used in updating oneRmMaxes
    var coreLift : CoreLift?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    //when editing ends, check which lift and update
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        //get core lift and text in Int format
        guard let lift = self.coreLift, let text = textField.text, let weight = Int(text) else {
            //do nothing
            return
        }
        WorkoutManagerClient.sharedInstance.oneRepMaxes[lift.description] = weight
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
