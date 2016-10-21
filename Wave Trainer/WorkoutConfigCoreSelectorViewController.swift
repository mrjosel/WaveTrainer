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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //remove whitespace
        self.automaticallyAdjustsScrollViewInsets = false
        
        //set text of labels
        self.directionLabel.text = "Select up to two Core Lifts"
        self.directionLabel.textAlignment = .center
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
        
        //set accessory view and return
        cell.accessoryType = .none  //TODO: SET IT IF EXISTS IN ROUTINE
        return cell
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
