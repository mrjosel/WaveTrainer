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
class WaveModelViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    //var for local reference to CoreData singleton
    var sharedContext = CoreDataStackManager.sharedInstance.managedObjectContext
    
    //dummy index var for creating/naming waves
    var index : Int! {
        didSet {
            self.userDefaults.setValue(self.index!, forKey: "waveIndex")
        }
    }
    
    //NSUserefaults, used to manage index
    let userDefaults = UserDefaults.standard
    
    //fetchedResultsController
    lazy var waveFetchedResultsController : NSFetchedResultsController<Wave> = { () -> NSFetchedResultsController<Wave> in
        
        //create fetch request
        let fetchRequest = NSFetchRequest<Wave>(entityName: "Wave")
        
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
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addWave(_:)))
        self.navigationItem.setRightBarButton(addButton, animated: false)
        //set title
        self.navigationItem.title = "Waves Viewer"
        
        //set delegates and data sources (where applicable)
        self.waveFetchedResultsController.delegate = self
        
        //perform fetch
        do {
            try self.waveFetchedResultsController.performFetch()
        } catch {
            print(error)
        }
        
        //set index based on user defaults
        self.index = {
            guard let index = self.userDefaults.value(forKey: "waveIndex") as? Int else {
                return 1
            }
            return index
        }()
    }
    
    //adds wave to CoreData
    func addWave(_ sender: UIBarButtonItem) {
        //create wave, wave has date set to now, no endDate, and is incomplete, save context
        let newWave = Wave(startDate: Date(), endDate: nil, completed: false, context: self.sharedContext)
        newWave?.name = "Wave " + String(self.index)
        self.index! += 1
        CoreDataStackManager.sharedInstance.saveContext()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //sets number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //get section info from fetch, return number of objects for section
        let sectionInfo = self.waveFetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    //creates cells for tableView
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //set reuseID
        let reuseID = "WaveCell"
        
        //get wave from fetch
        let wave = self.waveFetchedResultsController.object(at: indexPath)
        
        //create cell
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseID)! as UITableViewCell
        
        //set label of cell as wave name, return cell
        cell.textLabel?.text = wave.name
        return cell
    }
    
    //manages behavior when cell is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //get wave at path
        let wave = self.waveFetchedResultsController.object(at: indexPath)
        
        //create controller, pass wave in, present
        let controller = storyboard?.instantiateViewController(withIdentifier: "CycleModelViewController") as! CycleModelViewController
        controller.wave = wave
        self.navigationController?.pushViewController(controller, animated: true)
        
        
    }
    
    //manages delete behavior of cells
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            //get wave at path
            let wave = self.waveFetchedResultsController.object(at: indexPath)
            
            //decrement index if wave thats deleted is last row in table (which implies being in the last section as well)
            let lastSection = tableView.numberOfSections - 1
            let lastRow = tableView.numberOfRows(inSection: (indexPath as NSIndexPath).section) - 1
            self.index! = (indexPath as NSIndexPath).section == lastSection && (indexPath as NSIndexPath).row == lastRow ? self.index - 1 : self.index
            
            //delete wave from context, save context
            self.sharedContext.delete(wave)
            CoreDataStackManager.sharedInstance.saveContext()
        default:
            //should never get to this point
            print("error: reached default state of delete method")
            break
        }
    }
    
    //begin tableView updates when fetch changes
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
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
            let wave = self.waveFetchedResultsController.object(at: indexPath!)
            
            //get cell
            let cell = self.tableView.cellForRow(at: indexPath!)! as UITableViewCell
            
            //set label of cell as wave name, return cell
            cell.textLabel?.text = wave.name
        //move object
        case .move:
            self.tableView.deleteRows(at: [indexPath!], with: .fade)
            self.tableView.insertRows(at: [newIndexPath!], with: .fade)
            
        }
    }
    
    //end tableView updates when fetch changes
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
