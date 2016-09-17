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
    lazy var cycleFetchedResultsController : NSFetchedResultsController<Cycle> = { () -> NSFetchedResultsController<Cycle> in
        
        //create fetch request
        let fetchRequest = NSFetchRequest<Cycle>(entityName: "Cycle")

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
        
        //set FRC delegate
        self.cycleFetchedResultsController.delegate = self
        
        //ensure wave was passed in
        guard let wave = wave else {
            //no wave passed in, dismiss VC and return
            //TODO: THROW ERROR?
            print("no wave present, dismissing")
            self.dismiss(animated: false, completion: nil)
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
        guard let cycles = self.cycleFetchedResultsController.fetchedObjects, !cycles.isEmpty else {
            
            //create cycles for five, three, and one
            let cycleFive = Cycle(repsCycle: RepsCycle.fiveReps, completed: false, context: self.sharedContext)
            let cycleThree = Cycle(repsCycle: RepsCycle.threeReps, completed: false, context: self.sharedContext)
            let cycleFiveThreeOne = Cycle(repsCycle: RepsCycle.fiveThreeOneReps, completed: false, context: self.sharedContext)
            
            //create deload cycle if user is using one
            let cycleDeload = WorkoutManagerClinet.sharedInstance.deload ? Cycle(repsCycle: RepsCycle.deload, completed: false, context: self.sharedContext) : nil
            
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
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        //get sections info from fetch
        let sections = self.cycleFetchedResultsController.sections! as [NSFetchedResultsSectionInfo]
        return sections.count
    }

    //gets number of rows for each table section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //get rows in each section
        let sections = self.cycleFetchedResultsController.sections! as [NSFetchedResultsSectionInfo]
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }

    //configure cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //get cyclefor row
        let cycle = self.cycleFetchedResultsController.object(at: indexPath) 
        
        //set reuseID
        let reuseID = "CycleCell"
        
        //create cell
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseID, for: indexPath) 

        // Configure the cell ad return
        cell.textLabel?.text = cycle.repsCycle.description
        return cell
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    //selecting cycle shows list of exercises
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //get cycle at row
        let cycle = self.cycleFetchedResultsController.object(at: indexPath) 
        
        //create controller, pass wave in, present
        let controller = storyboard?.instantiateViewController(withIdentifier: "WorkoutModelViewController") as! WorkoutModelViewController
        controller.cycle = cycle
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    //fetch results controller delegate methods
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //begin the tableView updates
        self.tableView.beginUpdates()
    }
    
    //manages adding sections in the event of different sections in fetch
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        //check change type
        switch type {
        //insert new section
        case .insert:
            self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        //delete section
        case .delete:
            self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            print("error: reached default of didChangeSection in fetchController")
            return
        }
    }
    
    //manages the changing of an object in the fetch
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        //check change type
        switch type {
        //insert new object
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with: .fade)
        //delete object
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .fade)
        //update object
        case .update:
            //get wave from fetch
            let cycle = self.cycleFetchedResultsController.object(at: indexPath!) 
            
            //get cell
            let cell = self.tableView.cellForRow(at: indexPath!)! as UITableViewCell
            
            //set label of cell as wave name, return cell
            cell.textLabel?.text = cycle.repsCycle.description
        //move object
        case .move:
            self.tableView.deleteRows(at: [indexPath!], with: .fade)
            self.tableView.insertRows(at: [newIndexPath!], with: .fade)
            
        }
    }
    
    //end updates when finished
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
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
