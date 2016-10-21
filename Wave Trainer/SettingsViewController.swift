    //
//  SettingsViewController.swift
//  WaveTrainer
//
//  Created by Brian Josel on 9/26/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import UIKit

//views settings for the app
class SettingsViewController: UITableViewController, UITextFieldDelegate, UINavigationControllerDelegate, SettingsTableViewHeaderDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        //set delegates
        self.navigationController?.delegate = self
        
        //disallow scrolling
        self.tableView.isScrollEnabled = false
        
        //remove whitespace
        self.automaticallyAdjustsScrollViewInsets = true
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
    
    //perform after view disappears
    override func viewDidDisappear(_ animated: Bool) {
        
        //collapse all views
        self.collapseAllHeaders()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //collapses all headers
    func collapseAllHeaders() {
        
        //iterate through each section
        for i in 0 ..< self.tableView.numberOfSections {
            
            //get header at section
            let header = self.tableView.headerView(forSection: i) as! SettingsTableViewHeader
            
            //collapse if expanded
            if !header.isCollapsed {
                self.toggleSection(header: header)
            }
        }
    }
    
    //updates the selected plates array
    func updatedPlatesSelected() {
        
        //if this function is called, then section 1 (plates) is opened, get cells from that section
        let cells = tableView?.visibleCells as! [SettingItemCell]
        
        //array output
        var platesArray = [Double]()
        
        //iterate through cells, if checkBox visible, then add to array
        for cell in cells {
            
            //check for box
            if cell.accessoryType == .checkmark {
                
                //create double from textLabel
                guard let plateText = cell.textLabel?.text, let plate = Double(plateText) else {
                    return
                }
                platesArray.append(plate)
            }
        }
        
        //set platesSelected to array
        WorkoutManagerClient.sharedInstance.platesSelected = platesArray
    }

    // MARK: - Table view data source
    
    //one section in table per setting
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Setting.caseCount
    }

    //one row for each Settings case
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

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
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        //get setting at section
        guard let setting = Setting(rawValue: section) else {
            //if setting not found, return empty UIView, should never get to this point
            //TODO: ERROR HANDLING
            return UIView()
        }
        
        //get cell, set section
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? SettingsTableViewHeader ?? SettingsTableViewHeader(reuseIdentifier: "header")
        header.section = section
        
        //set delegate
        header.delegate = self
        
        //configure header,  label and return
        header.textLabel?.text = setting.description
        header.contentView.backgroundColor = UIColor.white
        return header
    }
    
    //height for header
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    //height for footer
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    //configure cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        //get header
        guard let header = tableView.headerView(forSection: indexPath.section) as? SettingsTableViewHeader else {
            return 0
        }
        
        //return 0 height if collapsed, 44.0 height if not collapsed
        return header.isCollapsed ? 0 : 44.0
    }
    
    //handle behavior of cell when its selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //TODO:  WHY DOES FIRST TAP ALWAYS FAIL???
        //get setting for section
        let setting = Setting(rawValue: indexPath.section)!
        
        //get cell that is selected
        let cell = tableView.cellForRow(at: indexPath) as! SettingItemCell
        
        //selection of cells differ with setting behavior
        switch setting {
        case .plates:
            //toggle checkbox appearence
                DispatchQueue.main.async {
                    cell.accessoryType = cell.accessoryType == .none ? .checkmark : .none
                }
        default:
            //remaining sections do nothing when selected
            break
            //TODO: WHY IS CHECKMARK ARTIFACT ALWAYS VISIBLE?
        }
    }
    
    //perform action depending header
    func didTapHeader(header: SettingsTableViewHeader) {
        
        //get setting
        guard let setting = Setting(rawValue: header.section) else {
            //should never get to this point
            //TODO: ERROR???
            return
        }
        
        //perform function depending on which section was tapped
        switch setting {
        case .oneRMTest:
            
            //collapse all headers
            self.collapseAllHeaders()
            
            //create new VC
            guard let oneRMVC = self.storyboard?.instantiateViewController(withIdentifier: "OneRMTestViewController") as? OneRMTestViewController else {
                //if fail, just return
                //TODO: ERROR?
                return
            }
            
            //push VC
            self.navigationController?.pushViewController(oneRMVC, animated: true)
            
        case .routine:
            
            //collapse all headers
            self.collapseAllHeaders()
            
            //present workoutCFGVC
            let workCFGvc = self.storyboard?.instantiateViewController(withIdentifier: "WorkoutConfigViewController") as! WorkoutConfigViewController
            self.navigationController?.pushViewController(workCFGvc, animated: true)
            
        default:
            //section is plates or barweight, toggle
            self.toggleSection(header: header)
        }
    }
    
    //collapsing cells delegate
    func toggleSection(header: SettingsTableViewHeader) {
        
        //get setting at section
        guard let setting = Setting(rawValue: header.section), let values = setting.valueString else {
            return
        }
        
        //toggle collapse
        header.isCollapsed = !header.isCollapsed
        
        //adjust rows height
        self.tableView.beginUpdates()
        for i in 0 ..< values.count {
            //create indexPath, update tableView
            let indexPath = IndexPath(row: i, section: header.section)
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        self.tableView.endUpdates()

    }
    
    //manage headers when they collapse
    func didCollapseHeader(header: SettingsTableViewHeader) {
        
        //get header section, get setting based on section
        guard let section = header.section, let setting = Setting(rawValue: section) else {
            return
        }
        
        //different action depending on section
        switch setting {
        case .barWeight:
            //get open cell
            let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: section)) as! SettingItemCell

            //resign first responder, sets weight in textField delegate methods
            if cell.textField.isEditing {
                _ = cell.textField.resignFirstResponder()   //WHY IS THIS REQUIRED FOR OTHER HEADERS BUT NOT BARWEIGHT HEADER?
            }
        case .plates:
            //update plates
            self.updatedPlatesSelected()
        default:
            break
        }
    }
    
    //configure individual cell
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
            cell.selectionStyle = .none
            cell.textField.sizeToFit()
            cell.textField.isHidden = false
            cell.textField.keyboardType = .decimalPad
            cell.textField.delegate = self
            cell.textLabel?.isHidden = true
            cell.contentView.bringSubview(toFront: cell.textField)
            
            //no checkmark accessory view
            cell.accessoryType = .none
            
            //set value if it exists
            guard let values = setting.valueString else {
                
                //no value, return
                return
            }
            
            //set text label
            cell.textLabel?.text = values[indexPath.row]
            
        case .plates:
            
            //cell not selectable
            cell.selectionStyle = .none
            
            //hide textField, show label
            cell.textField.isHidden = true
            cell.textLabel?.isHidden = false
            
            //set value if it exists
            guard let values = setting.valueString else {
                
                //no value, return
                return
            }
            
            //get desired plate for row
            let plateString = values[indexPath.row]
            
            //set text label
            cell.textLabel?.text = plateString
            
            //create double from string
            guard let plate = Double(plateString) else{
                return
            }
            
            //if plate is in stored plate array, create checkbox, else do not include checkbox
            if WorkoutManagerClient.sharedInstance.platesSelected.index(of: plate) != nil {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            
        default:
            //TODO: RESOLVE
            cell.textField.isHidden = true
            return
        }
        
        //layout cell
        cell.layoutSubviews()
    }
    
    // MARK: - textField Delegate Methods
    
    //called to determine if editing should end or not
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        //set barWeight to textField string
        guard let text = textField.text, text != "", let barWeight = Double(text), barWeight > 0 else {
            return true
        }
        
        //set barWeight, clear text
        WorkoutManagerClient.sharedInstance.barWeight = barWeight
        return true
    }
    
    //called whenever text is added to field
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        //the limit is 1-99 with a one significant figure
        //user cannot begin with a 0, nor a decimal point
        //determine when a decimal point is added, then allow only a single non-decimal, character, and disallow the rest
        //also, do not allow any digits to be entered if two are already entered
        
        
        //limit the number of characters to four (1-99, a decimal, and one significant figure)
        if range.location > 3 {
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
        
        //decimal only allowed if one doesn't exist, if one does, then only one digit allowed
        if text.range(of: ".") != nil {
            if string == "." {
                return false
            }
            //decimal exists, and user attempting to input digit, only allow single digit
            //if decimal is not last character, then disallow
            if text.characters.last == "." {
                //allow entry
                return true
            }
            //decimal exists, not last char, disallow unless deletion
            return string == ""
        }
        
        //at this point, text exists and text can be added within range
        //if only one character, allow anything
        if text.characters.count == 1 {
            return true
        }
        
        //two characters input, only allow decimal or deletion
        return string == "." || string == ""
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
