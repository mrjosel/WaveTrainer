//
//  ExercisePickerViewController.swift
//  WaveTrainer
//
//  Created by Brian Josel on 9/14/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import UIKit
import CoreData

//searches exercises and ads exercise to coreData to workout
class ExercisePickerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    //outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var exerciseTableView: UITableView!
    
    //exercises, used to populate tableView
    var exercises = [Exercise]()
    
    //delegate
    var delegate : ExercisePickerViewControllerDelegate?
    
    //MOCs, dummy context for returned search terms, shared for actual selected result
    var dummyContext : NSManagedObjectContext!
    var sharedContext : NSManagedObjectContext!
    
    //search task - URLSessionTask containing search term in search bar
    var searchTask : URLSessionTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set delegates
        self.searchBar.delegate = self
        self.exerciseTableView.delegate = self
        
        //show cancel button and begin first responder
        self.searchBar.showsCancelButton = true
        self.searchBar.becomeFirstResponder()
        
        //set background
        self.view.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
        
        //create dummy context
        self.dummyContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        self.dummyContext.persistentStoreCoordinator = CoreDataStackManager.sharedInstance.persistentStoreCoordinator
        self.sharedContext = CoreDataStackManager.sharedInstance.managedObjectContext

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    //called whenever text is entered
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("editing")
    }
    
    //cancel button was clicked, exit controller
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        //call delegate with no exercise object
        self.delegate?.exercisePicker(didAddExercise: nil)
        
        //dismiss
        self.exitPickerVC()
    }
    
    //dimiss VC and resign first responder
    func exitPickerVC() {
    
        //remove search bar
        searchBar.resignFirstResponder()
        
        //dismiss VC
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    //return tableRows for array of exercises
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.exercises.count
    }

    //configures cells at each row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //create and return cell
        let reuseID = "pickerCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseID, for: indexPath)
        return cell
    }
    
    //call delegate with selected exercise
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //get exercise
        let exercise = self.exercises[indexPath.row]
        
        //call delegate with exercise
        self.delegate?.exercisePicker(didAddExercise: exercise)
        
        //dismiss
        self.exitPickerVC()
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
