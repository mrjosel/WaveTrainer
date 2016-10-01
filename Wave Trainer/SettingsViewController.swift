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
        
        //placeholderfor textField
        self.textField.placeholder = "Enter a weight between 1-99.9 lbs"
        
        //setup button
        self.setBarWeightButton.setTitle("Cancel", for: UIControlState()) //weight text completes as typed
        self.setBarWeightButton.addTarget(self, action: #selector(self.setBarWeightButtonPressed(_:)), for: .touchUpInside)
        
        //set delegates
        self.settingsTableView.delegate = self
        self.settingsTableView.dataSource = self
        self.textField.delegate = self
        self.navigationController?.delegate = self
        
        //set height of tableView based on content, disallow scrolling
        self.settingsTableView.addObserver(self, forKeyPath: "contentSize", options: .initial, context: nil)
        self.settingsTableView.frame.size = self.settingsTableView.contentSize
        self.settingsTableView.isScrollEnabled = false
        
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
            
            //create double from weightText and set in client singleton
            let weightDouble = Double(weightString)!
            WorkoutManagerClient.sharedInstance.barWeight = weightDouble
            self.textField.resignFirstResponder()
            self.settingsTableView.reloadData()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseID, for: indexPath) as! SettingsTableViewCell
        
        //get setting for particular row
        let setting = Settings(rawValue: indexPath.row)
        
        //set cell and return
        cell.textLabel?.text = setting?.description
        cell.imageView?.image = setting?.image
        
        //set value if it exists
        guard let value = setting?.valueString else {
            cell.valueLabel.isHidden = true
            return cell
        }
        
        //if cell is barWeight, add "lbs" to string
        cell.valueLabel.text = setting == .barWeight ? value + " lbs" : value
        
        //layout cell
        cell.valueLabel.sizeToFit()
        cell.valueLabel.isHidden = false
        cell.contentView.bringSubview(toFront: cell.valueLabel)
        cell.layoutSubviews()
        return cell
    }

    
    
    // MARK: - textField Delegate Methods
    //beginning editing
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        //set cancel button for barWeight cell
        self.setBarWeightButton.setTitleWithOutAnimation(title: "Cancel")
    }
    
    //ending editing
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        //clear text
        textField.text = nil
    }
    
    //when clear button is hit, clear text or not
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        
        //set button text to cancel
        self.setBarWeightButton.setTitleWithOutAnimation(title: "Cancel")

        return true
    }
    
    //called whenever text is added to field
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        //the limit is 1-99 with a one significant figure
        //user cannot begin with a 0, nor a decimal point
        //determine when a decimal point is added, then allow only a single non-decimal, character, and disallow the rest
        //also, do not allow any digits to be entered if two are already entered
        
        
        //limit the number of characters to four (1-99, a decimal, and one significant figure)
        guard range.location <= 3 else {
            return false
        }
        
        //if text is nil or an empty string, ensure user is not attempting to start with 0 or a decimal
        guard let text = textField.text, text != "" else {
            
            //if string is "0", return false
            if string == "0" || string == "."{
                return false
            }
            
            //create button text using only replacementString since no previous text exists
            self.setBarWeightButton.setTitleWithOutAnimation(title: "Set Bar Weight to " + string + " lbs")
            return true
        }
        
        //if incoming string is a delete character, remove last char
        guard string != "" else {
            
            //pop last char off string, update button
            var updatedString = text.substring(to: text.index(before: text.endIndex))
            
            //if last char is a decimal, pop it as well so button text does not end in a decimal
            updatedString = updatedString.characters.last == "." ? updatedString.substring(to: updatedString.index(before: updatedString.endIndex)) : updatedString
            
            //check if updated string is empty
            if updatedString != "" {
                self.setBarWeightButton.setTitleWithOutAnimation(title: "Set Bar Weight to " + updatedString + " lbs")
            } else {
                self.setBarWeightButton.setTitleWithOutAnimation(title: "Cancel")
                self.textField.placeholder = "Enter a weight between 1-99.9 lbs"
            }
            return true
        }
        
        //decimal only allowed if one doesn't exist, if one does, then only one digit allowed
        guard text.range(of: ".") == nil else {
            if string == "." {
                return false
            }
            //decimal exists, and user attempting to input digit, only allow single digit
            //if decimal is not last character, then disallow
            if text.characters.last == "." {
                //allow entry
                let updatedString = text + string
                self.setBarWeightButton.setTitleWithOutAnimation(title: "Set Bar Weight to " + updatedString + " lbs")
                return true
            }
            
            //decimal exists, not last char, disallow
            return false
        }
        
        //at this point, text exists and text can be added within range
        //create updatedString based on text and input string from user, use updatedString in button text
        //if last char is a decimal, pop it from updatedString when adding to button text
        let updatedString = string == "." ? text : text + string
        self.setBarWeightButton.setTitleWithOutAnimation(title: "Set Bar Weight to " + updatedString + " lbs")
        return true
    }
    
    // MARK: - Keyboard resizing methods
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
    // MARK: - End of Keyboard resizing methods
    
}
