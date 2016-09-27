//
//  SettingsViewController.swift
//  WaveTrainer
//
//  Created by Brian Josel on 9/26/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import UIKit

//views settings for the app
class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UINavigationControllerDelegate {
    
    //outlets
    @IBOutlet weak var settingsTableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var buttonLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var setBarWeightButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        //hide textField and button by default
        self.textField.isHidden = true
        self.setBarWeightButton.isHidden = true
        
        //set clear button for textField
        self.textField.clearButtonMode = .whileEditing
        
        //setup button
        self.setBarWeightButton.setTitle("Cancel", for: UIControlState()) //weight text completes as typed
        self.setBarWeightButton.addTarget(self, action: #selector(self.setBarWeightButtonPressed(_:)), for: .touchUpInside)
        
        //set delegates
        self.settingsTableView.delegate = self
        self.settingsTableView.dataSource = self
        self.textField.delegate = self
        self.navigationController?.delegate = self
        
        //set height of tableView based on content
        self.settingsTableView.addObserver(self, forKeyPath: "contentSize", options: .initial, context: nil)
        self.settingsTableView.frame.size = self.settingsTableView.contentSize
        
        //numberPad keyBoard
        self.textField.keyboardType = .decimalPad
        
        //remove whitespace
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    //sets weight of bar in WorkoutManager singleton
    func setBarWeightButtonPressed(_ sender: UIButton) {
        //if button text is cancel, resign first responder and ignore
        if sender.titleLabel?.text == "Cancel" {
            self.textField.resignFirstResponder()
        } else {
            
            //ensure text in textField
            guard let weightString = self.textField.text else {
                //no text in field, should never get to this point
                print("error, no text in textField")
                self.textField.resignFirstResponder()
                return
            }
            
            //create int from weightText and set in client singleton
            let weightDouble = Double(weightString)!
            WorkoutManagerClient.sharedInstance.barWeight = weightDouble
            self.textField.resignFirstResponder()
        }
    }
    
    //perform the following before view appears
    override func viewWillAppear(_ animated: Bool) {
        
        //subscribe to keyboard notifications to allow for view resizing
        self.subscribeToKeyboardNotifications()
    }
    
    //perform the following before the view disappears
    override func viewWillDisappear(_ animated: Bool) {
        
        //unsubscribe to keyboard notifications to prevent any race conditions
        self.unsubscribeFromKeyboardNotifications()
    }
    
    //perform the following based on keyPath
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        //check keypath
        if keyPath == "contentSize" {
            
            //adjust settings tableVoew height
            self.tableViewHeight.constant = self.settingsTableView.contentSize.height
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    //only a single section in table
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    //one row for each Settings case
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Settings.caseCount
    }
    
    //handle behavior of cell when its selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //get setting for particular row
        let setting = Settings(rawValue: indexPath.row)
        
        //show textField for Bar Weight cell only
        if setting == Settings.barWeight {
            self.textField.isHidden = false
            self.setBarWeightButton.isHidden = false
            self.textField.becomeFirstResponder()
        } else {
            self.textField.resignFirstResponder()
            self.textField.text = nil
            self.textField.isHidden = true
        }
    }

    //configure cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //create cell
        let reuseID = "SettingsCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseID, for: indexPath)

        //get setting for particular row
        let setting = Settings(rawValue: indexPath.row)
        
        //set cell and return
        cell.textLabel?.text = setting?.description
        cell.imageView?.image = setting?.image
        
        return cell
    }

    
    
    //----------delegate methods----------
    //beginning editing
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
//        //get string of barWeight
//        guard let barWeight = WorkoutManagerClient.sharedInstance.barWeight else {
//            //no barWeight, just return and carry on
//            return
//        }
//        
//        //create string from barWeight, set in textField
//        let barWeightString = String(barWeight)
//        textField.text = barWeightString
    }
    
    
    //text field editing is over
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        //check value of textField
        guard let text = textField.text, let weightDouble = Double(text) else {
            textField.resignFirstResponder()
            return
        }
        
        //set weight
        WorkoutManagerClient.sharedInstance.barWeight = weightDouble
        textField.resignFirstResponder()
    }
    
    
    //when clear button is hit, clear text or not
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        
        //set button text to cancel
        self.setBarWeightButton.setTitleWithOutAnimation(title: "Cancel")

        return true
    }
    
    //called whenever text is added to field
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        //limit the number of characters to two
        guard range.location <= 1 else {
            return false
        }
        
        //if textField.text is not nil, append replacement string to text
        guard let text = textField.text, text != "" else {
            
            //if string is "0", return false
            if string == "0" {
                return false
            }
            self.setBarWeightButton.setTitleWithOutAnimation(title: "Set Bar Weight to " + string + " lbs")
            return true
        }
        
        //if incoming string is a delete character, remove last char
        guard string != "" else {
            
            //pop last char off string, update button
            let updatedString = text.substring(to: text.index(before: text.endIndex))
            
            //check if updated string is empty
            if updatedString != "" {
                self.setBarWeightButton.setTitleWithOutAnimation(title: "Set Bar Weight to " + updatedString + " lbs")
            } else {
                self.setBarWeightButton.setTitleWithOutAnimation(title: "Cancel")
                self.textField.placeholder = "Enter a weight between 1-99 lbs"
            }
            return true
        }
        
        
        //create updated string from text and replacement string, update text of button
        let updatedString = text + string
        self.setBarWeightButton.setTitleWithOutAnimation(title: "Set Bar Weight to " + updatedString + " lbs")
        return true
    }
    
    //-----Following methods all related to resizing view when keyboard appears/dissappers-------------------------
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
    @objc func keyboardWillShow(_ notification: Notification) {
        
        //only adjust if keyboard is not showing, else do nothing
        //self.view.frame.origin.y -= self.getKeyboardHeight(notification)
        
        //show button and textField, adjust layout of button
        self.setBarWeightButton.isHidden = false
        self.textField.isHidden = false
        self.buttonLayoutConstraint.constant = self.getKeyboardHeight(notification)
        
        //stop listening to keyboardWillShow so that view is not altered everytime a textfield is selected
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    //carry out following when keyboard is about to hide
    func keyboardWillHide(_ notification: Notification) {
        
        //add height of keyboard back to bottom layout origin, if all UI elements oriented/constrained about bottom layout, layout should shift downward when keyboard hides
        //self.view.frame.origin.y = 0
        
        //hide button and textField
        self.setBarWeightButton.isHidden = true
        self.textField.isHidden = true
        
    }
    
    //gets size of keyboard to be used in resizing the view
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    //------------------------------End of view resizing methods-------------------------------------------------
    
}
