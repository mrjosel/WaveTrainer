//
//  Wave.swift
//  Wave Trainer
//
//  Created by Brian Josel on 9/6/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import Foundation
import CoreData

@objc(Wave)

//class for wave
class Wave : NSManagedObject {
    
    //managed vars
    @NSManaged fileprivate var endDatePersisted: Date?
    @NSManaged fileprivate var completedPersisted : NSNumber
    @NSManaged var startDatePersisted : Date
    @NSManaged var name : String?   //TODO: DEVELOP METHOD OF INDEXING UNNAMED WAVES
    @NSManaged var cycles: [Cycle]
    
    //initializers
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init?(startDate: Date, endDate: Date?, completed: Bool, context: NSManagedObjectContext) {
        
        
        //if completed is set without an endDate or vice versa, initializer should fail and return nil
        if completed {
            guard endDate != nil else {
                return nil
            }
        } else {
            guard endDate == nil else {
                return nil
            }
        }
        
        //if endDate set, should be after than startDate
        if let endDate = endDate {
            if startDate == endDate {
                return nil
            }
            if (endDate as NSDate).timeIntervalSince(startDate).sign == .minus {
                return nil
            }
        }
        
        //completed and start/enddates compliant, attempt creation of managed object
        guard let entity = NSEntityDescription.entity(forEntityName: "Wave", in: context) else {
            return nil
        }
        super.init(entity: entity, insertInto: context)
        
        //create object, setting intermediate vars will set managed vars
        self.startDatePersisted = startDate //no need for intermediate var
        self.endDate = endDate
        self.completed = completed
        
    }
    
    //intermediate variables, allows for computing/obersving other variables in Core Data
    //intermediate var for end date of wave
    var endDate : Date? {
        get {
            guard let date = self.endDatePersisted else {
                return nil
            }
            return date
        }
        set {
            self.endDatePersisted = newValue
        }
    }

    
    //intermediate var for completion of wave
    var completed : Bool {
        get {
            return self.completedPersisted == 1 ? true : false
        }
        set {
            self.completedPersisted = newValue ? 1 : 0
            self.endDate = newValue ? Date() : nil //when wave is complete, set endDate, if not complete remove endDate
        }
    }

}
