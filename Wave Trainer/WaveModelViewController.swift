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
class WaveModelViewController: TabParentViewController {

    
    //outlets
    @IBOutlet weak var coreDataTableView: UITableView!
    
    //var for local reference to CoreData singleton
    var sharedContext = CoreDataStackManager.sharedInstance.managedObjectContext
    
    //dummy index var for creating/naming waves
    var index : Int = 0
    
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
        
        //perform fetch
        do {
            try self.waveFetchedResultsController.performFetch()
        } catch {
            print(error)
        }
        
        //set index based on results in fetch
        if let fetchedResults = self.waveFetchedResultsController.fetchedObjects {
            self.index = fetchedResults.count
        } else {
            self.index = 1
        }
        
    }
    
    //adds wave to CoreData
    func addWave(sender: UIBarButtonItem) {
        print("creating Wave", self.index)
        //create wave, wave has date set to now, no endDate, and is incomplete, save context
//        let newWave = Wave(startDate: NSDate(), endDate: nil, completed: false, context: self.sharedContext)
//        newWave?.name = "Wave " + String(self.index)
        self.index += 1
//        do {
//            try self.sharedContext.save()
//        } catch {
//            print(error)
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
