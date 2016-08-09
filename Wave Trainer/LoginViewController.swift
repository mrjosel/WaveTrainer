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
    @IBOutlet weak var barbellImageViewHeightConstraint: NSLayoutConstraint! //TODO: USE FOR AUTO-SIZING
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //TODO: FIX ICON COLOR (IS BLACK)
        
        //set image and constraints
        self.barbellImageView.image = UIImage(named: "barbellImage")    //TODO: SHARPEN IMAGE
        self.titleLabel.text = "Wave Trainer"   //TODO: make stylized version
        self.titleLabel.textColor = UIColor.whiteColor()
        self.view.backgroundColor = UIColor.blackColor()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

