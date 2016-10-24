//
//  RoutineConfigCoreSelectorViewController.swift
//  WaveTrainer
//
//  Created by Brian Josel on 10/20/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import UIKit

//allows configuration of new workout by selecting core exercises first
class WorkoutConfigCoreSelectorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //outlets
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    //selected indicies - keeps trackof which coreLifts are selected
    var selectedIndicies = [IndexPath]()
    
    //exercises button
    var exercisesButton : UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //set delegate and dataSource
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        //remove whitespace
        self.automaticallyAdjustsScrollViewInsets = false
        
        //set text of label
        self.directionLabel.text = "Select up to two Core Lifts"
        self.directionLabel.textAlignment = .center
        
        //add button to add exercises
        self.exercisesButton = UIBarButtonItem(title: "Exercises >", style: .plain, target: self, action: #selector(self.addExercise(_:)))
        self.navigationItem.setRightBarButton(exercisesButton, animated: false)
        self.exercisesButton.isEnabled = self.selectedIndicies.count > 0
        
        //set title
        self.navigationItem.title = "Core Lifts"
    }
    
    //sends to exerciseVC
    func addExercise(_ sender : UIButton) {
        
        //create VC
        let exerciseVC = self.storyboard?.instantiateViewController(withIdentifier: "ExerciseListViewController") as! ExerciseListViewController
        
        //
        
        //move onto exercise listVC
        self.navigationController?.pushViewController(exerciseVC, animated: true)
    }
    
    // MARK : Table View Datasource
    
    //one section only
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //one row per coreLift
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CoreLift.caseCount
    }
    
    //display each cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //get lift
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "coreLift"), let coreLift = CoreLift(rawValue: indexPath.row) else {
            //no lift nor cell, return empty cell
            return UITableViewCell()
        }
        
        //set title
        cell.textLabel?.text = coreLift.description
        
        //set accessory view, selecttion style and return
        cell.accessoryType = .none
        cell.selectionStyle = .none
        return cell
    }
    
    //toggle checkbox view when selected, only allow display of two checkboxes
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        ////get cell, if selectedIndicies is size 2, then exit routine (two coreLifts per routine only)
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
        
        //check if selected cell is in selectedIndicies
        guard let selectedIndex = self.selectedIndicies.index(of: indexPath) else {
            
            //not in selectedIndicies, append to array and turn on checkmark iff less than 2 selectedIndicies, enable add button
            if self.selectedIndicies.count < 2 {
                cell.accessoryType = .checkmark
                self.selectedIndicies.append(indexPath)
                self.exercisesButton.isEnabled = true
            }
            return
        }
        
        //found in selectedIndicies, turn off checkmark and remove indexPath from array
        cell.accessoryType = .none
        self.selectedIndicies.remove(at: selectedIndex)
        
        //enable addButton depending on size of selectedIndicies
        self.exercisesButton.isEnabled = self.selectedIndicies.count > 0
    }
    
    //limit tableViewheightto content view only
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        //if last row, update tableViewHeightConstraint, else do nothing
        if indexPath.row == self.tableView.numberOfRows(inSection: indexPath.section) - 1 {
            self.tableViewHeightConstraint.constant = self.tableView.contentSize.height
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
