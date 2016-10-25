//
//  ExerciseListViewController.swift
//  WaveTrainer
//
//  Created by Brian Josel on 10/21/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import UIKit
import CoreData

//protocol for picking exercises in pickerVC
protocol ExercisePickerViewControllerDelegate {
    func exercisePicker(didPickExercise exercise: Exercise?) -> Void
}

//view controller for viewing exercises
class ExerciseListViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, ExercisePickerViewControllerDelegate {
    
    //outlets
    @IBOutlet weak var tableView: UITableView!
    
    
    //var for local reference to CoreData singleton
    var sharedContext = CoreDataStackManager.sharedInstance.managedObjectContext
    
    //workout passed in from previous viewController
    var workout : Workout?  //TODO: MAY HAVE TO REMOVE
    
    //exercise array
    var exercises = [Exercise]()
    
//    //fetched results controller for Workout objects
//    lazy var exerciseFetchedResultsController : NSFetchedResultsController<Exercise> = { () -> NSFetchedResultsController<Exercise> in
//        
//        //create fetch request
//        let fetchRequest = NSFetchRequest<Exercise>(entityName: "Exercise")
//        
//        //create search predicate to get workouts for specific workout, if workout exists
//        if let workout = self.workout {
//            fetchRequest.predicate = NSPredicate(format: "workout == %@", workout)
//        }
//        //set sort descriptor
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "orderPersisted", ascending: false)]
//        
//        //create and return fetch controller
//        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
//        return frc
//    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //add button to add exercises
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addExercise(_:)))
        self.navigationItem.setRightBarButton(addButton, animated: false)
        
        //set title
        self.navigationItem.title = "Exercises"
        
//        //ensure workout was successfully passed in from previous view controller
//        guard workout != nil else {
//            //do not finish routines involving tableViewor FRC
//            return
//        }
        
        //set delegates and dataSource
//        self.exerciseFetchedResultsController.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        //TODO:  ADJUST DELEGATE METHODS TO WORK IF NO WORKOUT PRESENT

//        //perform fetch
//        do {
//            try self.exerciseFetchedResultsController.performFetch()
//        } catch {
//            print(error)
//        }
    }
    
    //adds exercise to CoreData
    func addExercise(_ sender: UIBarButtonItem) {
        
        //create controller, set delegate,  present modally
        let controller = storyboard?.instantiateViewController(withIdentifier: "ExercisePickerViewController") as! ExercisePickerViewController
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }
    
    //method called by picker controller, handles when user selects exercise in pickerVC
    func exercisePicker(didPickExercise exercise: Exercise?) {
        
        //incoming exercise has dummyContext, recreate new object using sharedContext
        guard let pickedExercise = exercise as Exercise? else {
            return
        }
        //TODO: WHY DOES THIS BREAK?
        //      RECURSION (INIFINITE LOOP?) http://stackoverflow.com/questions/21212988/xcode-continuously-crashes-given-thread-1-exc-bad-access-code-2-address-0x8
        //create dictionary for new exercise
        let data = Exercise.makeExerciseDict(pickedExercise)
        let dict = [WorkoutManagerClient.Keys.DATA : data]
        
        //create new exercise and save context
        guard let newExercise = Exercise(dict: dict as [String : AnyObject], reps: nil, order: nil, context: self.sharedContext) else {
            print("failed to create exercise")
            //TODO: MAKE ALERT
            return
        }

        //add to array, reload table
        self.exercises.append(newExercise)
        self.tableView.reloadData()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    //gets number of sections to be displayed in table
    func numberOfSections(in tableView: UITableView) -> Int {
        
//        //get sections info from fetch
//        let sections = self.exerciseFetchedResultsController.sections! as [NSFetchedResultsSectionInfo]
//        return sections.count
        return 1
    }
    
    //gets number of rows for each table section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //get rows in each section
//        let sections = self.exerciseFetchedResultsController.sections! as [NSFetchedResultsSectionInfo]
//        let sectionInfo = sections[section]
//        return sectionInfo.numberOfObjects
        return self.exercises.count
    }
    
    //configure cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //get workout for row
        let exercise = self.exercises[indexPath.row]//self.exerciseFetchedResultsController.object(at: indexPath)
        
        //set reuseID
        let reuseID = "ExerciseCell"
        
        //create cell
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseID, for: indexPath)
        
        
        // Configure the cell and return
        cell.textLabel?.text = exercise.name
        guard let category = exercise.category else {
            return cell
        }
        cell.detailTextLabel?.text = "Category: " + category
        return cell
    }
    
    //delete or move cells
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    
        //different behavior depending on editing style
        switch editingStyle {
        case .delete:
            self.exercises.remove(at: indexPath.row)
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.tableView.endUpdates()
        default:
            break
        }
    }
    
    //can move rows while in edit mode
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //adjust order of exercises in array
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        //get exercise at sourceIndexPath
        let exercise = self.exercises.remove(at: sourceIndexPath.row)
        
        //insert exercise at destinationIndexPath
        self.exercises.insert(exercise, at: destinationIndexPath.row)
        
    }
    
    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
//    //fetch results controller delegate methods
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        //begin the tableView updates
//        self.tableView.beginUpdates()
//    }
//    
//    //manages adding sections in the event of different sections in fetch
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
//        
//        //check change type
//        switch type {
//        //insert new section
//        case .insert:
//            self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
//        //delete section
//        case .delete:
//            self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
//        default:
//            print("error: reached default of didChangeSection in fetchController")
//            return
//        }
//    }
//    
//    //manages the changing of an object in the fetch
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        
//        //check change type
//        switch type {
//        //insert new object
//        case .insert:
//            self.tableView.insertRows(at: [newIndexPath!], with: .fade)
//        //delete object
//        case .delete:
//            self.tableView.deleteRows(at: [indexPath!], with: .fade)
//        //update object
//        case .update:
//            //get wave from fetch
//            let exercise = self.exerciseFetchedResultsController.object(at: indexPath!)
//            
//            //get cell
//            let cell = self.tableView.cellForRow(at: indexPath!)! as UITableViewCell
//            
//            //set label of cell as wave name, return cell
//            cell.textLabel?.text = exercise.name
//        //move object
//        case .move:
//            self.tableView.deleteRows(at: [indexPath!], with: .fade)
//            self.tableView.insertRows(at: [newIndexPath!], with: .fade)
//            
//        }
//    }
//    
//    //end updates when finished
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        self.tableView.endUpdates()
//    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
