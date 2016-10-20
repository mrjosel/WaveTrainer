//
//  OneRMTestViewController.swift
//  WaveTrainer
//
//  Created by Brian Josel on 10/10/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import UIKit

//allows for editing and viewing of 1 Rep Max numbers
class OneRMTestViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    override func viewWillAppear(_ animated: Bool) {
        
        //subscribe to keyboard notifications
        self.subscribeToKeyboardNotifications()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //unsubscrib from keyboard notifications
        //subscribe to keyboard notifications
        self.unsubscribeFromKeyboardNotifications()
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
        
        //set lift in cell (used in textField delegate)
        cell.coreLift = lift
        
        //set title for lift
        cell.textLabel?.text = lift.description
        
        //set textField's delegate as the cell
        cell.textField.delegate = cell
        
        //if weight exists for max, set it as text
        if let weight = WorkoutManagerClient.sharedInstance.oneRepMaxes[lift.description] {
            cell.textField.text = String(weight)
        }
        
        //set textField properties
        cell.selectionStyle = .none
        cell.textField.sizeToFit()
        cell.textField.borderStyle = .none
        cell.textField.isHidden = false
        cell.textField.keyboardType = .numberPad
        cell.textField.placeholder = WorkoutManagerClient.oneRepMaxPlaceHolder
        cell.textField.textAlignment = .right
        return cell
    }
    
    //when cell is tapped anywhere, textField becomes first responder
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //get cell, set textField as first responder
        let cell = tableView.cellForRow(at: indexPath) as! OneRepMaxTableViewCell
        cell.textField.becomeFirstResponder()
    }
    
    //used to limit tableViewHeight based on content, content does not change, so no method for updating required
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        //if last row, update tableViewHeightConstraint, else do nothing
        if indexPath.row == self.tableView.numberOfRows(inSection: indexPath.section) - 1 {
            self.tableViewHeightConstraint.constant = self.tableView.contentSize.height
        }
    }
    
    // MARK: KEYBOARD METHODS
    //subscribes to notifications from keyboard, usually called in a VCs viewWillAppear method
    func subscribeToKeyboardNotifications() {
        //adds notifications to notification center
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    //unsubscribes to notifications from keyboard, usually called in a VCs viewWillDisappear method
    func unsubscribeFromKeyboardNotifications() {
        //removes keyboard notifications from notification center
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    //carry out following when keyboard is about to show
    func keyboardWillShow(_ notification: Notification) {
        
        //stop listening to keyboardWillShow so that view is not altered everytime a textfield is selected
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    //carry out following when keyboard is about to hide
    func keyboardWillHide(_ notification: Notification) {
        
        //add height of keyboard back to bottom layout origin, if all UI elements oriented/constrained about bottom layout, layout should shift downward when keyboard hides
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
    }
    
    //gets size of keyboard to be used in resizing the view
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    // MARK: END OF KEYBOARD METHODS
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
