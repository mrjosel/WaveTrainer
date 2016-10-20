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
        
        //get core lift
        guard let lift = coreLift else {
            //should never get to this point
            //TODO: ERROR?
            return
        }
        
        //set coreLift parameter based on lift
        switch lift {
//        case .OHP:
//            print(<#T##items: Any...##Any#>)
        default:
            print(lift.description)
        }
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
