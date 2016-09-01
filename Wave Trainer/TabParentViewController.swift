//
//  TabParentViewController.swift
//  Wave Trainer
//
//  Created by Brian Josel on 8/31/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import UIKit

class TabParentViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //create menu button and add to navigation bar
        let menuButton = UIBarButtonItem(image: UIImage(named: "menuImage"), style: .Plain, target: self, action: #selector(self.showMenu(_:)))
        self.navigationItem.setLeftBarButtonItem(menuButton, animated: false)
        //set title
        self.navigationItem.title = "Wave Trainer"
        
    }
    
    //shows menu panel
    func showMenu(sender: UIBarButtonItem) {
        //TODO: IMPLEMENT MENU
        print("showing menu")
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
