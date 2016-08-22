//
//  LoginViewController.swift
//  Wave Trainer
//
//  Created by Brian Josel on 8/4/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import UIKit

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
        
        //TODO: FIX ICON COLOR (IS BLACK)
        
        //set image and constraints
        self.barbellImageView.image = UIImage(named: "barbellImage")    //TODO: SHARPEN IMAGE
        self.titleLabel.text = "Wave Trainer"   //TODO: make stylized version
        self.titleLabel.textColor = UIColor.whiteColor()
        self.view.backgroundColor = UIColor.blackColor()
        self.userNameTextField.placeholder = "Username"
        self.passwordTextField.placeholder = "Password"
        //TODO:  JAZZ UP BUTTONS
        self.signUpButton.setTitle("Sign Up", forState: UIControlState.Normal)
        self.signUpButton.backgroundColor = UIColor.whiteColor()
        self.signUpButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        self.signUpButton.addTarget(self, action: #selector(self.signUpButtonPressed(_:)), forControlEvents: .TouchUpInside)
        self.loginButton.addTarget(self, action: #selector(self.loginButtonPressed(_:)), forControlEvents: .TouchUpInside)
        self.loginButton.setTitle("Login", forState: UIControlState.Normal)
        self.loginButton.backgroundColor = UIColor.whiteColor()
        self.loginButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        
        //set delegates
        self.userNameTextField.delegate = self
        self.passwordTextField.delegate = self
        
    }
    
    //perform the following before view appears
    override func viewWillAppear(animated: Bool) {
        
        //subscribe to keyboard notifications to allow for view resizing
        self.subscribeToKeyboardNotifications()
    }
    
    //perform the following before the view disappears
    override func viewWillDisappear(animated: Bool) {
        
        //unsubscribe to keyboard notifications to prevent any race conditions
        self.unsubscribeFromKeyboardNotifications()
    }
    
    //login button pressed
    func loginButtonPressed(sender: UIButton) {
        
        //get username and password text, pass into Workout Manager client
        guard let username = self.userNameTextField.text, password = self.passwordTextField.text else {
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
    func signUpButtonPressed(sender: UIButton) {
        
        //get username and password text, pass into Workout Manager client
        guard let username = self.userNameTextField.text, password = self.passwordTextField.text else {
            //one or more fields empty, do nothing
            return
        }
        //ensure strings are not empty, if either is empty, do nothing
        if username != "" && password != "" {
            //pass fields into client
            WorkoutManagerClinet.sharedInstance.signUp(username, password: password)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //----------delegate methods----------
    //when return key is hit
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //hide keyboard when enter key is hit
        textField.resignFirstResponder()
        
        //resume listening for keyboardWillShow
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        return true
    }
    
    //-----Following methods all related to resizing view when keyboard appears/dissappers-------------------------
    //subscribes to notifications from keyboard, usually called in a VCs viewWillAppear method
    func subscribeToKeyboardNotifications() {
        //adds notifications to notification center
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    //unsubscribes to notifications from keyboard, usually called in a VCs viewWillDisappear method
    func unsubscribeFromKeyboardNotifications() {
        //removes keyboard notifications from notification center
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    //carry out following when keyboard is about to show
    func keyboardWillShow(notification: NSNotification) {
        
        //only adjust if keyboard is not showing, else do nothing
        self.view.frame.origin.y -= self.getKeyboardHeight(notification)
        
        //stop listening to keyboardWillShow so that view is not altered everytime a textfield is selected
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    //carry out following when keyboard is about to hide
    func keyboardWillHide(notification: NSNotification) {
        
        //add height of keyboard back to bottom layout origin, if all UI elements oriented/constrained about bottom layout, layout should shift downward when keyboard hides
        self.view.frame.origin.y = 0
        
    }
    
    //gets size of keyboard to be used in resizing the view
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    //------------------------------End of view resizing methods-------------------------------------------------
    
}

