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
    @NSManaged var startDatePersisted : NSDate
    @NSManaged private var endDatePersisted: NSDate?
    @NSManaged private var completedPersisted : NSNumber
    //@NSManaged var cycles: [Cycle]    //TODO: IMPLEMENT CYCLES
    
    //initializers
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init?(startDate: NSDate, endDate: NSDate?, completed: Bool, context: NSManagedObjectContext) {
        
        
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
            if startDate.isEqualToDate(endDate) {
                return nil
            }
            if endDate.timeIntervalSinceDate(startDate).isSignMinus {
                return nil
            }
        }
        
        //completed and start/enddates compliant, attempt creation of managed object
        guard let entity = NSEntityDescription.entityForName("Wave", inManagedObjectContext: context) else {
            return nil
        }
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        //create object, setting intermediate vars will set managed vars
        self.startDatePersisted = startDate //no need for intermediate var
        self.endDate = endDate
        self.completed = completed
        
    }
    
    //intermediate variables, allows for computing/obersving other variables in Core Data
    //intermediate var for end date of wave
    var endDate : NSDate? {
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
            self.endDate = newValue ? NSDate() : nil //when wave is complete, set endDate, if not complete remove endDate
        }
    }

}