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
        //TODO:  NEED TO RESIGN FIRST RESPONDER
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
        
        //only adjust if keyboard is not showing, else do nothing
        self.buttonsViewBottomLayoutGuide.constant = self.getKeyboardHeight(notification)
        
        //stop listening to keyboardWillShow so that view is not altered everytime a textfield is selected
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    //carry out following when keyboard is about to hide
    func keyboardWillHide(_ notification: Notification) {
        
        //add height of keyboard back to bottom layout origin, if all UI elements oriented/constrained about bottom layout, layout should shift downward when keyboard hides
        self.buttonsViewBottomLayoutGuide.constant = 0
        
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