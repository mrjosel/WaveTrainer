//
//  ExtensionUIButton.swift
//  WaveTrainer
//
//  Created by Brian Josel on 9/27/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import Foundation
import UIKit

//allows for updating buttons without animation
extension UIButton {
    func setTitleWithOutAnimation(title: String?) {
        UIView.setAnimationsEnabled(false)
        
        setTitle(title, for: .normal)
        
        layoutIfNeeded()
        UIView.setAnimationsEnabled(true)
    }
}
