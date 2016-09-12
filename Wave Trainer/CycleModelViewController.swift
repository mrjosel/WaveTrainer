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
            return
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
