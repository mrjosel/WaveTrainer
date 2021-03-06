//
//  Setting.swift
//  WaveTrainer
//
//  Created by Brian Josel on 9/26/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import Foundation
import UIKit

//enum which provides a count of its cases
protocol CaseCountable {
    static func countCases() -> Int
    static var caseCount : Int { get }
}


//provide a default implementation to count the cases for Int enums assuming starting at 0 and contiguous
extension CaseCountable where Self : RawRepresentable, Self.RawValue == Int {
    // count the number of cases in the enum
    static func countCases() -> Int {
        // starting at zero, verify whether the enum can be instantiated from the Int and increment until it cannot
        var count = 0
        while let _ = Self(rawValue: count) {
            count += 1
        }
        return count
    }
}

//enum for settings in SettingsViewController
enum Setting : Int, CustomStringConvertible, CaseCountable {
    case barWeight = 0, plates, routines, oneRMTest
    
    //names for settings
    static let SettingNames = [
        barWeight : "Bar Weight",
        plates : "Plates",
        routines : "Routines",
        oneRMTest : "1RM Test"
    ]
    
    //images for settings
    static let SettingImages : [Setting: UIImage?] = [
        //TODO: CREATE IMAGES
        barWeight : nil,
        plates : nil,
        routines : nil,
        oneRMTest : nil
    ]
    
    //generic value, depending on setting returns different value type, only barWeight has value for now
    var valueString : [String]? {
        get {
            switch self {
            case .barWeight :
                guard let barWeight = WorkoutManagerClient.sharedInstance.barWeight else {
                    return [String()]
                }
                return [String(barWeight)]
            case .plates :
                return WorkoutManagerClient.PlatesAvailable.ALLPLATES
            case .routines :
                return nil
            case .oneRMTest :
                return nil
            }
        }
    }
    
    //count of number of settings
    static let caseCount: Int = Setting.countCases()
    
    //return image
    var image: UIImage? {
        get {
            return Setting.SettingImages[self]!
        }
    }
    
    //description var for CustomStringConvertible conformance
    var description: String {
        get {
            return Setting.SettingNames[self]!
        }
    }
}
