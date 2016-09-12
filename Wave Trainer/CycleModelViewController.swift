//
//  CycleModelViewController.swift
//  WaveTrainer
//
//  Created by Brian Josel on 9/12/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import UIKit
import CoreData

class CycleModelViewController: UITableViewController,NSFetchedResultsControllerDelegate {
    
    //var for local reference to CoreData singleton
    var sharedContext = CoreDataStackManager.sharedInstance.managedObjectContext

    //wave, sent from previous controller
    var wave : Wave?
    
    //fetched results controller for cycle objects
    lazy var cycleFetchedResultsController : NSFetchedResultsController = {
        
        //create fetch request
        let fetchRequest = NSFetchRequest(entityName: "Cycle")

        //create search predicate to get cycles for specific wave
        fetchRequest.predicate = NSPredicate(format: "wave == %@", self.wave!)  //safely using implicitly unwrapping since wave is not nil if VC ever gets to this point
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "repsCyclePersisted", ascending: false)]
        
        //create and return fetch controller
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        return frc
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        guard let wave = wave else {
            //no wave passed in, dismiss VC and return
            //TODO: THROW ERROR?
            print("no wave present, dismissing")
            self.dismissViewControllerAnimated(false, completion: nil)
            return
        }
        
        //perform fetch
        do {
            try self.cycleFetchedResultsController.performFetch()
        } catch {
            //failed to fetch, print error
            print(error)
        }
        
        //check for cycles, if no cycles exist, create them
        guard let cycles = self.cycleFetchedResultsController.fetchedObjects as? [Cycle] where cycles != [] else {
            
            //create cycles for five, three, and one
            let cycleFive = Cycle(repsCycle: RepsCycle.FiveReps, completed: false, context: self.sharedContext)
            let cycleThree = Cycle(repsCycle: RepsCycle.ThreeReps, completed: false, context: self.sharedContext)
            let cycleFiveThreeOne = Cycle(repsCycle: RepsCycle.FiveThreeOneReps, completed: false, context: self.sharedContext)
            
            //create deload cycle if user is using one
            let cycleDeload = WorkoutManagerClinet.sharedInstance.deload ? Cycle(repsCycle: RepsCycle.Deload, completed: false, context: self.sharedContext) : nil
            
            //set cycles wave to wave
            cycleFive?.wave = wave
            cycleThree?.wave = wave
            cycleFiveThreeOne?.wave = wave
            cycleDeload?.wave = wave
            
            //save context
            CoreDataStackManager.sharedInstance.saveContext()
            return
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    //gets number of sections to be displayed in table
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        //get sections info from fetch
        let sections = self.cycleFetchedResultsController.sections! as [NSFetchedResultsSectionInfo]
        return sections.count
    }

    //gets number of rows for each table section
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //get rows in each section
        let sections = self.cycleFetchedResultsController.sections! as [NSFetchedResultsSectionInfo]
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }

    //configure cell
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //get cyclefor row
        let cycle = self.cycleFetchedResultsController.objectAtIndexPath(indexPath) as! Cycle
        
        //set reuseID
        let reuseID = "CycleCell"
        
        //create cell
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseID, forIndexPath: indexPath) 

        // Configure the cell ad return
        cell.textLabel?.text = cycle.repsCycle.description
        return cell
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    //selecting cycle shows list of exercises
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //get cycle at row
        let cycle = self.cycleFetchedResultsController.objectAtIndexPath(indexPath) as! Cycle
        print(cycle.repsCycle.description)
        //TODO:  MAKE SEGUE TO NEXT VC
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
