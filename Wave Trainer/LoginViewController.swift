//
//  LoginViewController.swift
//  Wave Trainer
//
//  Created by Brian Josel on 8/4/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import UIKit
//TODO: IMPLEMENT #IFDEF TO REMOVE INITIALVC AT BUILD
class LoginViewController: UIViewController, UITextFieldDelegate {
    
    //outlets
    @IBOutlet weak var barbellImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //set image and constraints
        self.barbellImageView.image = UIImage(named: "barbellImage")    //TODO: SHARPEN IMAGE
        self.titleLabel.text = "Wave Trainer"   //TODO: make stylized version
        self.titleLabel.textColor = UIColor.white
        self.view.backgroundColor = UIColor.black
        self.userNameTextField.placeholder = "Username"
        self.passwordTextField.placeholder = "Password"
        //TODO:  JAZZ UP BUTTONS
        self.signUpButton.setTitle("Sign Up", for: UIControlState())
        self.signUpButton.backgroundColor = UIColor.white
        self.signUpButton.setTitleColor(UIColor.black, for: UIControlState())
        self.signUpButton.addTarget(self, action: #selector(self.signUpButtonPressed(_:)), for: .touchUpInside)
        self.loginButton.addTarget(self, action: #selector(self.loginButtonPressed(_:)), for: .touchUpInside)
        self.loginButton.setTitle("Login", for: UIControlState())
        self.loginButton.backgroundColor = UIColor.white
        self.loginButton.setTitleColor(UIColor.black, for: UIControlState())
        
        //textField behavior
        self.userNameTextField.clearsOnBeginEditing = true
        self.userNameTextField.clearButtonMode = .whileEditing
        self.passwordTextField.clearsOnBeginEditing = true
        self.passwordTextField.clearButtonMode = .whileEditing
        self.passwordTextField.isSecureTextEntry = true
        
        //set delegates
        self.userNameTextField.delegate = self
        self.passwordTextField.delegate = self

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
    //TODO:  INVESTIGATE HOW TO LOGIN AND HOW TO SIGNUP USING CLIENT
    //login button pressed
    func loginButtonPressed(_ sender: UIButton) {
        
        //get username and password text, pass into Workout Manager client
        guard let username = self.userNameTextField.text, let password = self.passwordTextField.text else {
            //one or more fields empty, do nothing
            return
        }
        //ensure strings are not empty, if either is empty, do nothing
        if username != "" && password != "" {
            //pass fields into client
            WorkoutManagerClinet.sharedInstance.login(username, password: password)
        }
    }
    
    //login button pressed
    func signUpButtonPressed(_ sender: UIButton) {
        
        //transition to signupVC
        //TODO: MODAL TRANSITION TO NEW VC
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //----------delegate methods----------
    //when return key is hit
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //hide keyboard when enter key is hit
        textField.resignFirstResponder()
        
        //resume listening for keyboardWillShow
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
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
    func keyboardWillShow(_ notification: Notification) {
        
        //only adjust if keyboard is not showing, else do nothing
        self.view.frame.origin.y -= self.getKeyboardHeight(notification)
        
        //stop listening to keyboardWillShow so that view is not altered everytime a textfield is selected
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    //carry out following when keyboard is about to hide
    func keyboardWillHide(_ notification: Notification) {
        
        //add height of keyboard back to bottom layout origin, if all UI elements oriented/constrained about bottom layout, layout should shift downward when keyboard hides
        self.view.frame.origin.y = 0
        
    }
    
    //gets size of keyboard to be used in resizing the view
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    //------------------------------End of view resizing methods-------------------------------------------------
    
}

