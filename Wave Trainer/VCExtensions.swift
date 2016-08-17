//
//  VCExtensions.swift
//  Wave Trainer
//
//  Created by Brian Josel on 8/10/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController: UITextFieldDelegate {
    //TODO:  FIX BUG WHERE VIEW SHRINKS EVEN IF KEYBOARD IS SHOWING
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        //hide keyboard when enter key is hit
        textField.resignFirstResponder()
        return true
    }
    
    //-----Following methods all related to resizing view when keyboard appears/dissappers-------------------------
    //subscribes to notifications from keyboard, usually called in a VCs viewWillAppear method
    func subscribeToKeyboardNotifications() {
        //adds notifications to notification center
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UIViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UIViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    //unsubscribes to notifications from keyboard, usually called in a VCs viewWillDisappear method
    func unsubscribeFromKeyboardNotifications() {
        //removes keyboard notifications from notification center
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    //carry out following when keyboard is about to show
    func keyboardWillShow(notification: NSNotification) {
        
        //subtract height of keyboard from bottom layout origin, if all UI elements oriented/constrained about bottom layout, layout should shift upward when keyboard shows
        self.view.frame.origin.y -= self.getKeyboardHeight(notification)
    }
    
    //carry out following when keyboard is about to hide
    func keyboardWillHide(notification: NSNotification) {
        //add height of keyboard back to bottom layout origin, if all UI elements oriented/constrained about bottom layout, layout should shift downward when keyboard hides
        self.view.frame.origin.y += self.getKeyboardHeight(notification)
    }
    
    //gets size of keyboard to be used in resizing the view
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    //------------------------------End of view resizing methods--------------------------------------------------
}