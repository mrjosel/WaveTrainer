    //
//  SettingsViewController.swift
//  WaveTrainer
//
//  Created by Brian Josel on 9/26/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import UIKit

//views settings for the app
class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UINavigationControllerDelegate, CollapsibleTableViewHeaderDelegate {
    
    //outlets
    @IBOutlet weak var settingsTableView: UITableView!
    
    //keeper variable for which collapsible header is currently expanded
    var expandedHeader : CollapsibleTableViewHeader?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        //hide textField and button by default
//        self.textField.isHidden = true
//        self.setBarWeightButton.isHidden = true
//        
//        //set clear button for textField
//        self.textField.clearButtonMode = .whileEditing
//        
//        //placeholderfor textField
//        self.textField.placeholder = "Enter a weight between 1-99.9 lbs"
//        
//        //setup button
//        self.setBarWeightButton.setTitle("Cancel", for: UIControlState()) //weight text completes as typed
//        self.setBarWeightButton.addTarget(self, action: #selector(self.setBarWeightButtonPressed(_:)), for: .touchUpInside)
//        
        //set delegates
        self.settingsTableView.delegate = self
        self.settingsTableView.dataSource = self
        self.navigationController?.delegate = self
        
        //set height of tableView based on content, disallow scrolling
//        self.settingsTableView.addObserver(self, forKeyPath: "contentSize", options: .initial, context: nil)
//        self.settingsTableView.frame.size = self.settingsTableView.contentSize
        self.settingsTableView.isScrollEnabled = false
        
        //numberPad keyBoard
//        self.textField.keyboardType = .decimalPad
        
        //remove whitespace
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
//    //sets weight of bar in WorkoutManager singleton
//    func setBarWeightButtonPressed(_ sender: UIButton) {
//        //if button text is cancel, resign first responder and ignore
//        if sender.titleLabel?.text == "Cancel" {
//            self.textField.resignFirstResponder()
//        } else {
//            
//            //ensure text in textField
//            guard let weightString = self.textField.text else {
//                //no text in field, should never get to this point
//                print("error, no text in textField")
//                self.textField.resignFirstResponder()
//                return
//            }
//            
//            //create double from weightText and set in client singleton
//            let weightDouble = Double(weightString)!
//            WorkoutManagerClient.sharedInstance.barWeight = weightDouble
//            self.textField.resignFirstResponder()
//            self.settingsTableView.reloadData()
//        }
//    }
    
    //perform the following before view appears
    override func viewWillAppear(_ animated: Bool) {
        
        //subscribe to keyboard notifications to allow for view resizing
//        self.subscribeToKeyboardNotifications()
    }
    
    //perform the following before the view disappears
    override func viewWillDisappear(_ animated: Bool) {
        
        //unsubscribe to keyboard notifications to prevent any race conditions
//        self.unsubscribeFromKeyboardNotifications()
    }
    
//    //perform the following based on keyPath
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        
//        //check keypath
//        if keyPath == "contentSize" {
//            
//            //adjust settings tableVoew height
//            self.tableViewHeight.constant = self.settingsTableView.contentSize.height
//        }
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    //one section in table per setting
    func numberOfSections(in tableView: UITableView) -> Int {
        return Setting.caseCount
    }

    //one row for each Settings case
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        //get setting at section
        guard let setting = Setting(rawValue: section) else {
            return 0
        }

        //get valueString count for setting
        guard let value = setting.valueString else {
            //valueCount is nil, return 0
            return 0
        }
        return value.count

    }
    
    //customize header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        //get setting at section
        guard let setting = Setting(rawValue: section) else {
            //if setting not found, return empty UIView, should never get to this point
            //TODO: ERROR HANDLING
            return UIView()
        }
        
        //get cell, set section
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? CollapsibleTableViewHeader ?? CollapsibleTableViewHeader(reuseIdentifier: "header")
        header.section = section
        
        //set delegate
        header.delegate = self
        
        //configure header,  label and return
        header.textLabel?.text = setting.description
        header.contentView.backgroundColor = UIColor.white
        return header
    }
    
    //height for header
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    //height for footer
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    //configure cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //create cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "item") as? SettingItemCell else {
            return UITableViewCell()
        }
        
        //get setting for particular row
        guard let setting = Setting(rawValue: indexPath.section) else {
            //if setting not found, return cell, should never get to this point
            //TODO: ERROR HANDLING
            return cell
        }
        
        //configure cell and return
        self.configureSettingItemCell(cell, withSetting: setting, atIndexPath: indexPath)
        return cell
    }
    
    //cponfigure height of cells
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        //get header
        guard let header = tableView.headerView(forSection: indexPath.section) as? CollapsibleTableViewHeader else {
            return 0
        }
        
        //return 0 height if collapsed, 44.0 height if not collapsed
        return header.isCollapsed ? 0 : 44.0
    }
    
    //handle behavior of cell when its selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    }
    
    //collapsing cells delegate
    func toggleSection(header: CollapsibleTableViewHeader) {
        //TODO:  FIX TOGGLING SECTION TO END EDITING OF TEXTFIELD
        //TOOD:  FIX TOGGLING BUG WHERE SOMETIMES IT TOGGLES, OTHER TIMES NOT
        //get setting at section
        guard let setting = Setting(rawValue: header.section) else {
            return
        }
        
        //collapse open header, if header is open
        if let expandedHeader = self.expandedHeader {
            
            //if expandedHeader is barWeight, call delegate method to end textField editing
            if expandedHeader.section == Setting.barWeight.rawValue {
                
                //get open cell, call method
                let cell = self.settingsTableView.cellForRow(at: IndexPath(row: 0, section: expandedHeader.section)) as! SettingItemCell
                cell.textField.delegate?.textFieldDidEndEditing!(cell.textField)
            }
            
            //collapse header and clear var
            expandedHeader.isCollapsed = true
        }
        
        //get values of setting
        guard let values = setting.valueString else {
            return
        }
        
        //toggle collapse
        header.isCollapsed = !header.isCollapsed
        
        //adjust rows height
        self.settingsTableView.beginUpdates()
        for i in 0 ..< values.count {
            //create indexPath, update tableView
            let indexPath = IndexPath(row: i, section: header.section)
            self.settingsTableView.reloadRows(at: [indexPath], with: .automatic)
        }
        self.settingsTableView.endUpdates()
        
        //if expandedHeader is the header itself, then clear variable, otherwise set it
        self.expandedHeader = self.expandedHeader == header ? nil : header
    }
    
    func configureSettingItemCell(_ cell: SettingItemCell, withSetting setting : Setting, atIndexPath indexPath: IndexPath) {
        
        //set cell image
        cell.imageView?.image = setting.image
        
        //configure textField based on setting
        switch setting {
        case .barWeight:
            //configure textField
            cell.textField.placeholder = WorkoutManagerClient.barWeightPlaceHolder
            if let barWeight = WorkoutManagerClient.sharedInstance.barWeight {
                let string = String(barWeight)
                cell.textField.text = string
            }
            cell.textField.sizeToFit()
            cell.textField.isHidden = false
            cell.textField.keyboardType = .decimalPad
            cell.textField.delegate = self
            cell.textLabel?.isHidden = true
            cell.contentView.bringSubview(toFront: cell.textField)
        case .plates:
            cell.textField.isHidden = true
            cell.textLabel?.isHidden = false
        default:
            //TODO: RESOLVE
            cell.textField.isHidden = true
            return
        }
        
        //set value if it exists
        guard let values = setting.valueString else {
            
            //no value, return
            return
        }
        
        //set text label
        cell.textLabel?.text = values[indexPath.row]
        
        //layout cell
        cell.layoutSubviews()
    }

    
    
    // MARK: - textField Delegate Methods
    
    //ending editing
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        //set barWeight to textField string
        guard let text = textField.text, text != "" else {
            
            //clear text
            textField.text = nil
            return
        }
        
        //create barWeight from text
        guard let barWeight = Double(text), barWeight > 0 else {
            //clear text
            textField.text = nil
            return
        }
        
        //set barWeight, clear text
        WorkoutManagerClient.sharedInstance.barWeight = barWeight
        textField.text = nil
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
            return true
        }
        
        //if incoming string is a delete character, remove last char
        guard string != "" else {
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
                return true
            }
            //decimal exists, not last char, disallow
            return false
        }
        
        //at this point, text exists and text can be added within range
        //if only one character, allow anything
        if text.characters.count == 1 {
            return true
        }
        
        //two characters input, only allow decimal
        return string == "."
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
        
        //stop listening to keyboardWillShow so that view is not altered everytime a textfield is selected
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    //carry out following when keyboard is about to hide
    func keyboardWillHide(_ notification: Notification) {
        
        //start listening to willShow notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
    }
    
    //gets size of keyboard to be used in resizing the view
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    // MARK: - End of Keyboard resizing methods
    
}
