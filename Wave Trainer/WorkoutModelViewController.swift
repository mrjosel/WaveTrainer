//
//  WorkoutModelViewController.swift
//  WaveTrainer
//
//  Created by Brian Josel on 9/12/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import UIKit
import CoreData

class WorkoutModelViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    //outlets
    @IBOutlet weak var workoutTableView: UITableView!

    //MOC
    let sharedContext = CoreDataStackManager.sharedInstance.managedObjectContext
    
    //cycle passed in from previous VC
    var cycle : Cycle?
    
    //add and edit buttons
    //var addWorkoutButton : UIBarButtonItem!
    //var editWorkoutButton : UIBarButtonItem!
    
    //fetched results controller for cycle objects
    lazy var workoutFetchedResultsController : NSFetchedResultsController<Workout> = { () -> NSFetchedResultsController<Workout> in
        
        //create fetch request
        let fetchRequest = NSFetchRequest<Workout>(entityName: "Workout")
        
        //create search predicate to get cycles for specific wave
        fetchRequest.predicate = NSPredicate(format: "cycle == %@", self.cycle!)  //safely using implicitly unwrapping since wave is not nil if VC ever gets to this point
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        
        //create and return fetch controller
        let frc = NSFetchedResultsController<Workout>(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        return frc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //set delegate and dataSource
        self.workoutTableView.delegate = self
        self.workoutTableView.dataSource = self
        self.workoutFetchedResultsController.delegate = self
        
        //create and add buttons to controller
        //self.addWorkoutButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addWorkout(_:)))
        //self.editWorkoutButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.editWorkout(_:)))
        //self.navigationItem.setRightBarButton(self.addWorkoutButton, animated: false)
        //self.navigationItem.rightBarButtonItems = [self.addWorkoutButton, self.editWorkoutButton]
        
        //set title
        self.navigationItem.title = "Workout"
        
        //ensure cycle was passed in from prevoious VC
        guard let cycle = self.cycle else {
            //no wave passed in, dismiss VC and return
            //TODO: THROW ERROR?
            print("no cycle present, dismissing")
            self.dismiss(animated: false, completion: nil)
            return
        }
        
        //fetch workouts
        do {
            try self.workoutFetchedResultsController.performFetch()
        } catch {
            //failed to complete fetch, dismiss VC
            print(error)
            //TODO: ALERT USER
            self.dismiss(animated: true, completion: nil)
        }
        
        //if no workouts exist, create four base workouts based on core lifts
        guard let workouts = self.workoutFetchedResultsController.fetchedObjects, !workouts.isEmpty else {
            //self.workoutTableView.isHidden = true
            //self.addWorkoutButton.isEnabled = true
            //self.editWorkoutButton.isEnabled = false
            
            let ohp = Workout(name: "OHP", order: 0, context: self.sharedContext)
            let deadlift = Workout(name: "Deadlift", order: 1, context: self.sharedContext)
            let bench = Workout(name: "Bench Press", order: 2, context: self.sharedContext)
            let squat = Workout(name: "Squat", order: 3, context: self.sharedContext)
            
            //set workout cycles to self.cycle
            ohp?.cycle = cycle
            deadlift?.cycle = cycle
            bench?.cycle = cycle
            squat?.cycle = cycle
            
            //save context
            CoreDataStackManager.sharedInstance.saveContext()
            return
        }   
        
        //hide add workout button and show editWorkoutButton
        //self.addWorkoutButton.isEnabled = false
        //self.editWorkoutButton.isEnabled = true
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    //add workout to cycle
    func addWorkout(_ sender : UIButton) {
        print("adding workout")
    }
    
    //edit workout, allows deletion and reordering
    func editWorkout(_ sender : UIButton) {
        print("editing workout")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    //gets number of sections to be displayed in table
    func numberOfSections(in tableView: UITableView) -> Int {
        
        //get sections info from fetch
        let sections = self.workoutFetchedResultsController.sections! as [NSFetchedResultsSectionInfo]
        return sections.count
    }
    
    //gets number of rows for each table section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //get rows in each section
        let sections = self.workoutFetchedResultsController.sections! as [NSFetchedResultsSectionInfo]
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    //configure cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //get cyclefor row
        let workout = self.workoutFetchedResultsController.object(at: indexPath)
        
        //set reuseID
        let reuseID = "WorkoutCell"
        
        //create cell
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseID, for: indexPath)
        
        // Configure the cell ad return
        cell.textLabel?.text = workout.name
        return cell
    }
    
    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    //selecting cycle shows list of exercises
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //get cycle at row
        let workout = self.workoutFetchedResultsController.object(at: indexPath)
        
        //create controller, pass workout in, present
        let controller = storyboard?.instantiateViewController(withIdentifier: "ExerciseModelViewController") as! ExerciseModelViewController
        controller.workout = workout
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    //fetch results controller delegate methods
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //begin the tableView updates
        self.workoutTableView.beginUpdates()
    }
    
    //manages adding sections in the event of different sections in fetch
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        //check change type
        switch type {
        //insert new section
        case .insert:
            self.workoutTableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        //delete section
        case .delete:
            self.workoutTableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
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
            self.workoutTableView.insertRows(at: [newIndexPath!], with: .fade)
        //delete object
        case .delete:
            self.workoutTableView.deleteRows(at: [indexPath!], with: .fade)
        //update object
        case .update:
            //get wave from fetch
            let workout = self.workoutFetchedResultsController.object(at: indexPath!)
            
            //get cell
            let cell = self.workoutTableView.cellForRow(at: indexPath!)! as UITableViewCell
            
            //set label of cell as wave name, return cell
            cell.textLabel?.text = workout.name
        //move object
        case .move:
            self.workoutTableView.deleteRows(at: [indexPath!], with: .fade)
            self.workoutTableView.insertRows(at: [newIndexPath!], with: .fade)
            
        }
    }
    
    //end updates when finished
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.workoutTableView.endUpdates()
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
