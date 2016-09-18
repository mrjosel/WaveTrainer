//
//  ExerciseModelViewController.swift
//  WaveTrainer
//
//  Created by Brian Josel on 9/12/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import UIKit
import CoreData

//protocol for picking exercises in pickerVC
protocol ExercisePickerViewControllerDelegate {
    func exercisePicker(didAddExercise exercise: Exercise?) -> Void
}

//view controller for viewing exercises
class ExerciseModelViewController: UITableViewController, ExercisePickerViewControllerDelegate {

    //var for local reference to CoreData singleton
    var sharedContext = CoreDataStackManager.sharedInstance.managedObjectContext
    
    //workout passed in from previous viewController
    var workout : Workout?
    
    //fetched results controller for Workout objects
    lazy var exerciseFetchedResultsController : NSFetchedResultsController<Exercise> = { () -> NSFetchedResultsController<Exercise> in
        
        //create fetch request
        let fetchRequest = NSFetchRequest<Exercise>(entityName: "Exercise")
        
        //create search predicate to get workouts for specific wave
        fetchRequest.predicate = NSPredicate(format: "workout == %@", self.workout!)  //safely using implicitly unwrapping since wave is not nil if VC ever gets to this point
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "orderPersisted", ascending: false)]
        
        //create and return fetch controller
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        return frc
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ensure workout was successfully passed in from previous view controller
        guard workout != nil else {
            
            //workout not passed in, dismiss VC
            print("error: failed to pass in workout, dismissing")
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        //add button to add exercises
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addExercise(_:)))
        self.navigationItem.setRightBarButton(addButton, animated: false)
        
        //perform fetch
        do {
            try self.exerciseFetchedResultsController.performFetch()
        } catch {
            print(error)
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    //adds exercise to CoreData
    func addExercise(_ sender: UIBarButtonItem) {
        
        //create controller, set delegate,  present modally
        let controller = storyboard?.instantiateViewController(withIdentifier: "ExercisePickerViewController") as! ExercisePickerViewController
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
        
    }
    
    //method called by picker controller, handles when user selects exercise in pickerVC
    func exercisePicker(didAddExercise exercise: Exercise?) {
        print("didAddExercise called, \(exercise?.name)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    //gets number of sections to be displayed in table
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        //get sections info from fetch
        let sections = self.exerciseFetchedResultsController.sections! as [NSFetchedResultsSectionInfo]
        return sections.count
    }
    
    //gets number of rows for each table section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //get rows in each section
        let sections = self.exerciseFetchedResultsController.sections! as [NSFetchedResultsSectionInfo]
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    //configure cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //get workout for row
        let exercise = self.exerciseFetchedResultsController.object(at: indexPath)
        print(exercise.name)
        
        //set reuseID
        let reuseID = "ExerciseCell"
        
        //create cell
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseID, for: indexPath)
        
        // Configure the cell and return
        cell.textLabel?.text = "exercise" //TODO: EXERCISE STRING
        return cell
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    //selecting workout shows list of exercises
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*
        //get workout at row
        let exercise = self.exerciseFetchedResultsController.object(at: indexPath)
        
        //create controller, pass wave in, present
        let controller = storyboard?.instantiateViewController(withIdentifier: "ExerciseModelViewController") as! ExerciseModelViewController
        controller.workout = workout
        self.navigationController?.pushViewController(controller, animated: true)
        */
    }
    
    //fetch results controller delegate methods
    func controllerWillChangeContent(controller: NSFetchedResultsController<Exercise>) {
        //begin the tableView updates
        self.tableView.beginUpdates()
    }
    
    //manages adding sections in the event of different sections in fetch
    func controller(controller: NSFetchedResultsController<Exercise>, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
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
    func controller(controller: NSFetchedResultsController<Exercise>, didChangeObject anObject: AnyObject, atIndexPath indexPath: IndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
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
            let exercise = self.exerciseFetchedResultsController.object(at: indexPath!)
            
            //get cell
            let cell = self.tableView.cellForRow(at: indexPath!)! as UITableViewCell
            
            //set label of cell as wave name, return cell
            cell.textLabel?.text = exercise.name
        //move object
        case .move:
            self.tableView.deleteRows(at: [indexPath!], with: .fade)
            self.tableView.insertRows(at: [newIndexPath!], with: .fade)
            
        }
    }
    
    //end updates when finished
    func controllerDidChangeContent(controller: NSFetchedResultsController<Exercise>) {
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
