//
//  OneRMTestViewController.swift
//  WaveTrainer
//
//  Created by Brian Josel on 10/10/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import UIKit

//allows for editing and viewing of 1 Rep Max numbers
class OneRMTestViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    //outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonsViewBottomLayoutGuide: NSLayoutConstraint!
    
    override func viewDidAppear(_ animated: Bool) {
        //set heightof tableView
        self.tableView.frame = CGRect(x: self.tableView.frame.origin.x, y: self.tableView.frame.origin.y, width: self.tableView.frame.size.width, height: self.tableView.contentSize.height)
        //TODO: FIX THIS
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set delegate and dataSource
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        //disallow scrolling
        self.tableView.isScrollEnabled = false
        
        //remove whitespace
        self.automaticallyAdjustsScrollViewInsets = false
        
        //set buttons
        self.applyButton.addTarget(self, action: #selector(self.applyButtonPressed(_:)), for: .touchUpInside)
        self.applyButton.setTitle("Apply", for: .normal)
        self.applyButton.isEnabled = false
        self.cancelButton.addTarget(self, action: #selector(self.cancelButtonPressed(_:)), for: .touchUpInside)
        self.cancelButton.setTitle("Cancel", for: .normal)
        self.cancelButton.isEnabled = true
    }
    
    //called when applyButton is pressed
    func applyButtonPressed(_ sender: UIButton) {
        print("applyButtonPressed")
    }
    
    //called when applyButton is pressed
    func cancelButtonPressed(_ sender: UIButton) {
        print("cancelButtonPressed")
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: DATA SOURCE METHODS
    
    //one row per coreLift
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CoreLift.caseCount
    }
    
    //configure cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //get cell and lift
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "max") as? OneRepMaxTableViewCell, let lift = CoreLift(rawValue: indexPath.row) else {
            return UITableViewCell()
        }
        
        //set title for lift
        cell.textLabel?.text = lift.description
        
        //set textField properties
        cell.selectionStyle = .none
        cell.textField.sizeToFit()
        cell.textField.borderStyle = .none
        cell.textField.isHidden = false
        cell.textField.keyboardType = .numberPad
        cell.textField.delegate = self
        cell.textField.placeholder = WorkoutManagerClient.oneRepMaxPlaceHolder
        return cell
    }
    
    //when cell is tapped anywhere, textField becomes first responder
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //get cell, set textField as first responder
        let cell = tableView.cellForRow(at: indexPath) as! OneRepMaxTableViewCell
        cell.textField.becomeFirstResponder()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
