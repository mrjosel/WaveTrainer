//
//  WaveModelViewController.swift
//  WaveTrainer
//
//  Created by Brian Josel on 9/8/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import UIKit
import CoreData

//class to view CoreData model in a Table View Controller
//NOT TO BE IMPLEMENTED IN RELEASE
class WaveModelViewController: TabParentViewController, NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource {

    
    //outlets
    @IBOutlet weak var coreDataTableView: UITableView!
    
    //var for local reference to CoreData singleton
    var sharedContext = CoreDataStackManager.sharedInstance.managedObjectContext
    
    //dummy index var for creating/naming waves
    var index : Int! {
        didSet {
            self.userDefaults.setValue(self.index!, forKey: "waveIndex")
        }
    }
    
    //NSUserefaults, used to manage index
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    //fetchedResultsController
    lazy var waveFetchedResultsController : NSFetchedResultsController = {
        
        //create fetch request
        let fetchRequest = NSFetchRequest(entityName: "Wave")
        
        //set sort descriptors
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startDatePersisted", ascending: true)]
        
        //create controller and return
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil
        )
        return frc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //create add button and add to navigation bar
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(self.addWave(_:)))
        self.navigationItem.setRightBarButtonItem(addButton, animated: false)
        //set title
        self.navigationItem.title = "Waves Viewer"
        
        //set delegates and data sources (where applicable)
        self.coreDataTableView.delegate = self
        self.coreDataTableView.dataSource = self
        self.waveFetchedResultsController.delegate = self
        
        //perform fetch
        do {
            try self.waveFetchedResultsController.performFetch()
        } catch {
            print(error)
        }
        
        //set index based on user defaults
        self.index = {
            guard let index = self.userDefaults.valueForKey("waveIndex") as? Int else {
                return 1
            }
            return index
        }()
    }
    
    //adds wave to CoreData
    func addWave(sender: UIBarButtonItem) {
        print("creating Wave", self.index)
        //create wave, wave has date set to now, no endDate, and is incomplete, save context
        let newWave = Wave(startDate: NSDate(), endDate: nil, completed: false, context: self.sharedContext)
        newWave?.name = "Wave " + String(self.index)
        self.index! += 1
        CoreDataStackManager.sharedInstance.saveContext()
        print("fetch count is", self.waveFetchedResultsController.fetchedObjects!.count)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //sets number of rows
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //get section info from fetch, return number of objects for section
        let sectionInfo = self.waveFetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    //creates cells for tableView
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //set reuseID
        let reuseID = "WaveCell"
        
        //get wave from fetch
        let wave = self.waveFetchedResultsController.objectAtIndexPath(indexPath) as! Wave
        
        //create cell
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseID)! as UITableViewCell
        
        //set label of cell as wave name, return cell
        cell.textLabel?.text = wave.name
        return cell
    }
    
    //manages behavior when cell is selected
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //get wave at path
        let wave = self.waveFetchedResultsController.objectAtIndexPath(indexPath) as! Wave
        
        //print wave name (for now)
        //TODO: CREATE SEGUE TO NEXT VC TO VIEW CYCLES
        print(wave.name)
    }
    
    //manages delete behavior of cells
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Delete:
            //get wave at path
            let wave = self.waveFetchedResultsController.objectAtIndexPath(indexPath) as! Wave
            
            //decrement index if wave thats deleted is last row in table (which implies being in the last section as well)
            let lastSection = tableView.numberOfSections - 1
            let lastRow = tableView.numberOfRowsInSection(indexPath.section) - 1
            self.index! = indexPath.section == lastSection && indexPath.row == lastRow ? self.index - 1 : self.index
            
            //delete wave from context, save context
            self.sharedContext.deleteObject(wave)
            CoreDataStackManager.sharedInstance.saveContext()
        default:
            //should never get to this point
            print("error: reached default state of delete method")
            break
        }
    }
    
    //begin tableView updates when fetch changes
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.coreDataTableView.beginUpdates()
    }
    
    //manages adding sections in the event of different sections in fetch
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        //check change type
        switch type {
        //insert new section
        case .Insert:
            self.coreDataTableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        //delete section
        case .Delete:
            self.coreDataTableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            print("error: reached default of didChangeSection in fetchController")
            return
        }
    }
    
    //manages the changing of an object in the fetch
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        //check change type
        switch type {
        //insert new object
        case .Insert:
            self.coreDataTableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        //delete object
        case .Delete:
            self.coreDataTableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        //update object
        case .Update:
            //get wave from fetch
            let wave = self.waveFetchedResultsController.objectAtIndexPath(indexPath!) as! Wave
            
            //get cell
            let cell = self.coreDataTableView.cellForRowAtIndexPath(indexPath!)! as UITableViewCell
            
            //set label of cell as wave name, return cell
            cell.textLabel?.text = wave.name
        //move object
        case .Move:
            self.coreDataTableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            self.coreDataTableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            
        }
    }
    
    //end tableView updates when fetch changes
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.coreDataTableView.endUpdates()
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
