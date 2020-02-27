//
//  ViewController.swift
//  Metro Explorer
//
//  Created by XYZ on 11/20/18.
//  Copyright © 2018 XYZ. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func findNearestStationButtonPressed(_ sender: Any) {
        print("find nearest station pressed")
        performSegue(withIdentifier: "nearestStationsSegue", sender: self)
    }
    
    @IBAction func findMetroStationsButtonPressed(_ sender: Any) {
        
        print("find stations pressed")
        performSegue(withIdentifier: "mstationsSegue", sender: self)
        
    }
    
    @IBAction func favoriteLandmarksButtonPressed(_ sender: Any) {
        print("favorite landmarks pressed")
        performSegue(withIdentifier: "favoriteSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //pass the data to your next view controller
        if segue.identifier == "nearestStationsSegue" {
            let vc = segue.destination as! LandmarksTableViewController
            vc.flag = 0
        }
        if segue.identifier == "favoriteSegue"{
            let vc = segue.destination as! LandmarksTableViewController
            vc.flag = 1
        }
        
    }
    
}

