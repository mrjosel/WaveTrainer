//
//  OneRMTestViewController.swift
//  WaveTrainer
//
//  Created by Brian Josel on 10/10/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import UIKit

//allows for editing and viewing of 1 Rep Max numbers
class OneRMTestViewController: UITableViewController, UITextFieldDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    // MARK: DATA SOURCE METHODS
    
    //one row per coreLift
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CoreLift.caseCount
    }
    
    //configure cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //get cell and lift
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "max") as? OneRepMaxTableViewCell, let lift = CoreLift(rawValue: indexPath.row) else {
            return UITableViewCell()
        }
        
        //set title for lift and return
        cell.textLabel?.text = lift.description
        return cell
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
