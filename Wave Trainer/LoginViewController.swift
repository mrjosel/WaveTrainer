//
//  LoginViewController.swift
//  Wave Trainer
//
//  Created by Brian Josel on 8/4/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

